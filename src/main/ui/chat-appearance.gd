class_name ChatAppearance
extends Node
"""
Stores metadata about the chat window's appearance.

This includes the position, color and texture of the main chat window and nametag.
"""

enum NametagSize {
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
var nametag_right: bool

"""
The chat window changes its appearance based on who's talking. For example, one character's speech might be blue with
a black background, and giant blue soccer balls in the background. The 'accent_def' parameter defines the chat
window's appearance, such as 'blue', 'soccer balls' and 'giant'.

'accent_def/accent_scale': The scale of the accent's background texture
'accent_def/accent_swapped': If 'true', the accent's foreground/background colors will be swapped
'accent_def/accent_texture': A number in the range [0, 15] referring to a background texture
'accent_def/color': The color of the chat window
'accent_def/dark': True/false for whether the sentence window's background should be black/white
'accent_def/nametag_right': True/false for whether the nametag should be shown on the right/left side
"""
func _init(accent_def: Dictionary):
	accent_color = accent_def["color"] if accent_def.has("color") else Color.gray
	accent_scale = accent_def["accent_scale"] if accent_def.has("accent_scale") else 2.0
	accent_swapped = accent_def["accent_swapped"] if accent_def.has("accent_swapped") else false
	border_color = accent_def["color"] if accent_def.has("color") else Color.gray
	dark = accent_def["dark"] if accent_def.has("dark") else false
	nametag_right = accent_def["nametag_right"] if accent_def.has("nametag_right") else false
	accent_texture_index = accent_def["accent_texture"] if accent_def.has("accent_texture") else 0
	
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
