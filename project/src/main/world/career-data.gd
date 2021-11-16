class_name CareerData
## Stores current and historical data for Career mode
##
## This includes the current day's data like "how much money has the player earned today" and "how far have they
## travelled today", as well as historical information like "how many days have they played" and "how much money did
## they earn three days ago"

## how many days worth of records do we keep
const MAX_DAILY_HISTORY := 40

## how many consecutive levels does the player play in one career session
const HOURS_PER_CAREER_DAY := 8

## how far has the player travelled in the current career session
var distance_travelled := 0

## how many consecutive levels has the player played in the current career session
var hours_passed := 0

## how much money has the player earned in the current career session
var daily_earnings := 0

## how many days has the player completed
var day := 0

## Array of ints for previous daily earnings. Index 0 holds the most recent data.
var prev_daily_earnings := []

func reset() -> void:
	distance_travelled = 0
	hours_passed = 0
	daily_earnings = 0
	day = 0
	prev_daily_earnings.clear()


func from_json_dict(dict: Dictionary) -> void:
	distance_travelled = dict.get("distance_travelled", 0)
	hours_passed = dict.get("hours_passed", 0)
	daily_earnings = dict.get("daily_earnings", 0)
	day = dict.get("day", 0)
	prev_daily_earnings = dict.get("prev_daily_earnings", [])


func to_json_dict() -> Dictionary:
	var results := {}
	results["distance_travelled"] = distance_travelled
	results["hours_passed"] = hours_passed
	results["daily_earnings"] = daily_earnings
	results["day"] = day
	results["prev_daily_earnings"] = prev_daily_earnings
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
		advance_calendar()
		PlayerSave.save_player_data()
		SceneTransition.replace_trail("res://src/main/world/CareerWin.tscn")


## Returns 'true' if the player is current playing career mode
func is_career_mode() -> bool:
	return Global.SCENE_CAREER_MAP in Breadcrumb.trail


## Advances the calendar day and resets all daily variables
func advance_calendar() -> void:
	prev_daily_earnings.push_front(daily_earnings)
	if prev_daily_earnings.size() > MAX_DAILY_HISTORY:
		prev_daily_earnings = prev_daily_earnings.slice(0, MAX_DAILY_HISTORY - 1)
	
	distance_travelled = 0
	hours_passed = 0
	daily_earnings = 0
	day = min(day + 1, 999999)
