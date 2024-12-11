extends Control
## Converts touch events into ui_accept events which can be handled by the ChatUi.

export (NodePath) var chat_frame_path: NodePath
export (NodePath) var narration_frame_path: NodePath

## index of the current touch event, or -1 if there is none
var _touch_index := -1

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
	
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)


func _process(_delta: float) -> void:
	if _touch_index != -1:
		# emit an echo event
		_emit_ui_accept_event(true, true)


## Translates the current touch event into a ui_accept event.
func _emit_ui_accept_event(pressed: bool, echo: bool) -> void:
	var ev := InputEventKey.new()
	ev.scancode = _ui_accept_scancode
	ev.pressed = pressed
	ev.echo = echo
	Input.parse_input_event(ev)


## Temporarily disables touch translation.
##
## This is done when showing chat choices, or when the chat window is not being shown.
func _disable_translation() -> void:
	if _touch_index != -1:
		_emit_ui_accept_event(false, false)
		_touch_index = -1
	set_process(false)


## Reenables touch translation.
##
## Touch translation is reenabled during a brief delay to prevent a bug where a touch event is immediately processed,
## causing all text to appear.
func _enable_translation() -> void:
	call_deferred("set_process", true)


## Emits press/release events based on a multi-touch press/release.
func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and _touch_index == -1 and not _showing_choices:
		# emit a press event
		_touch_index = event.index
		get_tree().set_input_as_handled()
		_emit_ui_accept_event(true, false)
	
	if not event.pressed and _touch_index == event.index:
		# emit a release event
		_touch_index = -1
		get_tree().set_input_as_handled()
		_emit_ui_accept_event(false, false)


func _on_ChatUi_popped_in() -> void:
	_enable_translation()


func _on_ChatUi_showed_choices() -> void:
	_disable_translation()


func _on_ChatChoices_chat_choice_chosen(_choice_index: int) -> void:
	_enable_translation()


func _on_ChatUi_chat_finished() -> void:
	_disable_translation()
