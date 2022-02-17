class_name CareerData
## Stores current and historical data for career mode
##
## This includes the current day's data like "how much money has the player earned today" and "how far have they
## travelled today", as well as historical information like "how many days have they played" and "how much money did
## they earn three days ago"

## Emitted when the player's distance changes, particularly at the start of career mode when they're picking their
## starting distance
signal distance_travelled_changed

## Emitted when the number of levels played in the current career session changes. It's unusual for this to change
## mid-scene, and really only happens when using cheat codes.
signal hours_passed_changed

## The 3rd and 6th levels in career mode include a cutscene interlude.
const CAREER_INTERLUDE_HOURS := [2, 5]

## Chat key root for non-region-specific cutscenes
const GENERAL_CHAT_KEY_ROOT := "chat/career/general"

## The number of days worth of records which are stored.
const MAX_DAILY_HISTORY := 40

## The maximum number of days the player can progress.
const MAX_DAY := 999999

## The maximum distance the player can travel.
const MAX_DISTANCE_TRAVELLED := 999999

## The maximum number of consecutive levels the player can play in one career session.
const HOURS_PER_CAREER_DAY := 8

## Array of dictionaries containing milestone metadata, including the necessary rank, the distance the player will
## travel, and the UI color.
const RANK_MILESTONES := [
	{"rank": 64.0, "distance": 1, "color": Color("48b968")},
	{"rank": 36.0, "distance": 2, "color": Color("48b968")},
	{"rank": 24.0, "distance": 3, "color": Color("48b968")},
	{"rank": 20.0, "distance": 4, "color": Color("78b948")},
	{"rank": 16.0, "distance": 5, "color": Color("b9b948")},
	{"rank": 10.0, "distance": 10, "color": Color("b95c48")},
	{"rank": 4.0, "distance": 15, "color": Color("b94878")},
	{"rank": 0.0, "distance": 25, "color": Color("b948b9")},
]

## The rank milestone to display when the player fails a boss level.
const RANK_MILESTONE_FAIL := {"rank": 64.0, "distance": 0, "color": Color("bababa")}

## The number of steps the player couldn't take because they were blocked by a boss level.
var banked_steps := 0

## The distance the player has travelled in the current career session.
var distance_travelled := 0 setget set_distance_travelled

## The distance earned from the previously completed puzzle.
var distance_earned := 0

## The number of levels played in the current career session.
var hours_passed := 0 setget set_hours_passed

## The number of customers served in the current career session.
var daily_customers := 0

## The amount of money earned in the current career session.
var daily_earnings := 0

## The level IDs played in the current career session. This is tracked to avoid repeating levels.
var daily_level_ids := []

## The amount of time played in the current career session.
var daily_seconds_played := 0.0

## The number of steps taken in the current career session (not including initial level selection)
var daily_steps := 0

## The number of days the player has completed.
var day := 0

## Array of ints for previous daily earnings. Index 0 holds the most recent data.
var prev_daily_earnings := []

## Array of ints for previous distance travelled. Index 0 holds the most recent data.
var prev_distance_travelled := []

## The furthest total distance the player has travelled in a single session.
var max_distance_travelled := 0

## 'true' if the player skipped or gave up on the previous level, instead of finishing it or topping out.
var skipped_previous_level := false

## Returns 'true' if the player has completed the current career mode session.
func is_day_over() -> bool:
	return hours_passed >= HOURS_PER_CAREER_DAY


func reset() -> void:
	banked_steps = 0
	distance_travelled = 0
	distance_earned = 0
	hours_passed = 0
	daily_customers = 0
	daily_earnings = 0
	daily_level_ids.clear()
	daily_seconds_played = 0.0
	daily_steps = 0
	day = 0
	prev_daily_earnings.clear()
	prev_distance_travelled.clear()
	max_distance_travelled = 0
	skipped_previous_level = false
	emit_signal("distance_travelled_changed")


