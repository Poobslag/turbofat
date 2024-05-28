extends Node
## UI corrections for CheckBoxes using the Squeak theme.
##
## Godot's checkbox UI shows focus by drawing a texture around a checkbox and its text. Squeak checkboxes show focus
## by brightening the check box itself. This script dynamically swaps in different colors and textures.

## Texture to use for the button's checked state when focused.
export (Texture) var _checked_focus: Texture

## Texture to use for the button's unchecked state when focused.
export (Texture) var _unchecked_focus: Texture

## Texture to use for the button's checked state when hovered.
export (Texture) var _checked_hover: Texture

## Texture to use for the button's unchecked state when hovered.
export (Texture) var _unchecked_hover: Texture

## Font color to use for the button's text when focused or hovered.
##
## Godot's checkbox UI expects a "pressed color", a special text color which is only used when the check box is
## checked. We don't want this behavior in our UI, so we manually override the font color.
export (Color) var _font_color_focus: Color

## 'true' if the mouse is hovering over the button
var _hovered := false

onready var _parent: BaseButton = get_parent()

func _ready() -> void:
	_parent.connect("focus_entered", self, "_on_focus_entered")
	_parent.connect("focus_exited", self, "_on_focus_exited")
	_parent.connect("mouse_entered", self, "_on_mouse_entered")
	_parent.connect("mouse_exited", self, "_on_mouse_exited")


func _refresh_styles() -> void:
	if _parent.has_focus():
		_parent.set("custom_icons/checked", _checked_focus)
		_parent.set("custom_icons/unchecked", _unchecked_focus)
		_parent.set("custom_colors/font_color_pressed", _font_color_focus)
	elif _hovered:
		_parent.set("custom_icons/checked", _checked_hover)
		_parent.set("custom_icons/unchecked", _unchecked_hover)
		_parent.set("custom_colors/font_color_pressed", _font_color_focus)
	else:
		_parent.set("custom_icons/checked", null)
		_parent.set("custom_icons/unchecked", null)
		_parent.set("custom_colors/font_color_pressed", null)


func _on_focus_entered() -> void:
	_refresh_styles()


func _on_focus_exited() -> void:
	_refresh_styles()


func _on_mouse_entered() -> void:
	_hovered = true
	_refresh_styles()


func _on_mouse_exited() -> void:
	_hovered = false
	_refresh_styles()
