extends Control
## RankOutlierDemo tab which performs statistical analysis on a .score file.

## Data about how a player's performance on a single level matched our expectations.
class SkillRecord:
	var level_id: String
	
	## Result of comparing the player's performance to the level's required threshold to obtain a master grade. A
	## value of 0.5 means the player was half as good (they scored half as much, or took twice as much time)
	var skill_percent: float
	
	## Mean of all skill percents in comparable level archetypes
	var mean: float
	
	## Deviation of this record's skill percent from the mean of all skill percents in comparable level archetypes
	var deviation: float
	
	## Standard deviation of all skill percents in comparable level archetypes
	var stddev: float

## Categories for levels based on their finish condition, and whether they enforce slow play (< 90 pieces per minute)
enum LevelArchetype {
	SANDBOX,
	CUSTOMERS,
	LINES,
	PIECES,
	SCORE,
	TIME,
	CUSTOMERS_FAST,
	LINES_FAST,
	PIECES_FAST,
	SCORE_FAST,
	TIME_FAST,
}

## 'z score' for player records which are considered outliers. A threshold of 3 means that records will be considered
## outliers if they are more than 3 standard deviations from the mean.
const OUTLIER_Z_SCORE_THRESHOLD := 3
const ALL_REGIONS := "(all)"
const MAIN_STORY_REGIONS := "(main story)"

## key: (String) level id
## value: (int) Enum from LevelArchetype
var _archetypes_by_level_id := {}

## key: (int) Enum from LevelArchetype
## value: (Array, String) level ids
var _level_ids_by_archetype := {}

## key: (String) level id
## value: (float) level's required threshold to obtain a master grade
var _best_grade_thresholds_by_level_id := {}

## key: (String) level id
## value: (float) score for the player's highest ranking performance
var _player_scores_by_level_id := {}

## key: (String) level id
## value: (float) time for the player's highest ranking performance
var _player_times_by_level_id := {}

## SkillRecord instances with data about how a player's performance on a single level matched our expectations.
var _skill_records := []

var _regions := []

onready var _option_button_regions := $VBoxContainer/Top/OptionButtonRegions
onready var _text_edit_in := $VBoxContainer/Bottom/TextEditIn
onready var _text_edit_out := $VBoxContainer/Bottom/TextEditOut

func _ready() -> void:
	_regions.append(ALL_REGIONS)
	_regions.append(MAIN_STORY_REGIONS)
	for region in CareerLevelLibrary.regions:
		_regions.append(region)
	for region in OtherLevelLibrary.regions:
		_regions.append(region)
	
	for region in _regions:
		if region is String:
			_option_button_regions.add_item(region)
		elif region is CareerRegion:
			_option_button_regions.add_item(region.id)
		elif region is OtherRegion:
			_option_button_regions.add_item(region.id)
	
	_analyze_and_refresh(_all_level_ids())


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_option_button_regions = $VBoxContainer/Top/OptionButtonRegions
	_text_edit_in = $VBoxContainer/Bottom/TextEditIn
	_text_edit_out = $VBoxContainer/Bottom/TextEditOut


func _analyze_and_refresh(level_ids: Array) -> void:
	_analyze_levels(level_ids)
	_extract_player_data()
	_analyze_player_data()
	_refresh_text()


func _all_level_ids() -> Array:
	var result := []
	for level_id in CareerLevelLibrary.all_level_ids():
		result.append(level_id)
	for level_id in OtherLevelLibrary.all_level_ids():
		result.append(level_id)
	return result


func _main_story_level_ids() -> Array:
	var result := []
	for region in CareerLevelLibrary.regions:
		if region.has_end():
			result.append_array(_level_ids_for_career_region(region))
	return result


## Analyzes data for all levels, extracting their archetypes and grading criteria.
func _analyze_levels(level_ids: Array) -> void:
	_archetypes_by_level_id.clear()
	_level_ids_by_archetype.clear()
	_best_grade_thresholds_by_level_id.clear()
	_player_scores_by_level_id.clear()
	_player_times_by_level_id.clear()
	_skill_records.clear()
	_level_ids_by_archetype.clear()
	
	for archetype in range(LevelArchetype.size()):
		_level_ids_by_archetype[archetype] = []
	for level_id in level_ids:
		_analyze_level(level_id)


