extends Control
## Toaster popup which prompts the player to exit the credits

## Emitted after the player hits enter twice or escape once, signalling to exit the credits.
signal exit_pressed

enum PopupState {
	POPPED_OUT, # off the bottom of the screen
	POPPING_IN, # moving onscreen
	POPPED_IN, # onscreen
	POPPING_OUT # moving offscreen
}

const POPPED_OUT := PopupState.POPPED_OUT
const POPPING_IN := PopupState.POPPING_IN
const POPPED_IN := PopupState.POPPED_IN
const POPPING_OUT := PopupState.POPPING_OUT

## music panel's y coordinate when popped in and when popped out
const POP_IN_Y := 28
const POP_OUT_Y := 60

## how long it takes the popup to slide in or out of view
const TWEEN_DURATION := 0.2

## how many seconds to stay popped in
const LINGER_DURATION := 3.0

## monitors whether the popup is currently popping in or out
var _popup_state: int = PopupState.POPPED_OUT

var _tween: SceneTreeTween

onready var _panel := $Panel
onready var _label := $Panel/Label

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept", true):
		_handle_press_event()
		if _popup_state != POPPED_IN:
			_label.text = tr("Press again to exit")
	elif event.is_action_pressed("ui_click"):
		_handle_press_event()
		if _popup_state != POPPED_IN:
			_label.text = tr("Click again to exit")
	
	if event.is_action_pressed("ui_cancel", true):
		emit_signal("exit_pressed")


func _handle_press_event() -> void:
	match _popup_state:
		POPPING_OUT, POPPED_OUT:
			_pop_in()
		POPPED_IN:
			emit_signal("exit_pressed")
		POPPING_IN:
			# we ignore additional button presses until we're fully popped in, so that the player doesn't
			# accidentally mash through the credits
			pass


func _pop_in() -> void:
	# Calculate the tween duration.
	# This is usually TWEEN_DURATION, but can be shorter if the popup is partially popped in.
	var pop_in_amount := inverse_lerp(POP_OUT_Y, POP_IN_Y, _panel.rect_position.y)
	var tween_duration := TWEEN_DURATION * (1.0 - pop_in_amount)

	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_callback(self, "set", ["_popup_state", POPPING_IN])
	_tween.tween_property(_panel, "rect_position:y", POP_IN_Y, tween_duration)
	_tween.tween_callback(self, "set", ["_popup_state", POPPED_IN])
	
	# pop out after a few seconds
	_tween.tween_callback(self, "_pop_out").set_delay(LINGER_DURATION)


func _pop_out() -> void:
	# Calculate the tween duration.
	# This is usually TWEEN_DURATION, but can be shorter if the popup is partially popped in.
	var pop_in_amount := inverse_lerp(POP_OUT_Y, POP_IN_Y, _panel.rect_position.y)
	var tween_duration := TWEEN_DURATION * pop_in_amount

	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_callback(self, "set", ["_popup_state", POPPING_OUT])
	_tween.tween_property(_panel, "rect_position:y", POP_OUT_Y, tween_duration)
	_tween.tween_callback(self, "set", ["_popup_state", POPPED_OUT])
