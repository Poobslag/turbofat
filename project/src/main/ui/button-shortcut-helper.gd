extends Node
## Manages shortcuts for buttons in some weird edge cases.
##
## Sometimes we want two actions to activate a button, such as a menu which is launched with the start button. The
## player would expect the 'back' button or 'menu' button to close the menu, but only one shortcut can be bound to the
## closing of the menu. This node is capable of assigning a second shortcut to a button.
##
## Sometimes we want two actions assigned to the same key, such as the 'escape' key which is bound to both 'ui_back'
## and 'ui_menu'. But, sometimes a menu might include separate cancel and menu buttons, in which case 'escape' would
## press both. This node is capable of overriding that behavior, and pressing only one button when two actions are
## activated simultaneously.

## action which activates the button
export (String) var action: String

## (optional) second action which is also required to activate the button
export (String) var overridden_action: String

## button this helper will activate
onready var button: BaseButton = get_parent()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		return
	if not event.is_action(action):
		return
	if not get_parent().is_visible_in_tree():
		# do not activate invisible buttons
		return
	if not overridden_action.empty() \
			and not Input.is_action_pressed(overridden_action) \
			and not Input.is_action_just_released(overridden_action):
		# if an 'overridden_action' is defined, only activate when both actions are activated
		return
	
	if event.is_action_pressed(action):
		# workaround for Godot #35172 (https://github.com/godotengine/godot/issues/35172); setting button pressed to
		# true doesn't work without toggle mode
		button.toggle_mode = true
		button.pressed = true
		button.emit_signal("button_down")
	if button.pressed and event.is_action_released(action):
		# workaround for Godot #35172 (https://github.com/godotengine/godot/issues/35172); setting button pressed to
		# true doesn't work without toggle mode
		button.pressed = false
		button.toggle_mode = false
		button.emit_signal("button_up")
		button.emit_signal("pressed")
	if is_inside_tree():
		get_tree().set_input_as_handled()