## Analyzes a level's data, extracting its archetype and grading criteria.
func _analyze_level(level_id: String) -> void:
	var settings := LevelSettings.new()
	settings.load_from_resource(level_id)
	if settings.other.tutorial:
		return
	
	var piece_speed := PieceSpeeds.speed(settings.speed.get_start_speed())
	var fast := Ranks.min_frames_per_line(piece_speed) <= 80
	var level_archetype: int
	match settings.finish_condition.type:
		Milestone.CUSTOMERS:
			level_archetype = LevelArchetype.CUSTOMERS_FAST if fast else LevelArchetype.CUSTOMERS
		Milestone.LINES:
			level_archetype = LevelArchetype.LINES_FAST if fast else LevelArchetype.LINES
		Milestone.PIECES:
			level_archetype = LevelArchetype.PIECES_FAST if fast else LevelArchetype.PIECES
		Milestone.SCORE:
			level_archetype = LevelArchetype.SCORE_FAST if fast else LevelArchetype.SCORE
		Milestone.TIME_OVER:
			level_archetype = LevelArchetype.TIME_FAST if fast else LevelArchetype.TIME
		Milestone.NONE:
			level_archetype = LevelArchetype.SANDBOX
		_:
			push_warning("Unrecognized archetype for level id: %s" % [level_id])
	_best_grade_thresholds_by_level_id[level_id] = settings.rank.rank_criteria.thresholds_by_grade[Ranks.BEST_GRADE]
	_archetypes_by_level_id[level_id] = level_archetype
	_level_ids_by_archetype[level_archetype].append(level_id)


## Extract the raw data from the player's .score file.
func _extract_player_data() -> void:
	_player_times_by_level_id.clear()
	_player_scores_by_level_id.clear()
	
	var lines_in: Array = _text_edit_in.text.split("\n")
	for i in range(1, lines_in.size()):
		_parse_line(i + 1, lines_in[i])


## Analyzes a player's performance, comparing their performance to the level's expected performance.
##
## We compare levels in batches; levels with score and time goals can be compared directly, for example. A player who
## can earn ¥1,000 in a 2-minute level can also finish a level with a ¥1,000 score requirement in 2 minutes. So a
## player who is consistently scoring about 50% of the required score for a perfect grade will have a skill percent of
## 0.5 across all of those archetypes. However, levels with line goals can't be compared directly. A player who plays
## very thoughtfully may have a low skill percent on timed levels, but will play very well on marathon levels where
## time is not a factor.
##
## We compare levels in batches according to their archetypes. Each batch has its own mean and deviance.
func _analyze_player_data() -> void:
	_skill_records = []
	
	# The score and time archetypes reward players who can build boxes and combos, with a speed limit.
	_append_records([LevelArchetype.SCORE, LevelArchetype.TIME])
	
	# The "score fast" and "time fast" archetypes reward players who can build boxes and combos with no effective
	# speed limit.
	_append_records([LevelArchetype.SCORE_FAST, LevelArchetype.TIME_FAST])
	
	# The "lines" and "pieces" archetypes reward thoughtful play.
	_append_records([LevelArchetype.LINES, LevelArchetype.PIECES, LevelArchetype.LINES_FAST,
			LevelArchetype.PIECES_FAST])
	
	# The "customers" archetype rewards players who can build very, very long combos.
	_append_records([LevelArchetype.CUSTOMERS, LevelArchetype.CUSTOMERS_FAST])
	
	# sort the biggest outliers to the top
	_skill_records.sort_custom(self, "_compare_by_deviation")


## Outputs text based on the result of analyzing the player's performance.
func _refresh_text() -> void:
	_text_edit_out.text = ""
	
	var overall_variance := 0.0
	for record in _skill_records:
		overall_variance += pow(record.deviation, 2)
	overall_variance = overall_variance / _skill_records.size() if _skill_records else 0.0
	_text_edit_out.text += "Analyzed %s levels, with an overall variance of %.2f.\n" \
			% [_skill_records.size(), overall_variance]
	
	# print an outlier message; '72 (69.9%) outliers have data outside 2.5 standard deviations.'
	var outlier_count := 0
	for record in _skill_records:
		if abs(record.deviation) > record.stddev * OUTLIER_Z_SCORE_THRESHOLD:
			outlier_count += 1
	var outlier_percent := outlier_count / float(_skill_records.size()) if _skill_records else 0.0
	_text_edit_out.text += "%s (%.1f%%) outliers have data outside %s standard deviations." \
			% [outlier_count, 100 * outlier_percent, OUTLIER_Z_SCORE_THRESHOLD]
	_text_edit_out.text += "\n\n"
	
	# print the 20 biggest outliers
	for i in range(min(20, _skill_records.size())):
		var skill_record: SkillRecord = _skill_records[i]
		var compared_property: String
		var player_value: float
		var expected_value: float
		if _archetypes_by_level_id[skill_record.level_id] in [LevelArchetype.SCORE, LevelArchetype.SCORE_FAST]:
			compared_property = "time"
			player_value = _player_times_by_level_id[skill_record.level_id]
			expected_value = _best_grade_thresholds_by_level_id[skill_record.level_id] / max(0.001, skill_record.mean)
		else:
			compared_property = "score"
			player_value = _player_scores_by_level_id[skill_record.level_id]
			expected_value = _best_grade_thresholds_by_level_id[skill_record.level_id] * skill_record.mean
		var z_score: float = 0.0 if skill_record.stddev == 0.0 else skill_record.deviation / skill_record.stddev
		
		_text_edit_out.text += "%s: player %s=%d (not %d), z_score=%s\n" % [
			skill_record.level_id,
			compared_property,
			player_value,
			expected_value,
			z_score
		]
	_text_edit_out.text = _text_edit_out.text.strip_edges()


