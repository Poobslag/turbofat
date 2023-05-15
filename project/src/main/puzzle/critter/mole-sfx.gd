class_name MoleSfx
extends Node
## Sound effects for moles, puzzle critters which dig up star seeds for the player.

## AudioStreamPlayers to use for dig sound effects. We cycle between multiple players to handle concurrent sounds
onready var _digs := [$Dig0, $Dig1]

onready var _found := $Found
onready var _poof := $Poof

## next dig sound effect to play
var _dig_index := 0

func play_poof_sound() -> void:
	_poof.pitch_scale = rand_range(0.95, 1.05)
	SfxDeconflicter.play(_poof)


func play_dig_sound() -> void:
	var dig: AudioStreamPlayer = _digs[_dig_index]
	dig.volume_db = rand_range(0.0, -4.0)
	dig.pitch_scale = rand_range(0.95, 1.05)
	SfxDeconflicter.play(dig)
	_dig_index = (_dig_index + 1) % _digs.size()


func play_found_sound() -> void:
	_found.pitch_scale = rand_range(0.95, 1.05)
	SfxDeconflicter.play(_found)
