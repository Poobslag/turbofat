extends Button
## Runs all release tools.

func _pressed() -> void:
	for button in get_tree().get_nodes_in_group("release_tool_buttons"):
		button.run()
