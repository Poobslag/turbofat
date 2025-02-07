extends Node
## Generates echo events for a specific gamepad input.
##
## Most gamepad inputs should not generate echo events, but this script enables echoing for special cases like holding
## 'ui_accept' to advance cutscenes.

## A subclass of InputEventAction which is also an echo event.
class InputEventEcho extends InputEventAction:
	func is_echo() -> bool:
		return true

## Pressing and holding the button for this duration will continuously emit pseudo-echo events.
const ECHO_DURATION := 0.30

## The action which should generate echo events for gamepad inputs.
export (String) var action_name

## Timer which delays the first echo event until the specified duration (ECHO_DURATION).
onready var _delay_timer: Timer

func _ready() -> void:
	_initialize_delay_timer()
	set_process(false)


func _input(event: InputEvent) -> void:
	if not event is InputEventJoypadButton:
		return
	
	if event.is_action_released(action_name):
		# stop echoing events
		_delay_timer.stop()
		set_process(false)
	elif event.is_action_pressed(action_name):
		# echo events after a delay
		_delay_timer.start(ECHO_DURATION)


## Continuously generates echo input events while the button is held.
func _process(_delta: float) -> void:
	_parse_input_event_action(true)


## Generates a single input event and feeds it to the game.
func _parse_input_event_action(pressed: bool) -> void:
	var ev := InputEventEcho.new()
	ev.action = action_name
	ev.pressed = pressed
	Input.parse_input_event(ev)


func _initialize_delay_timer() -> void:
	_delay_timer = Timer.new()
	_delay_timer.connect("timeout", self, "_on_DelayTimer_timeout")
	_delay_timer.one_shot = true
	add_child(_delay_timer)


## When the delay timer times out, we start emitting echo events
func _on_DelayTimer_timeout() -> void:
	set_process(true)