func from_json_dict(json: Dictionary) -> void:
	banked_steps = int(json.get("banked_steps", 0))
	distance_travelled = int(json.get("distance_travelled", 0))
	distance_earned = int(json.get("distance_earned", 0))
	hours_passed = int(json.get("hours_passed", 0))
	daily_customers = int(json.get("daily_customers", 0))
	daily_earnings = int(json.get("daily_earnings", 0))
	daily_level_ids = json.get("daily_level_ids", [])
	daily_seconds_played = float(json.get("daily_seconds_played", 0.0))
	daily_steps = int(json.get("daily_steps", 0))
	day = int(json.get("day", 0))
	prev_daily_earnings = json.get("prev_daily_earnings", [])
	prev_distance_travelled = json.get("prev_distance_travelled", [])
	max_distance_travelled = int(json.get("max_distance_travelled", 0))
	skipped_previous_level = bool(json.get("skipped_previous_level", false))
	emit_signal("distance_travelled_changed")


func to_json_dict() -> Dictionary:
	var results := {}
	results["banked_steps"] = banked_steps
	results["distance_travelled"] = distance_travelled
	results["distance_earned"] = distance_earned
	results["hours_passed"] = hours_passed
	results["daily_customers"] = daily_customers
	results["daily_earnings"] = daily_earnings
	results["daily_level_ids"] = daily_level_ids
	results["daily_seconds_played"] = daily_seconds_played
	results["daily_steps"] = daily_steps
	results["day"] = day
	results["prev_daily_earnings"] = prev_daily_earnings
	results["prev_distance_travelled"] = prev_distance_travelled
	results["max_distance_travelled"] = max_distance_travelled
	results["skipped_previous_level"] = skipped_previous_level
	return results


## Launches the next scene in career mode. Either a new level, or a cutscene/ending scene.
func push_career_trail() -> void:
	# Purge any puzzle or cutscene scenes from trail before changing the scene.
	while Breadcrumb.trail.front() != Global.SCENE_CAREER_MAP:
		Breadcrumb.trail.pop_front()
	
	var redirected := false
	if not redirected and not CutsceneManager.is_queue_empty():
		# If there are pending puzzles/cutscenes, show them.
		
		# If the player is playing a puzzle, we immediately apply failure penalties to the player's save data so they
		# can't quit and retry.
		if CutsceneManager.is_front_level():
			_preapply_failure_penalties()
		
		CutsceneManager.push_trail()
		redirected = true
	
	if not redirected and is_day_over():
		# After the final level, we show a 'you win' screen.
		SceneTransition.replace_trail("res://src/main/ui/career/CareerWin.tscn")
		redirected = true
	
	if not redirected and should_play_prologue():
		# If they haven't seen the region's prologue cutscene, we show it.
		var region: CareerRegion = CareerLevelLibrary.region_for_distance(distance_travelled)
		var prologue_chat_key: String = region.get_prologue_chat_key()
		CurrentCutscene.set_launched_cutscene(prologue_chat_key)
		CurrentCutscene.push_cutscene_trail()
		redirected = true
	
	if not redirected:
		# After a puzzle (or any other scene), we go back to the career map.
		SceneTransition.change_scene()


func should_play_prologue() -> bool:
	var region: CareerRegion = CareerLevelLibrary.region_for_distance(distance_travelled)
	var prologue_chat_key: String = region.get_prologue_chat_key()
	return ChatLibrary.chat_exists(prologue_chat_key) \
			and not PlayerData.chat_history.is_chat_finished(prologue_chat_key)


## Returns 'true' if the player is current playing career mode
func is_career_mode() -> bool:
	return Global.SCENE_CAREER_MAP in Breadcrumb.trail


## Returns 'true' if the player is current playing a cutscene in career mode
func is_career_cutscene() -> bool:
	return Global.SCENE_CAREER_MAP in Breadcrumb.trail


## Returns 'true' if the player has completed the boss level in the specified region
func is_region_cleared(region: CareerRegion) -> bool:
	return max_distance_travelled > region.distance + region.length - 1


