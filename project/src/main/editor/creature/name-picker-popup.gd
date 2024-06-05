extends PopupPanel
## A popup which includes a LineEdit for entering the creature's name.

signal name_changed(name)

onready var _line_edit := $LineEdit

func _ready() -> void:
	$LineEdit.max_length = NameUtils.MAX_CREATURE_NAME_LENGTH


func set_selected_name(new_selected_name: String) -> void:
	_line_edit.text = new_selected_name


func _on_LineEdit_text_changed(new_text: String) -> void:
	if new_text == NameUtils.sanitize_name(new_text):
		emit_signal("name_changed", NameUtils.sanitize_name(_line_edit.text))


func _on_LineEdit_text_entered(_new_text: String) -> void:
	emit_signal("name_changed", NameUtils.sanitize_name(_line_edit.text))
	hide()


func _on_about_to_show() -> void:
	_line_edit.select_all()
	_line_edit.caret_position = _line_edit.text.length()
