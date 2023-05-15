class_name PracticeData
## Stores data for practice/tutorial mode.
##
## This includes the previous region, level and difficulty the player chose.

## region id the player last chose in practice mode
var region_id: String

## level id the player last chose in practice mode
var level_id: String

## level id the player last chose in tutorial mode
var tutorial_level_id: String

## piece speed the player last chose in practice mode
var piece_speed: String

func reset() -> void:
	region_id = ""
	level_id = ""
	tutorial_level_id = ""
	piece_speed = ""


func from_json_dict(json: Dictionary) -> void:
	region_id = json.get("region_id", "")
	level_id = json.get("level_id", "")
	piece_speed = json.get("piece_speed", "")
	tutorial_level_id = json.get("tutorial_level_id", "")


func to_json_dict() -> Dictionary:
	var results := {}
	results["region_id"] = region_id
	results["level_id"] = level_id
	results["piece_speed"] = piece_speed
	results["tutorial_level_id"] = tutorial_level_id
	return results
