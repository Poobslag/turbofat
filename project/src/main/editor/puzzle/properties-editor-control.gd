class_name PropertiesEditorControl
extends Control
"""
UI control for editing level properties.
"""

# emitted when the user edits level property values using the UI.
signal properties_changed

onready var _button: Button = $Pickups/Button
onready var _line_edit: LineEdit = $Pickups/HBoxContainer1/LineEdit

func get_master_pickup_score() -> int:
	return int(_line_edit.text)


func set_master_pickup_score(new_master_pickup_score: int) -> void:
	_line_edit.text = str(new_master_pickup_score)


func _on_PickupsLineEdit_text_entered(new_text: String) -> void:
	emit_signal("properties_changed")
