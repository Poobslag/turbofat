extends Node
## Non-interactive demo which prints the currently bound keys in JSON format.
##
## Useful for saving a new keybind preset from the current InputMap.

func _ready() -> void:
	var json_dict := {}
	
	var actions := InputMap.get_actions()
	actions.sort()
	for action in actions:
		json_dict[action] = []
		for action_item in InputMap.get_action_list(action):
			var json_action_item := KeybindManager.input_event_to_json(action_item)
			if json_action_item:
				json_dict[action].append(json_action_item)
	
	print(Utils.print_json(json_dict))
