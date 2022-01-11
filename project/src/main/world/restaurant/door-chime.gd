extends AudioStreamPlayer2D
## Door chime which rings when a customer enters the restaurant.

## sounds which get played when a creature shows up
onready var _chime_sounds := [
	preload("res://assets/main/world/door-chime0.wav"),
	preload("res://assets/main/world/door-chime1.wav"),
	preload("res://assets/main/world/door-chime2.wav"),
	preload("res://assets/main/world/door-chime3.wav"),
	preload("res://assets/main/world/door-chime4.wav"),
]

onready var _suppress_sfx_timer := $SuppressSfxTimer
onready var _chime_timer := $ChimeTimer

func _ready() -> void:
	# suppress door chime at the start of a level
	briefly_suppress_sfx()


## Preemptively initialize onready variables to avoid null references.
func _enter_tree() -> void:
	_suppress_sfx_timer = $SuppressSfxTimer
	_chime_timer = $ChimeTimer


func play_door_chime() -> void:
	stream = Utils.rand_value(_chime_sounds)
	play()


## Temporarily suppresses door chime sounds.
func briefly_suppress_sfx(duration: float = 1.0) -> void:
	_suppress_sfx_timer.start(duration)
	if not _chime_timer.is_stopped():
		# cancel any queued chimes
		_chime_timer.stop()


func _on_CreatureVisuals_dna_loaded() -> void:
	if not _suppress_sfx_timer.is_stopped():
		return
	
	_chime_timer.start()


func _on_ChimeTimer_timeout() -> void:
	play_door_chime()
