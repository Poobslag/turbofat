tool
extends ConfirmationDialog
## Displays a confirmation with a warning icon.

## The text displayed by the dialog.
export (String, MULTILINE) var custom_text: String setget set_custom_text

## The color of the warning icon.
export (Color) var icon_color: Color setget set_icon_color

onready var _icon := $TextContainer/Icon
onready var _label := $TextContainer/Label

func _ready() -> void:
	_refresh_custom_text()
	_refresh_icon_color()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


func set_custom_text(new_custom_text: String) -> void:
	custom_text = new_custom_text
	_refresh_custom_text()


func set_icon_color(new_icon_color: Color) -> void:
	icon_color = new_icon_color
	_refresh_icon_color()


func _initialize_onready_variables() -> void:
	_icon = $TextContainer/Icon
	_label = $TextContainer/Label


func _refresh_custom_text() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			_initialize_onready_variables()
	
	_label.text = custom_text


func _refresh_icon_color() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			_initialize_onready_variables()
	
	_icon.modulate = icon_color
