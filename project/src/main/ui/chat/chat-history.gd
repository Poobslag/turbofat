class_name ChatHistory
## Stores a history of conversations the player's had.
##
## Keeps track of which conversations the player's had and how long ago they've had them.

## Constant for the age of conversations we've never had. This is a large number so that evaluating 'have we had this
## conversation recently?' will work without requiring a third branch to handle the case where we haven't had a
## conversation before.
const CHAT_AGE_NEVER := 99999999

## Tracks which conversations the player has had with each creature. The value is a per-creature index which starts
## from 0 and increments with each conversation with that creature.
##
## key: chat key
## value: ordering of when the chat happened (smaller is older)
var chat_history: Dictionary

var _chat_count := 0

func reset() -> void:
	chat_history.clear()


func add_history_item(chat_key: String) -> void:
	_chat_count += 1
	chat_history[chat_key] = _chat_count


## Deletes an item from the chat history.
##
## Returns:
## 	'true' if the key was present in the chat history, 'false' otherwise.
func delete_history_item(chat_key: String) -> bool:
	return chat_history.erase(chat_key)


## Returns how long ago the player had the specified chat.
##
## Used to avoid repeating conversations too frequently.
func chat_age(chat_key: String) -> int:
	var result := CHAT_AGE_NEVER
	if chat_history.has(chat_key):
		result = _chat_count - chat_history.get(chat_key)
	return result


func is_chat_finished(chat_key: String) -> bool:
	return chat_history.has(chat_key)


func to_json_dict() -> Dictionary:
	return {
		"history_items": chat_history,
	}


func from_json_dict(json: Dictionary) -> void:
	chat_history = json.get("history_items", {})
	_convert_float_values_to_ints(chat_history)
	
	# calculate _chat_count instead of storing it
	for value in chat_history.values():
		_chat_count = int(max(value, _chat_count))


## Converts the float values in a Dictionary to int values.
##
## Godot's JSON parser converts all ints into floats, so we need to change them back. See Godot #9499
## https://github.com/godotengine/godot/issues/9499
func _convert_float_values_to_ints(dict: Dictionary) -> void:
	for key in dict:
		if dict[key] is float:
			dict[key] = int(dict[key])
