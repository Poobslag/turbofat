extends Control
## UI control for enabling line pieces to all levels

onready var _check_box := $CheckBox

func _ready() -> void:
	SystemData.gameplay_settings.connect("hold_piece_changed", self, "_on_GameplaySettings_hold_piece_changed")
	_refresh()


func _refresh() -> void:
	_check_box.pressed = SystemData.gameplay_settings.hold_piece


func _on_OptionButton_toggled(_button_pressed: bool) -> void:
	SystemData.gameplay_settings.hold_piece = _check_box.pressed


func _on_GameplaySettings_hold_piece_changed(_value: bool) -> void:
	_refresh()
