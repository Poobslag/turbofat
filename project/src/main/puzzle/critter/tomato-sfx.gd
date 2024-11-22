class_name TomatoSfx
extends Node
## Sound effects for tomatoes, puzzle critters which indicate lines which can't be cleared.

onready var _poof := $Poof
onready var _voice := $Voice

func play_poof_sound() -> void:
	_poof.pitch_scale = rand_range(0.95, 1.05)
	_poof.play()


func play_voice() -> void:
	_voice.pitch_scale = rand_range(0.95, 1.05)
	_voice.play()
