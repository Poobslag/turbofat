class_name CareerData
## Stores current and historical data for Career mode
##
## This includes the current day's data like "how much money has the player earned today" and "how far have they
## travelled today", as well as historical information like "how many days have they played" and "how much money did
## they earn three days ago"

## The number of days worth of records which are stored.
const MAX_DAILY_HISTORY := 40

## The maximum number of days the player can progress.
const MAX_DAY := 999999

## The maximum distance the player can travel.
const MAX_DISTANCE_TRAVELLED := 999999

## The maximum number of consecutive levels the player can play in one career session.
const HOURS_PER_CAREER_DAY := 8

## The distance the player has travelled in the current career session.
var distance_travelled := 0

## The distance earned from the previously completed puzzle.
var distance_earned := 0

## The number of levels played in the current career session.
var hours_passed := 0

## The amount of money earned in the current career session.
var daily_earnings := 0

## The level IDs played in the current career session. This is tracked to avoid repeating levels.
var daily_level_ids := []

## The number of days the player has completed.
var day := 0

## Array of ints for previous daily earnings. Index 0 holds the most recent data.
var prev_daily_earnings := []

## Array of ints for previous distance travelled. Index 0 holds the most recent data.
var prev_distance_travelled := []

func reset() -> void:
	distance_travelled = 0
	distance_earned = 0
	hours_passed = 0
	daily_earnings = 0
	daily_level_ids.clear()
	day = 0
	prev_daily_earnings.clear()
	prev_distance_travelled.clear()


func from_json_dict(dict: Dictionary) -> void:
	distance_travelled = dict.get("distance_travelled", 0)
	distance_earned = dict.get("distance_earned", 0)
	hours_passed = dict.get("hours_passed", 0)
	daily_earnings = dict.get("daily_earnings", 0)
	daily_level_ids = dict.get("daily_level_ids", [])
	day = dict.get("day", 0)
	prev_daily_earnings = dict.get("prev_daily_earnings", [])
	prev_distance_travelled = dict.get("prev_distance_travelled", [])


func to_json_dict() -> Dictionary:
	var results := {}
	results["distance_travelled"] = distance_travelled
	results["distance_earned"] = distance_earned
	results["hours_passed"] = hours_passed
	results["daily_earnings"] = daily_earnings
	results["daily_level_ids"] = daily_level_ids
	results["day"] = day
	results["prev_daily_earnings"] = prev_daily_earnings
	results["prev_distance_travelled"] = prev_distance_travelled
	return results


## Launches the next scene in career mode. Either a new level, or a cutscene/ending scene.
func push_career_trail() -> void:
	if hours_passed < HOURS_PER_CAREER_DAY:
		# after the 'overworld map' scene, we launch a level
		hours_passed += 1
		PlayerSave.save_player_data()
		CurrentLevel.push_level_trail()
	else:
		# after the final level, we show a 'you win' screen
		SceneTransition.replace_trail("res://src/main/world/CareerWin.tscn")


## Returns 'true' if the player is current playing career mode
func is_career_mode() -> bool:
	return Global.SCENE_CAREER_MAP in Breadcrumb.trail


## Advances the calendar day and resets all daily variables
func advance_calendar() -> void:
	prev_daily_earnings.push_front(daily_earnings)
	if prev_daily_earnings.size() > MAX_DAILY_HISTORY:
		prev_daily_earnings = prev_daily_earnings.slice(0, MAX_DAILY_HISTORY - 1)
	
	prev_distance_travelled.push_front(distance_travelled)
	if prev_distance_travelled.size() > MAX_DAILY_HISTORY:
		prev_distance_travelled = prev_distance_travelled.slice(0, MAX_DAILY_HISTORY - 1)
	
	distance_travelled = 0
	hours_passed = 0
	daily_earnings = 0
	day = min(day + 1, MAX_DAY)
