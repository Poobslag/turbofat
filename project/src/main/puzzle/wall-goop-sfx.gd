extends Node
## Plays sound effects when metaballs bounce off of the environment.
##
## Plays loud sound effects when metaballs hit the wall, and quieter sound effects when they smear against the
## background.

const SPLAT_SFX := [
	preload("res://assets/main/puzzle/goop-splat0.wav"),
	preload("res://assets/main/puzzle/goop-splat1.wav"),
	preload("res://assets/main/puzzle/goop-splat2.wav"),
	preload("res://assets/main/puzzle/goop-splat3.wav"),
	preload("res://assets/main/puzzle/goop-splat4.wav"),
	preload("res://assets/main/puzzle/goop-splat5.wav"),
]

## index of the next AudioStreamPlayer to use
var _splat_player_index := 0

## AudioStreamPlayers to use. We cycle between multiple players to handle concurrent sound effects
onready var _splat_players := [
	$SplatPlayer0,
	$SplatPlayer1,
	$SplatPlayer2,
]

## Play sound effects for a collision.
##
## Globs with a higher alpha component appear larger, and play louder sounds.
func _play_sfx(glob_alpha: float, max_volume: float) -> void:
	var player: AudioStreamPlayer = _splat_players[_splat_player_index]
	player.stream = Utils.rand_value(SPLAT_SFX)
	player.pitch_scale = rand_range(1.90, 2.10)
	player.volume_db = rand_range(max_volume, max_volume - 8.0)
	if glob_alpha < 0.7:
		player.pitch_scale += 0.5
		player.volume_db -= 6.0
	if glob_alpha < 0.4:
		player.pitch_scale += 0.5
		player.volume_db -= 6.0
	player.play()
	_splat_player_index = (_splat_player_index + 1) % _splat_players.size()


func _on_GoopGlobs_hit_wall(glob: GoopGlob) -> void:
	_play_sfx(glob.modulate.a, -10.0)


func _on_GoopGlobs_hit_playfield(glob: GoopGlob) -> void:
	_play_sfx(glob.modulate.a, -20.0)


func _on_GoopGlobs_hit_next_pieces(glob: GoopGlob) -> void:
	_play_sfx(glob.modulate.a, -20.0)
