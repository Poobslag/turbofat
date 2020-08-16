class_name ChatHistory
"""
Stores a history of conversations the player's had.

Keeps track of which conversations the player's had and how long ago they've had them.
"""

"""
Tracks which conversations the player has had with each creature. The value is a per-creature index which starts from
0 and increments with each conversation with that creature.

key: chat key
value: ordering of when the chat happened (smaller is older)
"""
var chat_history: Dictionary

"""
Tracks the number of conversations the player has had with each creature.

key: chat key fragment
value: int corresponding to number of chats with a character
"""
var chat_counts: Dictionary

"""
Tracks the number of consecutive filler chats for each creature. After a creature has enough filler chats, they'll
have a more serious or interesting conversation.

key: creature id
value: number of consecutive filler chats
"""
var filler_counts: Dictionary

func reset() -> void:
	chat_history.clear()
	chat_counts.clear()
	filler_counts.clear()


func increment_filler_count(creature_name: String) -> void:
	filler_counts[creature_name] = get_filler_count(creature_name) + 1


func reset_filler_count(creature_name: String) -> void:
	filler_counts[creature_name] = 0


func get_filler_count(creature_name: String) -> int:
	return filler_counts.get(creature_name, 0)


func add_history_item(history_key: String) -> void:
	var chat_prefix := StringUtils.substring_before_last(history_key, "/")
	
	if not chat_counts.has(chat_prefix):
		chat_counts[chat_prefix] = 0
	var chat_count: int = chat_counts[chat_prefix]
	chat_counts[chat_prefix] += 1
	
	chat_history[history_key] = chat_count


func delete_history_item(history_key: String) -> void:
	chat_history.erase(history_key)


"""
Returns how long ago the player had the specified chat.

Used to avoid repeating conversations too frequently.
"""
func get_chat_age(history_key: String) -> int:
	var chat_prefix := StringUtils.substring_before_last(history_key, "/")
	
	var chat_count: int = chat_counts.get(chat_prefix, 0)
	var chat_time: int = chat_history.get(history_key, -1)
	
	var result := -1
	if chat_count > 0 and chat_time != -1:
		result = chat_count - chat_time - 1
	return result


func to_json_dict() -> Dictionary:
	return {
		"history-items": chat_history,
		"counts": chat_counts,
		"filler-counts": chat_counts,
	}


func from_json_dict(json: Dictionary) -> void:
	chat_history = json.get("history-items", {})
	chat_counts = json.get("counts", {})
	filler_counts = json.get("filler-counts", {})
