extends Control
## Converts click events into ui_accept events which can be handled by the ChatUi.

export (NodePath) var chat_frame_path: NodePath
export (NodePath) var narration_frame_path: NodePath

## index of the current click event, or -1 if there is none
var _click_index := -1

## 'true' if the player is making a dialog choice
var _showing_choices := false

## scancode which triggers a ui_accept action.
## echo events cannot be emitted without an InputEventKey instance which requires a scancode
var _ui_accept_scancode: int

onready var _chat_frame: ChatFrame = get_node(chat_frame_path)
onready var _narration_frame: NarrationFrame = get_node(narration_frame_path)

func _ready() -> void:
	# calculate a scancode which triggers a ui_accept action
	for action_item in InputMap.get_action_list("ui_accept"):
		if action_item is InputEventKey:
			_ui_accept_scancode = action_item.scancode
			break
	
	_disable_translation()


func _input(event: InputEvent) -> void:
	if not is_processing():
		return
	
	if not _chat_frame.is_chat_window_showing() and not _narration_frame.is_narration_window_showing():
		return
	
	if event is InputEventMouseButton:
		_handle_mouse_button(event)


func _process(_delta: float) -> void:
	if _click_index != -1:
		# emit an echo event
		_emit_ui_accept_event(true, true)


## Translates the current click event into a ui_accept event.
func _emit_ui_accept_event(pressed: bool, echo: bool) -> void:
	var ev := InputEventKey.new()
	ev.scancode = _ui_accept_scancode
	ev.pressed = pressed
	ev.echo = echo
	Input.parse_input_event(ev)


## Temporarily disables click translation.
##
## This is done when showing chat choices, or when the chat window is not being shown.
func _disable_translation() -> void:
	if _click_index != -1:
		_emit_ui_accept_event(false, false)
		_click_index = -1
	set_process(false)


## Reenables click translation.
##
## Click translation is reenabled during a brief delay to prevent a bug where a click event is immediately processed,
## causing all text to appear.
func _enable_translation() -> void:
	call_deferred("set_process", true)


## Emits press/release events based on a mouse click.
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed \
			and _click_index == -1 \
			and not _showing_choices \
			and not _is_event_within_cutscene_button(event):
		# emit a press event
		_click_index = event.button_index
		if is_inside_tree():
			get_tree().set_input_as_handled()
		_emit_ui_accept_event(true, false)

	if not event.pressed and _click_index == event.button_index:
		# emit a release event
		_click_index = -1
		if is_inside_tree():
			get_tree().set_input_as_handled()
		_emit_ui_accept_event(false, false)


## Returns 'true' if the press/release event is within a button, such as the settings button.
##
## When watching a cutscene, most mouse clicks advance the cutscene, but the player also needs to be able to press
## certain buttons.
func _is_event_within_cutscene_button(event: InputEventMouseButton) -> bool:
	var result := false
	for button in get_tree().get_nodes_in_group("cutscene_buttons"):
		if button.visible and button.get_global_rect().has_point(event.global_position):
			result = true
			break
	return result


func _on_ChatUi_popped_in() -> void:
	_enable_translation()


func _on_ChatUi_showed_choices() -> void:
	_showing_choices = true


func _on_ChatChoices_chat_choice_chosen(_choice_index: int) -> void:
	_showing_choices = false


func _on_ChatUi_chat_finished() -> void:
	_disable_translation()
