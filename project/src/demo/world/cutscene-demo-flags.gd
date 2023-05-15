extends VBoxContainer
## UI input for specifying flags to assign or unassign during cutscenes.

## Describes flags to assign or unassign during cutscenes
## Virtual property; value is only exposed through getters/setters
var value: String: get = get_value, set = set_value

## Applies the text contents to the player's data.
##
## This involves assigning and unassigning conversations they've had and levels they've played based on the input. The
## input field supports the following flags:
##
## 	'best_distance_travelled 123'
## 	'chat_finished foo'
## 	'not chat_finished foo'
## 	'level_finished foo'
## 	'not level_finished foo'
func apply_flags() -> void:
	for line_obj in $TextEdit.text.split("\n"):
		var line: String = line_obj
		if not line:
			pass
		elif line.begins_with("best_distance_travelled "):
			PlayerData.career.best_distance_travelled = \
					int(StringUtils.substring_after(line, "best_distance_travelled "))
		elif line.begins_with("chat_finished "):
			var chat_key := StringUtils.substring_after(line, "chat_finished ")
			PlayerData.chat_history.add_history_item(chat_key)
		elif line.begins_with("not chat_finished "):
			var chat_key := StringUtils.substring_after(line, "chat_finished ")
			PlayerData.chat_history.delete_history_item(chat_key)
		elif line.begins_with("level_finished "):
			var level_key := StringUtils.substring_after(line, "level_finished ")
			PlayerData.level_history.finished_levels[level_key] = Time.get_datetime_dict_from_system()
		elif line.begins_with("not level_finished "):
			var level_key := StringUtils.substring_after(line, "level_finished ")
			PlayerData.level_history.delete_results(level_key)
		elif line.begins_with("has_flag "):
			var flag := StringUtils.substring_after(line, "has_flag ")
			PlayerData.chat_history.set_flag(flag)
		elif line.begins_with("not has_flag "):
			var flag := StringUtils.substring_after(line, "has_flag ")
			PlayerData.chat_history.unset_flag(flag)
		else:
			push_warning("Unrecognized flag: %s" % [line])


func set_value(new_value: String) -> void:
	$TextEdit.text = new_value


func get_value() -> String:
	return $TextEdit.text
