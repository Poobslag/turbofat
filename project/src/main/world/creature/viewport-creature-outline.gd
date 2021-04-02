tool
extends CreatureOutline
"""
An implementation of CreatureOutline which is optimized for graphics quality.

This implementation utilizes a ViewportTexture to render an outline around the creature.
"""

# rendering of a creature with an outline shader applied
onready var _texture_rect := $TextureRect

func _ready() -> void:
	creature_visuals = $Viewport/Visuals
	_texture_rect.rect_scale = Vector2(Global.CREATURE_SCALE, Global.CREATURE_SCALE)
	creature_visuals.connect("dna_changed", self, "_on_CreatureVisuals_dna_changed")
	connect("elevation_changed", self, "_on_elevation_changed")


func _on_elevation_changed(_new_elevation: float) -> void:
	$TextureRect.rect_position.y = -366 - elevation * Global.CREATURE_SCALE


func _on_CreatureVisuals_dna_changed(dna: Dictionary) -> void:
	if dna.has("line_rgb"):
		_texture_rect.material.set_shader_param("black", Color(dna.line_rgb))
