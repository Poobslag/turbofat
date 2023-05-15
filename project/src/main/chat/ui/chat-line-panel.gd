class_name ChatLinePanel
extends Panel
## Displays an empty frame around spoken dialog.
##
## Note: ChatLinePanel does not contain its own chat line labels to avoid the labels being distorted as the panel
## 	stretches and shrinks. It would make the text annoying to read.

## The panel squishes over time. These two constants define the speed and squish amount
const PULSE_PERIOD := 5.385
const PULSE_AMOUNT := Vector2(0.015, 0.030)

## Number of available background textures
const CHAT_TEXTURE_COUNT := 16

## Different panel sizes to try, ordered from smallest to largest.
export (Array, Vector2) var panel_sizes

## The panel squishes over time. This field is used to calculate the squish amount
var _total_time := 0.0

## Background textures which scroll behind the chat window
var _accent_textures := []

func _ready() -> void:
	for i in range(CHAT_TEXTURE_COUNT):
		var path := "res://assets/main/chat/ui/texture/bg%02d.png" % i
		_accent_textures.append(load(path))


func _process(delta: float) -> void:
	_total_time += delta
	
	# stretch the chat window vertically/horizontally in a circular way which preserves its area
	rect_scale.x = 1.00 + PULSE_AMOUNT.x * sin((_total_time + 8.96) * TAU / PULSE_PERIOD)
	rect_scale.y = 1.00 + PULSE_AMOUNT.y * cos((_total_time + 8.96) * TAU / PULSE_PERIOD)


## Recolors and repositions the panel based on the current chat appearance.
##
## Parameters:
## 	'chat_line_size': The size of the chat line window. This is needed for the panel to update its texture to show a
## 		smaller/larger window.
func update_appearance(chat_theme: ChatTheme, chat_line_size: int) -> void:
	rect_size = panel_sizes[chat_line_size]
	rect_pivot_offset = rect_size * 0.5
	rect_position = get_parent().rect_size / 2 - rect_size / 2
	
	material.set_shader_param("accent_amount", chat_theme.accent_amount)
	material.set_shader_param("accent_color", chat_theme.accent_color)
	material.set_shader_param("accent_scale", chat_theme.accent_scale)
	material.set_shader_param("accent_swapped", chat_theme.accent_swapped)
	material.set_shader_param("accent_texture", _accent_textures[chat_theme.accent_texture_index])
	material.set_shader_param("border_color", chat_theme.border_color)
	material.set_shader_param("center_color", Color.black if chat_theme.dark else Color.white)
