extends Node
## Demonstrates the horizontal strip of level buttons which the player can scroll through.
##
## Radio buttons light up when signals are fired, to facilitate signal testing. Other buttons are shown to test how
## the keyboard/gamepad moves focus to and from the scroller.

onready var _changed_button: CheckButton = $VBoxContainer/ChangedCheckButton
onready var _changed_timer: Timer = $VBoxContainer/ChangedCheckButton/Timer
onready var _pressed_button: CheckButton = $VBoxContainer/PressedCheckButton
onready var _pressed_timer: Timer = $VBoxContainer/PressedCheckButton/Timer
onready var _scroller: LevelButtonScroller = $VBoxContainer/LevelButtonScroller

func _ready() -> void:
	var region: CareerRegion = CareerLevelLibrary.regions[0]
	_scroller.populate(region)
	
	$VBoxContainer/Button.grab_focus()


func _on_ChangedCheckButton_pressed() -> void:
	if _changed_button.pressed:
		_changed_timer.start()


func _on_ChangedTimer_timeout() -> void:
	_changed_button.pressed = false


func _on_PressedCheckButton_pressed() -> void:
	if _pressed_button.pressed:
		_pressed_timer.start()


func _on_PressedTimer_timeout() -> void:
	_pressed_button.pressed = false


func _on_LevelButtonScroller_central_button_changed() -> void:
	_changed_button.pressed = true
	_changed_timer.start()


func _on_LevelButtonScroller_central_button_pressed() -> void:
	_pressed_button.pressed = true
	_pressed_timer.start()
