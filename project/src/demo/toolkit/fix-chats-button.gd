extends Button
## Reports problems in the chats.
##
## Recursively searches for chats, reporting any problems.

## directories containing chats which should be checked for problems
const CHAT_DIRS := ["res://assets/main/chat"]

export (NodePath) var output_label_path: NodePath

## chatscript paths which have problems
var _problems := []

## label for outputting messages to the user
onready var _output_label: Label = get_node(output_label_path)

## Reports any chats with problems.
func _report_problems_for_chats() -> void:
	var chat_paths := _find_chat_paths()
	for chat_path in chat_paths:
		_report_problems_for_chat(chat_path)
	
	if _problems:
		_output_label.text = "%d chatscript files have problems." % [_problems.size()]
	else:
		_output_label.text = "No chatscript files have problems."


func _report_problems_for_chat(chat_path: String) -> void:
	var chat_tree: ChatTree = ChatLibrary.chat_tree_from_file(chat_path)
	for chat_key in chat_tree.events:
		for event_obj in chat_tree.events[chat_key]:
			var chat_event:ChatEvent = event_obj
			if chat_event.links:
				for link in chat_event.links:
					if not chat_tree.events.has(link):
						push_warning("%s - The chat branch '%s' references a non-existent link '%s'."
								% [chat_path, chat_key, link])
						_problems.append(chat_path)


## Returns a list of all chat paths within 'CHAT_DIRS', performing a tree traversal.
##
## Returns:
## 	List of string paths to json resources containing chat data to check for problems.
func _find_chat_paths() -> Array:
	var result := []
	
	# directories remaining to be traversed
	var dir_queue := CHAT_DIRS.duplicate()
	
	# recursively look for chat files under the specified paths
	var dir: Directory
	var file: String
	while true:
		if file:
			var resource_path := "%s/%s" % [dir.get_current_dir(), file.get_file()]
			if file.ends_with(".chat"):
				result.append(resource_path)
			elif dir.current_is_dir():
				dir_queue.append(resource_path)
		else:
			if dir:
				dir.list_dir_end()
			if dir_queue.empty():
				break
			# there are more directories. open the next directory
			dir = Directory.new()
			dir.open(dir_queue.pop_front())
			dir.list_dir_begin(true, true)
		file = dir.get_next()
	
	return result


func _on_pressed() -> void:
	_report_problems_for_chats()
