extends Node
## Calculates the necessary level metadata for the player to attain their expected grade.
##
## This demo takes the player's best performance and calculates the necessary level adjustments so that their best
## performance will result in the specified grade. For example, a player might usually play at an 'SSS' rank, but they
## make very few boxes on one specific level, because the level is difficult. So this demo might calculate and print
## something like 'box_factor=0.5' indicating that the level should be more lenient for players who don't make many
## boxes.

## property keys to use when saving/loading data
const SAVE_KEY_GRADE := "level-rank-demo.grade"
const SAVE_KEY_OPEN := "level-rank-demo.open"

var _rank_calculator := LegacyRankCalculator.new()

onready var _error_dialog := $Dialogs/Error
onready var _open_dialog := $Dialogs/OpenFile
onready var _open_input := $Input/Open
onready var _grade_input := $Input/PlayerGrade
onready var _text_edit := $Input/Output
onready var _demo_save := $DemoSave
onready var _calculate_button := $Input/CalculateButton

func _ready() -> void:
	_load_demo_data()
	_refresh_level()


func _refresh_level() -> void:
	# load the level settings
	var level_settings := LevelSettings.new()
	level_settings.load_from_resource(_open_input.value)
	CurrentLevel.start_level(level_settings)
	_calculate_button.disabled = not PlayerData.level_history.has_result(CurrentLevel.level_id)
	
	# immediately recalculate the level metadata
	if not _calculate_button.disabled:
		_calculate()


## Calculates and outputs the necessary level metadata for the player to attain their expected grade.
func _calculate() -> void:
	_text_edit.text = ""
	
	# peform the calculations
	_calculate_extra_seconds_per_piece()
	_calculate_box_factor()
	_calculate_combo_factor()
	_calculate_master_pickup_score_per_line()
	
	# trim extra newlines from the output
	_text_edit.text = _text_edit.text.strip_edges().rstrip(",")
	_text_edit.text = "\"rank\": [\n%s\n]," % [_text_edit.text]


## Calculates and outputs the extra_seconds_per_piece for levels which inhibit fast players.
func _calculate_extra_seconds_per_piece() -> void:
	var target_rank := _target_rank()
	var best_result := _best_result()
	
	var extra_seconds_per_piece_min := 0.0
	var extra_seconds_per_piece_max := 2.0
	for _i in range(20):
		CurrentLevel.settings.rank.legacy_rules["extra_seconds_per_piece"] = \
				0.5 * (extra_seconds_per_piece_min + extra_seconds_per_piece_max)
		var lpm_for_grade := _rank_calculator.rank_lpm(target_rank)
		if lpm_for_grade >= best_result.lines / max(best_result.seconds, 1):
			extra_seconds_per_piece_min = CurrentLevel.settings.rank.legacy_rules.get("extra_seconds_per_piece", 0.0)
		else:
			extra_seconds_per_piece_max = CurrentLevel.settings.rank.legacy_rules.get("extra_seconds_per_piece", 0.0)
	
	_text_edit.text += "\"extra_seconds_per_piece %.2f\",\n" \
			% [CurrentLevel.settings.rank.legacy_rules.get("extra_seconds_per_piece", 0.0)]


## Calculates and outputs the box_factor for levels which inhibit snack and cake boxes.
func _calculate_box_factor() -> void:
	var target_rank := _target_rank()
	var best_result := _best_result()
	
	var box_factor_min := 0.0
	var box_factor_max := 4.0
	for _i in range(20):
		CurrentLevel.settings.rank.legacy_rules["box_factor"] = \
				0.5 * (box_factor_min + box_factor_max)
		var box_score_for_grade := float(CurrentLevel.settings.rank.legacy_rules.get("box_factor", 1.0)) \
				* LegacyRankCalculator.MASTER_BOX_SCORE * pow(LegacyRankCalculator.RDF_BOX_SCORE_PER_LINE, target_rank)
		if box_score_for_grade >= best_result.box_score / max(best_result.lines, 1):
			box_factor_max = float(CurrentLevel.settings.rank.legacy_rules.get("box_factor", 1.0))
		else:
			box_factor_min = float(CurrentLevel.settings.rank.legacy_rules.get("box_factor", 1.0))
	
	_text_edit.text += "\"box_factor %.2f\",\n" % [CurrentLevel.settings.rank.legacy_rules.get("box_factor", 1.0)]


