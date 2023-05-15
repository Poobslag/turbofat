class_name SaveItem
## Individual chunk of save data.
##
## A chunk of save data includes a type and value and, optionally, a key. Some data, such as the player's money, is
## unique to the player. Other data is organized by a key field. For example, their high scores are tracked by level
## name.

## String unique to each type of data (level-data, player-data)
var type: String

## String identifying a specific data item (sophie, marathon-normal)
var key: String

## Value object (array, dictionary, string) containing the data
var value

func from_json_dict(json: Dictionary) -> void:
	type = json.get("type", "")
	key = json.get("key", "")
	value = json.get("value", "")


func to_json_dict() -> Dictionary:
	return {"type": type, "key": key, "value": value} if key else {"type": type, "value": value}
