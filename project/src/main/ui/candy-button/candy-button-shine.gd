extends TextureRect

## Bright shiny reflection texture which overlays the button and text when the button is not pressed.
export (Texture) var texture_normal: Texture setget set_texture_normal

## Less shiny reflection texture which overlays the button and text when the button is pressed.
export (Texture) var texture_pressed: Texture setget set_texture_pressed

onready var _button := get_parent()

func _ready() -> void:
	_button.connect("button_down", self, "_on_Button_button_down")
	_button.connect("button_up", self, "_on_Button_button_up")
	_button.connect("toggled", self, "_on_Button_toggled")
	_refresh_shine()


func set_texture_normal(new_texture_normal: Texture) -> void:
	texture_normal = new_texture_normal
	_refresh_shine()


func set_texture_pressed(new_texture_pressed: Texture) -> void:
	texture_pressed = new_texture_pressed
	_refresh_shine()


func _refresh_shine() -> void:
	if not is_inside_tree():
		return
	
	texture = texture_pressed if _button.pressed else texture_normal


func _on_Button_button_down() -> void:
	texture = texture_pressed


func _on_Button_button_up() -> void:
	texture = texture_normal


func _on_Button_toggled(_button_pressed: bool) -> void:
	_refresh_shine()