## Calculates and outputs the combo_factor for levels which inhibit combos.
func _calculate_combo_factor() -> void:
	var target_rank := _target_rank()
	var best_result := _best_result()
	
	var combo_factor_min := 0.0
	var combo_factor_max := 4.0
	for _i in range(20):
		CurrentLevel.settings.rank.legacy_rules["combo_factor"] = \
				0.5 * (combo_factor_min + combo_factor_max)
		var combo_score_for_grade := \
				float(CurrentLevel.settings.rank.legacy_rules.get("combo_factor", 1.0)) \
				* LegacyRankCalculator.MASTER_COMBO_SCORE \
				* pow(LegacyRankCalculator.RDF_COMBO_SCORE_PER_LINE, target_rank)
		if combo_score_for_grade >= best_result.combo_score / max(best_result.lines, 1):
			combo_factor_max = CurrentLevel.settings.rank.legacy_rules.get("combo_factor", 1.0)
		else:
			combo_factor_min = CurrentLevel.settings.rank.legacy_rules.get("combo_factor", 1.0)
	
	_text_edit.text += "\"combo_factor %.2f\",\n" % [CurrentLevel.settings.rank.legacy_rules.get("combo_factor", 1.0)]


## Calculates and outputs the master_pickup_score_per_line for levels with pickups.
func _calculate_master_pickup_score_per_line() -> void:
	var target_rank := _target_rank()
	var best_result := _best_result()
	
	CurrentLevel.settings.rank.legacy_rules["master_pickup_score_per_line"] = \
			(best_result.pickup_score / max(best_result.lines, 1)) \
			/ pow(LegacyRankCalculator.RDF_PICKUP_SCORE_PER_LINE, target_rank)
	
	_text_edit.text += "\"master_pickup_score_per_line %.2f\",\n" \
			% [CurrentLevel.settings.rank.legacy_rules.get("master_pickup_score_per_line", 0.0)]


## Returns the player's best result for the level selected in the demo.
##
## The player's data is loaded from the current save slot.
func _best_result() -> RankResult:
	return PlayerData.level_history.best_result(CurrentLevel.level_id)


## Returns the rank corresponding to the grade chosen in the demo.
func _target_rank() -> float:
	return LegacyRankCalculator.average_rank_for_grade(_grade_input.value)


## Reads the developer's in-memory data from a save file.
func _load_demo_data() -> void:
	if _demo_save.demo_data.has(SAVE_KEY_GRADE):
		_grade_input.value = _demo_save.demo_data[SAVE_KEY_GRADE]
	if _demo_save.demo_data.has(SAVE_KEY_OPEN):
		_open_input.value = _demo_save.demo_data[SAVE_KEY_OPEN]


## Writes the developer's in-memory data to a save file.
func _save_demo_data() -> void:
	_demo_save.demo_data[SAVE_KEY_GRADE] = _grade_input.value
	_demo_save.demo_data[SAVE_KEY_OPEN] = _open_input.value
	_demo_save.save_demo_data()


func _on_CalculateButton_pressed() -> void:
	_save_demo_data()
	_calculate()


func _on_OpenFileDialog_file_selected(path: String) -> void:
	if path.begins_with("res://assets/main/") and path.ends_with(".json"):
		_open_input.value = LevelSettings.level_key_from_path(path)
	else:
		_error_dialog.dialog_text = "%s doesn't seem like the path to a level file." % [path]
		_error_dialog.popup_centered()
	
	_refresh_level()


func _on_OpenButton_pressed() -> void:
	_open_dialog.current_path = LevelSettings.path_from_level_key(_open_input.value)
	_open_dialog.popup_centered()
