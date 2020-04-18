extends Control
"""
Displays UI elements for having a conversation.

The chat window is decorated with objects in the background called 'accents'. These accents can be injected with the
set_accent_def function to configure the chat window's appearance.
"""

const PULSE_PERIOD = 5.385
const PULSE_AMOUNT = Vector2(0.006, 0.012)

var _total_time := 0.0

onready var _accent_textures := [
	preload("res://assets/ui/chat/texture/bg00.png"),
	preload("res://assets/ui/chat/texture/bg01.png"),
	preload("res://assets/ui/chat/texture/bg02.png"),
	preload("res://assets/ui/chat/texture/bg03.png"),
	preload("res://assets/ui/chat/texture/bg04.png"),
	preload("res://assets/ui/chat/texture/bg06.png"),
	preload("res://assets/ui/chat/texture/bg07.png"),
	preload("res://assets/ui/chat/texture/bg08.png"),
	preload("res://assets/ui/chat/texture/bg09.png"),
	preload("res://assets/ui/chat/texture/bg10.png"),
	preload("res://assets/ui/chat/texture/bg11.png"),
	preload("res://assets/ui/chat/texture/bg12.png"),
	preload("res://assets/ui/chat/texture/bg13.png"),
	preload("res://assets/ui/chat/texture/bg14.png"),
	preload("res://assets/ui/chat/texture/bg15.png")
]

func _process(delta: float) -> void:
	_total_time += delta
	
	# stretch the chat window vertically/horizontally in a circular way which preserves its area
	$Holder/ChatRect.rect_scale.x = 0.40 + PULSE_AMOUNT.x * sin((_total_time + 8.96) * 2 * PI / PULSE_PERIOD)
	$Holder/ChatRect.rect_scale.y = 0.40 + PULSE_AMOUNT.y * cos((_total_time + 8.96) * 2 * PI / PULSE_PERIOD)

"""
Animates the conversation UI to gradually reveal the specified text, mimicking speech.
"""
func play_text(text_with_pauses: String, accent_def: Dictionary) -> void:
	set_accent_def(accent_def)
	$Holder/ChatLabel.play_text(text_with_pauses)


"""
Configures the conversation window's appearance based on the 'accent_def' which is passed in.

The conversation window changes its appearance based on who's talking. For example, one character's speech might be
blue with a black background, and giant blue soccer balls in the background. The 'accent_def' parameter defines the
conversation window's appearance, such as 'blue', 'soccer balls' and 'giant'.

Parameters:
	'accent_def': Describes the colors and textures used to draw the conversation window
	
	'accent_def/color': The color of the chat window
	
	'accent_def/accent_swapped': If 'true', the accent's foreground/background colors will be swapped
	
	'accent_def/dark': If 'true' the background will be black instead of white
	
	'accent_def/accent_texture': A number in the range [0, 15] referring to a background texture
"""
func set_accent_def(accent_def: Dictionary) -> void:
	_apply_accent_colors(accent_def)
	_apply_accent_shapes(accent_def)


"""
Updates the chat window's accent shapes based on an accent definition.
"""
func _apply_accent_shapes(accent_def: Dictionary) -> void:
	var scale: float = accent_def["accent_scale"] if accent_def.has("accent_scale") else 2.0
	var texture_index: int = accent_def["accent_texture"] if accent_def.has("accent_texture") else 0
	texture_index = clamp(texture_index, 0, _accent_textures.size() - 1)
	
	$Holder/ChatRect.material.set_shader_param("accent_scale", scale)
	$Holder/ChatRect.material.set_shader_param("accent_texture", _accent_textures[texture_index])


"""
Recolors the chat windows, borders and fonts based on an accent definition.
"""
func _apply_accent_colors(accent_def: Dictionary) -> void:
	var color: Color = accent_def["color"] if accent_def.has("color") else Color.gray
	var swapped: bool = accent_def["accent_swapped"] if accent_def.has("accent_swapped") else false
	var dark: bool = accent_def["dark"] if accent_def.has("dark") else false
	
	var border_color := color
	var accent_color := color
	if (dark):
		# accent color is a darker version of the input color
		accent_color.v = lerp(accent_color.v, 0.33, 0.8)
		# border color is a lighter, more saturated version of the input color
		border_color.v = lerp(color.v, 0.78, 0.8)
		border_color.s = pow(border_color.s, 0.33)
	else:
		# border color is a darker version of the input color
		border_color.v = lerp(color.v, 0.22, 0.8)
		# accent color is a lighter, more saturated version of the input color
		accent_color.v = lerp(accent_color.v, 0.67, 0.8)
		accent_color.s = pow(accent_color.s, 0.22)
	
	$Holder/ChatLabel.set("custom_colors/font_color", border_color)
	$Holder/ChatRect.material.set_shader_param("border_color", border_color)
	$Holder/ChatRect.material.set_shader_param("accent_color", accent_color)
	$Holder/ChatRect.material.set_shader_param("center_color", Color.black if dark else Color.white)
	$Holder/ChatRect.material.set_shader_param("accent_amount", 0.40 if dark else 0.24)
	$Holder/ChatRect.material.set_shader_param("accent_swapped", swapped)
	$Holder/ChatRect/NametagRect.self_modulate = border_color
	$Holder/ChatRect/NametagRect/NametagLabel.set("custom_colors/font_color", Color.black if dark else Color.white)
