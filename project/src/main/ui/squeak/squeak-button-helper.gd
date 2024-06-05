extends Node
## UI corrections for Buttons using the Squeak theme.
##
## Godot's button UI shows focus by drawing a texture over top of a button. This does not work for Squeak buttons
## because they change shape. This script dynamically swaps in different colors, textures and shapes.

## Texture to use for the button's normal state when focused.
export (StyleBoxTexture) var _normal_focus: StyleBoxTexture

## Texture to use for the button's pressed state when focused.
export (StyleBoxTexture) var _pressed_focus: StyleBoxTexture

onready var _parent: BaseButton = get_parent()

func _ready() -> void:
	_parent.connect("focus_entered", self, "_on_focus_entered")
	_parent.connect("focus_exited", self, "_on_focus_exited")


func _on_focus_entered() -> void:
	_parent.set("custom_styles/hover", _normal_focus)
	_parent.set("custom_styles/normal", _normal_focus)
	_parent.set("custom_styles/pressed", _pressed_focus)


func _on_focus_exited() -> void:
	_parent.set("custom_styles/hover", null)
	_parent.set("custom_styles/normal", null)
	_parent.set("custom_styles/pressed", null)