## Returns 'true' if the current career mode distance corresponds to an uncleared boss level
func is_boss_level() -> bool:
	var result := true
	var region: CareerRegion = CareerLevelLibrary.region_for_distance(distance_travelled)
	if distance_travelled != region.distance + region.length - 1:
		# the player is not at the end of the region
		result = false
	elif not region.boss_level:
		# the region has no boss level
		result = false
	elif is_region_cleared(region):
		# the player has already cleared this boss level
		result = false
	return result


## Returns the number of levels the player can choose between, based on their current distance and progress.
func level_choice_count() -> int:
	return 1 if is_boss_level() else 3


## Returns the player's distance penalties for picking different levels.
##
## Upon beating a level, the player is advanced by distance_earned. If they select one of the two leftmost levels,
## a penalty is applied and they don't travel as far.
##
## Returns:
## 	An array of positive ints corresponding to the penalty for selecting each level. Index 0 corresponds to the
## 	earliest level.
func distance_penalties() -> Array:
	var result := [0, 0, 0]
	
	if level_choice_count() == 1:
		# if the player has no choice, there is no penalty
		return result
	
	# adjust result[0]
	if distance_earned < 0: result [0] = 1 # small penalty for level selection after failing a boss stage
	elif distance_earned <= 1: result[0] = 0 # no penalty after skipping, or for the first level of a set
	elif distance_earned <= 2: result[0] = 1
	elif distance_earned <= 5: result[0] = 2
	elif distance_earned <= 6: result[0] = 3
	else: result[0] = 4
	
	# adjust result[1]
	if distance_earned <= 1: result[1] = 0 # no penalty after skipping, or for the first level of a set
	elif distance_earned <= 5: result[1] = 1
	else: result[1] = 2
	
	return result


## Advances the clock, and advances the player the specified distance.
##
## Even if new_distance_earned is a large number, the player's travel distance can be limited in two scenarios.
##
## 1. If they just played a non-boss level, they cannot advance past a boss level they haven't cleared.
##
## 2. If they just played a boss level, they cannot advance without meeting its success criteria.
##
## Parameters:
## 	'new_distance_earned': The maximum distance the player will travel.
##
## 	'success': 'True' if the player met the success criteria for the current level.
func advance_clock(new_distance_earned: int, success: bool) -> void:
	distance_earned = new_distance_earned
	skipped_previous_level = false
	
	hours_passed += 1
	
	if is_boss_level():
		var boss_region: CareerRegion = CareerLevelLibrary.region_for_distance(distance_travelled)
		if success:
			# if they pass a boss level, update max_distance_travelled to mark the region as cleared
			max_distance_travelled = boss_region.distance + boss_region.length
		else:
			# if they fail a boss level, they lose 1-2 days worth of progress
			distance_earned = -int(max(boss_region.length * rand_range(0.125, 0.25), 2))
	
	if distance_earned > 0:
		# if they make forward progress, they also spend their banked steps
		distance_earned += banked_steps
		banked_steps = 0
	
	var unapplied_distance_earned := distance_earned
	while unapplied_distance_earned != 0:
		unapplied_distance_earned = _apply_distance_earned(unapplied_distance_earned)


## Advances the calendar day and resets all daily variables
func advance_calendar() -> void:
	prev_daily_earnings.push_front(daily_earnings)
	if prev_daily_earnings.size() > MAX_DAILY_HISTORY:
		prev_daily_earnings = prev_daily_earnings.slice(0, MAX_DAILY_HISTORY - 1)
	
	max_distance_travelled = max(max_distance_travelled, distance_travelled)
	prev_distance_travelled.push_front(distance_travelled)
	if prev_distance_travelled.size() > MAX_DAILY_HISTORY:
		prev_distance_travelled = prev_distance_travelled.slice(0, MAX_DAILY_HISTORY - 1)
	
	# Put the player at the start of their current region.
	distance_travelled = CareerLevelLibrary.region_for_distance(distance_travelled).distance
	
	banked_steps = 0
	distance_earned = 0
	hours_passed = 0
	daily_customers = 0
	daily_earnings = 0
	daily_level_ids.clear()
	daily_seconds_played = 0.0
	daily_steps = 0
	day = min(day + 1, MAX_DAY)
	emit_signal("distance_travelled_changed")


