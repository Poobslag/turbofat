extends Node
"""
Plays creature-related sound effects.
"""

# delays between when creature arrives and when door chime is played (in seconds)
const CHIME_DELAYS: Array = [0.2, 0.3, 0.5, 1.0, 1.5]

# sounds the creatures make when they enter the restaurant
onready var hello_voices := [
	preload("res://assets/main/world/creature/hello-voice-0.wav"),
	preload("res://assets/main/world/creature/hello-voice-1.wav"),
	preload("res://assets/main/world/creature/hello-voice-2.wav"),
	preload("res://assets/main/world/creature/hello-voice-3.wav"),
]

# sounds which get played when a creature shows up
onready var _chime_sounds := [
	preload("res://assets/main/world/door-chime0.wav"),
	preload("res://assets/main/world/door-chime1.wav"),
	preload("res://assets/main/world/door-chime2.wav"),
	preload("res://assets/main/world/door-chime3.wav"),
	preload("res://assets/main/world/door-chime4.wav"),
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

# we suppress the first door chime. we usually cheat and play the chime after the creature appears, but that doesn't
# work when we can see them appear
var _suppress_one_chime := true

# index of the most recent combo sound that was played
var _combo_voice_index := 0

"""
Sets the relative position of sound effects related to the restaurant door. Each seat has a different position
relative to the restaurant's entrance; some are close to the door, some are far away.

Parameter: 'position' is the position of the door relative to this seat, in world coordinates.
"""
func set_door_sound_position(door_sound_position: Vector2) -> void:
	$DoorChime.position = door_sound_position


"""
Plays a 'mmm!' voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	_combo_voice_index = (_combo_voice_index + 1 + randi() % (_combo_voices.size() - 1)) % _combo_voices.size()
	$Voice.stream = _combo_voices[_combo_voice_index]
	$Voice.play()


"""
Plays a 'hello!' voice sample, for when a creature enters the restaurant
"""
func play_hello_voice() -> void:
	if Global.should_chat():
		$Voice.stream = hello_voices[randi() % hello_voices.size()]
		$Voice.play()


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice() -> void:
	if Global.should_chat():
		$Voice.stream = _goodbye_voices[randi() % _goodbye_voices.size()]
		$Voice.play()


"""
Plays a door chime sound effect, for when a creature enters the restaurant.

Parameter: 'delay' is the delay in seconds before the chime sound plays. The default value of '-1' results in a random
	delay.
"""
func play_door_chime(delay: float = -1) -> void:
	if Scenario.settings.other.tutorial:
		# suppress door chime for tutorials
		return
	
	if delay < 0:
		delay = CHIME_DELAYS[randi() % CHIME_DELAYS.size()]
	yield(get_tree().create_timer(delay), "timeout")
	
	if is_inside_tree():
		$DoorChime.stream = _chime_sounds[randi() % _chime_sounds.size()]
		$DoorChime.play()
		yield(get_tree().create_timer(0.5), "timeout")
	
	if is_inside_tree():
		play_hello_voice()


"""
Use a different AudioStreamPlayer for munch sounds, to avoid interrupting speech.

Of course in real life you can't talk with your mouth full -- but combo sounds are positive feedback, so it's nice to
avoid interrupting them.
"""
func _on_Creature_food_eaten() -> void:
	$Munch.stream = _munch_sounds[randi() % _munch_sounds.size()]
	$Munch.pitch_scale = rand_range(0.96, 1.04)
	$Munch.play()


func _on_Creature_creature_arrived() -> void:
	if Engine.is_editor_hint():
		# Skip the sound effects if we're using this as an editor tool
		pass
	else:
		if _suppress_one_chime:
			_suppress_one_chime = false
		else:
			play_door_chime()
