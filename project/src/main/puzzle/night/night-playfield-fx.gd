class_name NightPlayfieldFx
extends Node2D
## Generates visual lighting effects for the playfield during night mode.
##
## These lighting effects are synchronized with the daytime lighting effects, and rendered over them.

## daytime playfield fx to synchronize with
var source_playfield_fx: PlayfieldFx

## lights which turn on and off
@onready var _light_map: TileMap = $LightMap

## glowy effect around the lights
@onready var _glow_map: TileMap = $GlowMap

## bright flash when the player clears a line
@onready var _bg_strobe: ColorRect = $BgStrobe

func _process(_delta: float) -> void:
	# synchronize our modulate property; playfield_fx adjusts its modulate property for a pulsing effect
	modulate.a = source_playfield_fx.modulate.a
	
	# synchronize light map
	_light_map.clear()
	for cell in source_playfield_fx.light_map.get_used_cells(0):
		_light_map.set_cell(0, cell, 0, Vector2.ZERO)
	_light_map.modulate.a = source_playfield_fx.light_map.modulate.a
	
	# synchronize glow map
	_glow_map.clear()
	for cell in source_playfield_fx.glow_map.get_used_cells(0):
		_glow_map.set_cell(0, cell, 0, Vector2.ZERO)
	_glow_map.modulate.a = source_playfield_fx.glow_map.modulate.a
	
	# synchronize strobe
	_bg_strobe.color.a = source_playfield_fx.bg_strobe.color.a
