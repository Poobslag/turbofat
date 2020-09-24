extends AudioStreamPlayer2D
"""
Door chime which rings when a customer enters the restaurant.
"""

# sounds which get played when a creature shows up
onready var _chime_sounds := [
	preload("res://assets/main/world/door-chime0.wav"),
	preload("res://assets/main/world/door-chime1.wav"),
	preload("res://assets/main/world/door-chime2.wav"),
	preload("res://assets/main/world/door-chime3.wav"),
	preload("res://assets/main/world/door-chime4.wav"),
]

func play_door_chime() -> void:
	stream = Utils.rand_value(_chime_sounds)
	play()


"""
Temporarily suppresses door chime sounds.
"""
func start_suppress_sfx_timer() -> void:
	$SuppressSfxTimer.start(1.0)


func _on_CreatureVisuals_dna_loaded() -> void:
	if not $SuppressSfxTimer.is_stopped():
		# suppress door chime at the start of a level
		return
	
	$ChimeTimer.start()


func _on_ChimeTimer_timeout() -> void:
	play_door_chime()
