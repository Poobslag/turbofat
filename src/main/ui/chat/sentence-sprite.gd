class_name SentenceSprite
extends Sprite
"""
Note: SentenceSprite does not contain its own sentence labels to avoid the labels being distorted as the sprite
	stretches and shrinks. It would make the text annoying to read.
"""

# The sprite squishes over time. These two constants define the speed and squish amount
const PULSE_PERIOD := 5.385
const PULSE_AMOUNT := Vector2(0.003, 0.006)

# The number of available background textures
const CHAT_TEXTURE_COUNT := 16

# The sprite squishes over time. This field is used to calculate the squish amount
var _total_time := 0.0

# Bigger chat windows are displayed using bigger textures
onready var _sentence_textures := {
	ChatAppearance.SENTENCE_SMALL: preload("res://assets/ui/chat/window-small-sheet.png"),
	ChatAppearance.SENTENCE_MEDIUM: preload("res://assets/ui/chat/window-medium-sheet.png"),
	ChatAppearance.SENTENCE_LARGE: preload("res://assets/ui/chat/window-large-sheet.png"),
	ChatAppearance.SENTENCE_XL: preload("res://assets/ui/chat/window-extra-large-sheet.png")
}

# Background textures which scroll behind the chat window
var _accent_textures := []

func _ready() -> void:
	for i in range(CHAT_TEXTURE_COUNT):
		var path := "res://assets/ui/chat/texture/bg%02d.png" % i
		_accent_textures.append(load(path))

func _process(delta: float) -> void:
	_total_time += delta
	
	# stretch the chat window vertically/horizontally in a circular way which preserves its area
	scale.x = 0.20 + PULSE_AMOUNT.x * sin((_total_time + 8.96) * TAU / PULSE_PERIOD)
	scale.y = 0.20 + PULSE_AMOUNT.y * cos((_total_time + 8.96) * TAU / PULSE_PERIOD)

"""
Recolors and repositions the sprite based on the current chat appearance.

Parameters:
	'sentence_size': The size of the sentence window. This is needed for the sprite to update its texture to show a
		smaller/larger window.
"""
func update_appearance(chat_appearance: ChatAppearance, sentence_size: int) -> void:
	frame = randi() % 4
	flip_h = randf() > 0.5
	flip_v = randf() > 0.5
	texture = _sentence_textures[sentence_size]

	material.set_shader_param("accent_amount", 0.40 if chat_appearance.dark else 0.24)
	material.set_shader_param("accent_color", chat_appearance.accent_color)
	material.set_shader_param("accent_flip", Vector2(-1.0 if flip_h else 1.0, -1.0 if flip_v else 1.0));
	material.set_shader_param("accent_scale", chat_appearance.accent_scale)
	material.set_shader_param("accent_swapped", chat_appearance.accent_swapped)
	material.set_shader_param("accent_texture", _accent_textures[chat_appearance.accent_texture_index])
	material.set_shader_param("border_color", chat_appearance.border_color)
	material.set_shader_param("center_color", Color.black if chat_appearance.dark else Color.white)
