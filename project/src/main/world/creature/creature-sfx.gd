class_name CreatureSfx
extends Node
"""
Plays creature-related sound effects.
"""

# sounds the creatures make when they enter the restaurant
onready var hello_voices := [
	preload("res://assets/main/world/creature/hello-voice-0.wav"),
	preload("res://assets/main/world/creature/hello-voice-1.wav"),
	preload("res://assets/main/world/creature/hello-voice-2.wav"),
	preload("res://assets/main/world/creature/hello-voice-3.wav"),
]

# sounds which get played when the creature eats
onready var _munch_sounds := [
	preload("res://assets/main/world/creature/munch0.wav"),
	preload("res://assets/main/world/creature/munch1.wav"),
	preload("res://assets/main/world/creature/munch2.wav"),
	preload("res://assets/main/world/creature/munch3.wav"),
	preload("res://assets/main/world/creature/munch4.wav"),
]

# satisfied sounds the creatures make when a player builds a big combo
onready var _combo_voices := [
	preload("res://assets/main/world/creature/combo-voice-00.wav"),
	preload("res://assets/main/world/creature/combo-voice-01.wav"),
	preload("res://assets/main/world/creature/combo-voice-02.wav"),
	preload("res://assets/main/world/creature/combo-voice-03.wav"),
	preload("res://assets/main/world/creature/combo-voice-04.wav"),
	preload("res://assets/main/world/creature/combo-voice-05.wav"),
	preload("res://assets/main/world/creature/combo-voice-06.wav"),
	preload("res://assets/main/world/creature/combo-voice-07.wav"),
	preload("res://assets/main/world/creature/combo-voice-08.wav"),
	preload("res://assets/main/world/creature/combo-voice-09.wav"),
	preload("res://assets/main/world/creature/combo-voice-10.wav"),
	preload("res://assets/main/world/creature/combo-voice-11.wav"),
	preload("res://assets/main/world/creature/combo-voice-12.wav"),
	preload("res://assets/main/world/creature/combo-voice-13.wav"),
	preload("res://assets/main/world/creature/combo-voice-14.wav"),
	preload("res://assets/main/world/creature/combo-voice-15.wav"),
	preload("res://assets/main/world/creature/combo-voice-16.wav"),
	preload("res://assets/main/world/creature/combo-voice-17.wav"),
	preload("res://assets/main/world/creature/combo-voice-18.wav"),
	preload("res://assets/main/world/creature/combo-voice-19.wav"),
]

# sounds the creatures make when they ask for their check
onready var _goodbye_voices := [
	preload("res://assets/main/world/creature/goodbye-voice-0.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-1.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-2.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-3.wav"),
]

# index of the most recent combo sound that was played
var _combo_voice_index := 0

# 'true' if the creature should not make any sounds when walking/loading. Used for the creature editor.
var suppress_sfx := false

"""
Plays a 'mmm!' voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	if suppress_sfx:
		return
	
	_combo_voice_index = (_combo_voice_index + 1 + randi() % (_combo_voices.size() - 1)) % _combo_voices.size()
	$Voice.stream = _combo_voices[_combo_voice_index]
	$Voice.play()


"""
Plays a 'hello!' voice sample, for when a creature enters the restaurant
"""
func play_hello_voice(force: bool = false) -> void:
	if suppress_sfx:
		return
	
	if Global.should_chat() or force:
		$Voice.stream = Utils.rand_value(hello_voices)
		$Voice.play()


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice(force: bool = false) -> void:
	if suppress_sfx:
		return
	
	if Global.should_chat() or force:
		$Voice.stream = Utils.rand_value(_goodbye_voices)
		$Voice.play()


func start_suppress_sfx_timer() -> void:
	$SuppressSfxTimer.start(1.0)


"""
Use a different AudioStreamPlayer for munch sounds, to avoid interrupting speech.

Of course in real life you can't talk with your mouth full -- but combo sounds are positive feedback, so it's nice to
avoid interrupting them.
"""
func _on_CreatureVisuals_food_eaten() -> void:
	if suppress_sfx:
		return
	
	$Munch.stream = Utils.rand_value(_munch_sounds)
	$Munch.pitch_scale = rand_range(0.96, 1.04)
	$Munch.play()


func _on_CreatureVisuals_dna_loaded() -> void:
	if Engine.is_editor_hint():
		# Skip the sound effects if we're using this as an editor tool
		return
	if not $SuppressSfxTimer.is_stopped():
		# suppress greeting for first few seconds of a level
		return
	if suppress_sfx:
		return
	
	$HelloTimer.start()


func _on_HelloTimer_timeout() -> void:
	play_hello_voice()
