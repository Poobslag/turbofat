class_name ChatAppearance
extends Node
"""
Stores metadata about the chat window's appearance.

This includes the position, color and texture of the main chat window and nametag.
"""

enum NametagSize {
	OFF, # 0 characters
	SMALL, # 1-10 characters, approximately
	MEDIUM,  # 11-20 characters, approximately
	LARGE,  # 21-30 characters, approximately
	EXTRA_LARGE,  # 31-60 characters, approximately
	EXTRA_EXTRA_LARGE  # 61-90 characters, approximately
}

enum SentenceSize {
	SMALL, # 1-2 lines at 50% capacity
	MEDIUM, # 2 lines at 75% capacity
	LARGE, # 3 lines at 75% capacity
	EXTRA_LARGE # 3 lines at 100% capacity
}

var accent_color: Color
var accent_scale: float
var accent_swapped: bool
var accent_texture_index: int
var border_color: Color
var dark: bool

"""
Parses an accent_def into properties used by the chat UI.

See ChatEvent.accent_def for a full description of the accent_def properties.
"""
func _init(accent_def: Dictionary):
	accent_color = accent_def.get("color", Color.gray)
	accent_scale = accent_def.get("accent_scale", 2.0)
	accent_swapped = accent_def.get("accent_swapped", false)
	border_color = accent_def.get("color", Color.gray)
	dark = accent_def.get("dark", false)
	accent_texture_index = accent_def.get("accent_texture", 0)
	
	if dark:
		# accent color is a darker version of the input color
		accent_color.v = lerp(accent_color.v, 0.33, 0.8)
		# border color is a lighter, more saturated version of the input color
		border_color.v = lerp(border_color.v, 0.78, 0.8)
		border_color.s = pow(border_color.s, 0.33)
	else:
		# accent color is a lighter, more saturated version of the input color
		accent_color.v = lerp(accent_color.v, 0.67, 0.8)
		accent_color.s = pow(accent_color.s, 0.22)
		# border color is a darker version of the input color
		border_color.v = lerp(border_color.v, 0.22, 0.8)
