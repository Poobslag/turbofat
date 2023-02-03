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
	_problems.clear()
	
	var chat_paths := _find_chat_paths()
	for chat_path in chat_paths:
		_report_problems_for_chat(chat_path)
	
	if _problems:
		_output_label.text = "%d chatscript files have problems." % [_problems.size()]
	else:
		_output_label.text = "No chatscript files have problems."


func _report_broken_chat_links(chat_tree: ChatTree) -> void:
	for chat_key in chat_tree.events:
		for event_obj in chat_tree.events[chat_key]:
			var chat_event:ChatEvent = event_obj
			if chat_event.links:
				for link in chat_event.links:
					if not chat_tree.events.has(link):
						chat_tree.warn("The chat branch '%s' references a non-existent link '%s'."
								% [chat_key, link])


func _report_invalid_meta_creature_ids(chat_tree: ChatTree) -> void:
	for chat_key in chat_tree.events:
		for event_obj in chat_tree.events[chat_key]:
			for meta_obj in event_obj.meta:
				var meta: String = meta_obj
				var meta_split: Array = meta.split(" ")
				
				if meta_split.size() < 1:
					# ignore empty meta items to avoid array out of bounds
					continue
				
				var meta_creature_ids: Array = []
				match meta_split[0]:
					"creature_enter", "creature_exit", "creature_orientation", "creature_mood":
						meta_creature_ids.append(meta_split[1])
				
				for meta_creature_id in meta_creature_ids:
					var chat_tree_has_creature := chat_tree.creature_ids.has(meta_creature_id)
					
					if not chat_tree_has_creature:
						chat_tree.warn("The chat key '%s' has an invalid creature id %s"
								% [chat_key, meta_creature_id])


## Report disallowed characters in chat keys. We only allow lowercase letters, numbers and underscores.
func _report_disallowed_characters_in_chat_keys(chat_tree: ChatTree) -> void:
	var regex := RegEx.new()
	regex.compile("[^a-z0-9_]")
	for chat_key in chat_tree.events:
		var regex_match: RegExMatch = regex.search(chat_key)
		if regex_match:
			chat_tree.warn("The chat key '%s' contains an illegal character '%s'."
					% [chat_key, regex_match.get_string()])


func _report_problems_for_chat(chat_path: String) -> void:
	var chat_tree: ChatTree = ChatLibrary.chat_tree_from_file(chat_path)
	chat_tree.suppress_warnings()
	
	_report_broken_chat_links(chat_tree)
	_report_invalid_meta_creature_ids(chat_tree)
	_report_disallowed_characters_in_chat_keys(chat_tree)
	
	var warnings: Array = chat_tree.meta.get("warnings", [])
	if warnings:
		if not _problems.has(chat_path):
			_problems.append(chat_path)
		for warning in warnings:
			push_warning("%s - %s" % [chat_path, warning])


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