## Analyzes player data for the specified level archetypes.
##
## The result is stored in the '_skill_records' field.
func _append_records(level_archetypes: Array) -> void:
	var level_ids_to_analyze := []
	for level_archetype in level_archetypes:
		level_ids_to_analyze.append_array(_level_ids_by_archetype[level_archetype])
	
	var new_records := []
	for level_id in level_ids_to_analyze:
		if not level_id in _player_scores_by_level_id:
			continue
		var new_record := SkillRecord.new()
		new_record.level_id = level_id
		if _archetypes_by_level_id[level_id] in [LevelArchetype.SCORE, LevelArchetype.SCORE_FAST]:
			new_record.skill_percent = _best_grade_thresholds_by_level_id[level_id] \
					/ float(max(1, _player_times_by_level_id[level_id]))
		else:
			new_record.skill_percent = _player_scores_by_level_id[level_id] \
					/ float(max(1, _best_grade_thresholds_by_level_id[level_id]))
		new_records.append(new_record)
	
	if new_records:
		var mean := 0.0
		if new_records:
			for record in new_records:
				mean += record.skill_percent
			mean /= new_records.size()
		for record in new_records:
			record.mean = mean
	
	if new_records:
		for record in new_records:
			record.deviation = record.skill_percent - record.mean
	
	if new_records:
		var variance := 0.0
		for record in new_records:
			variance += pow(record.deviation, 2)
		var stddev := variance / new_records.size()
		for record in new_records:
			record.stddev = stddev
	
	_skill_records.append_array(new_records)


func _compare_by_deviation(a: SkillRecord, b: SkillRecord) -> bool:
	return abs(a.deviation / max(0.01, a.stddev)) > abs(b.deviation / max(0.01, b.stddev))


## Parses a level score from a '.score' file.
##
## These lines use the following format:
## 	practice/marathon_normal score=2609 seconds=223
func _parse_line(line_number: int, line: String) -> void:
	if line.empty():
		return
	var words := line.split(" ")
	if words.size() < 2:
		push_warning("Invalid input on line %s: %s" % [line_number, line])
		return
	
	var level_id: String = words[0]
	for word_index in range(1, words.size()):
		var word := words[word_index]
		if word.split("=").size() != 2:
			push_warning("Invalid input on line %s: %s" % [line_number, line])
			break
		
		if word.split("=")[0] == "score" and word.split("=").size() == 2:
			_player_scores_by_level_id[level_id] = int(word.split("=")[1])
		if word.split("=")[0] == "seconds" and word.split("=").size() == 2:
			_player_times_by_level_id[level_id] = int(word.split("=")[1])


func _on_Import_text_changed(new_score_text: String) -> void:
	_text_edit_in.text = new_score_text
	
	if _archetypes_by_level_id:
		_extract_player_data()
		_analyze_player_data()
		_refresh_text()


func _level_ids_for_career_region(region: CareerRegion) -> Array:
	var result := []
	var career_region: CareerRegion = region
	for level in career_region.levels:
		result.append(level.level_id)
	if career_region.intro_level:
		result.append(career_region.intro_level.level_id)
	if career_region.boss_level:
		result.append(career_region.boss_level.level_id)
	return result


func _on_OptionButtonRegions_item_selected(index: int) -> void:
	var level_ids := _all_level_ids()
	var region = _regions[index]
	if region is String and region == ALL_REGIONS:
		level_ids = _all_level_ids()
	if region is String and region == MAIN_STORY_REGIONS:
		level_ids = _main_story_level_ids()
	elif region is CareerRegion:
		level_ids = _level_ids_for_career_region(region)
	elif region is OtherRegion:
		level_ids = region.level_ids
	
	_analyze_and_refresh(level_ids)
