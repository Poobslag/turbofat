extends Node
## UI corrections for OptionButtons using the Squeak theme.
##
## Godot's button UI shows focus by drawing a texture over top of a button. This does not work for Squeak option
## buttons because they change shape. This script dynamically swaps in different colors, textures and shapes.

## Texture to use for the button's normal state when focused.
export (StyleBoxTexture) var _normal_focus: StyleBoxTexture

## Texture to use for the button's pressed state when focused.
export (StyleBoxTexture) var _pressed_focus: StyleBoxTexture

## Texture to use for the arrow icon when the button is in the normal state when focused.
##
## Workaround for Godot #47769 (https://github.com/godotengine/godot/issues/47769)
## Because Godot does not apply the OptionButton Font Color to OptionButton arrows, we need to manually reassign
## differently colored textures.
export (Texture) var _arrow_normal_focus: Texture

## Texture to use for the arrow icon when the button is in the pressed state.
export (Texture) var _arrow_pressed: Texture

## 'true' if the mouse is hovering over the button
var _hovered := false

onready var _parent: BaseButton = get_parent()

func _ready() -> void:
	_parent.connect("focus_entered", self, "_on_focus_entered")
	_parent.connect("focus_exited", self, "_on_focus_exited")
	_parent.connect("button_down", self, "_on_button_down")
	_parent.connect("button_up", self, "_on_button_up")
	_parent.connect("mouse_entered", self, "_on_mouse_entered")
	_parent.connect("mouse_exited", self, "_on_mouse_exited")
	_parent.get_popup().connect("about_to_show", self, "_on_Popup_about_to_show")
	_parent.get_popup().connect("popup_hide", self, "_on_Popup_popup_hide")


## Refreshes the button's textures and style boxes based on the button's state.
func _refresh_styles() -> void:
	if _parent.has_focus():
		# swap in brightly-colored focus textures
		_parent.set("custom_icons/arrow", _arrow_pressed if _parent.pressed else _arrow_normal_focus)
		_parent.set("custom_styles/hover", _normal_focus)
		_parent.set("custom_styles/normal", _normal_focus)
		_parent.set("custom_styles/pressed", _pressed_focus)
	elif _hovered:
		# swap in a brightly-colored arrow texture to match the font
		_parent.set("custom_icons/arrow", _arrow_pressed if _parent.pressed else _arrow_normal_focus)
		_parent.set("custom_styles/hover", null)
		_parent.set("custom_styles/normal", null)
		_parent.set("custom_styles/pressed", null)
	else:
		# revert to dim-colored fonts and textures
		_parent.set("custom_icons/arrow", _arrow_pressed if _parent.pressed else null)
		_parent.set("custom_styles/hover", null)
		_parent.set("custom_styles/normal", null)
		_parent.set("custom_styles/pressed", null)


func _on_Popup_about_to_show() -> void:
	_refresh_styles()


func _on_Popup_popup_hide() -> void:
	_refresh_styles()


func _on_focus_entered() -> void:
	_refresh_styles()


func _on_focus_exited() -> void:
	_refresh_styles()


func _on_button_down() -> void:
	_refresh_styles()


func _on_button_up() -> void:
	_refresh_styles()


func _on_mouse_entered() -> void:
	_hovered = true
	_refresh_styles()


func _on_mouse_exited() -> void:
	_hovered = false
	_refresh_styles()