func set_distance_travelled(new_distance_travelled: int) -> void:
	distance_travelled = new_distance_travelled
	emit_signal("distance_travelled_changed")


func set_hours_passed(new_hours_passed: int) -> void:
	hours_passed = new_hours_passed
	emit_signal("hours_passed_changed")


## Updates the state of career mode based on the player's puzzle performance.
##
## If the player skips or fails a level, this has consequences including skipping cutscenes and advancing the clock.
func process_puzzle_result() -> void:
	var skip_remaining_cutscenes := false
	if not PuzzleState.game_ended:
		# player skipped a level
		skip_remaining_cutscenes = true
		PlayerData.career.advance_clock(0, false)
		PlayerData.career.skipped_previous_level = true
	
	if PlayerData.career.is_boss_level() and not CurrentLevel.best_result == Levels.Result.WON:
		# player didn't meet the win criteria for a boss level
		skip_remaining_cutscenes = true
	
	if skip_remaining_cutscenes:
		# skip career cutscenes if they skip a level, or if they fail a boss level
		CutsceneManager.reset()

## Applies some of the player's distance earned, either advancing the player or throwing it away.
##
## This only applies a small chunk of the player's distance earned, stopping at region boundaries. It should be called
## iteratively until it returns zero.
##
## Parameters:
## 	'unapplied_distance_earned': The amount of distance_earned which hasn't been applied to advance the player, or
## 		thrown away.
##
## Returns:
## 	The remaining amount of the player's distance earned, after applying some of it toward advancing the player or
## 		throwing it away.
func _apply_distance_earned(unapplied_distance_earned: int) -> int:
	var region: CareerRegion = CareerLevelLibrary.region_for_distance(distance_travelled)
	var newly_banked_steps := 0
	var newly_travelled_distance := unapplied_distance_earned
	
	if distance_travelled + unapplied_distance_earned >= region.distance + region.length:
		# The player is trying to cross into the next region
		var distance_to_next_region := region.distance + region.length - distance_travelled
		if is_region_cleared(region):
			# The player can cross into the next region. Move them to the start of the next region and allow
			# movement.
			newly_travelled_distance = distance_to_next_region
		else:
			# The player can't cross into the next region, they haven't cleared the boss level. Move them to the end
			# of this region and forbid movement.
			newly_banked_steps = unapplied_distance_earned - distance_to_next_region + 1
	
	# if the player hit a wall, we bank their steps and don't move them as far this time
	banked_steps += newly_banked_steps
	newly_travelled_distance -= newly_banked_steps
	unapplied_distance_earned -= newly_banked_steps
	
	distance_travelled += newly_travelled_distance
	unapplied_distance_earned -= newly_travelled_distance
	
	return unapplied_distance_earned


## Applies penalties for skipping a level to the player's save data, so they can't quit and retry.
func _preapply_failure_penalties() -> void:
	var temp_distance_earned := distance_earned
	var temp_distance_travelled := distance_travelled
	var temp_hours_passed := hours_passed
	advance_clock(0, false)
	skipped_previous_level = true
	PlayerSave.save_player_data()
	distance_earned = temp_distance_earned
	distance_travelled = temp_distance_travelled
	hours_passed = temp_hours_passed


## Calculates the highest rank milestone the player's reached.
static func rank_milestone_index(rank: float) -> int:
	var rank_milestone_index := 0
	for i in range(1, RANK_MILESTONES.size()):
		var rank_milestone: Dictionary = RANK_MILESTONES[i]
		if rank > rank_milestone.rank:
			break
		rank_milestone_index = i
	return rank_milestone_index
