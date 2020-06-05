extends Node
"""
Plays creature-related sound effects.
"""

# delays between when creature arrives and when door chime is played (in seconds)
const CHIME_DELAYS: Array = [0.2, 0.3, 0.5, 1.0, 1.5]

# sounds the creatures make when they enter the restaurant
onready var hello_voices := [$HelloVoice0, $HelloVoice1, $HelloVoice2, $HelloVoice3]

# sounds which get played when a creature shows up
onready var chime_sounds := [$DoorChime0, $DoorChime1, $DoorChime2, $DoorChime3, $DoorChime4]

# sounds which get played when the creature eats
onready var _munch_sounds := [$Munch0, $Munch1, $Munch2, $Munch3, $Munch4]

# satisfied sounds the creatures make when a player builds a big combo
onready var _combo_voices := [
	$ComboVoice00, $ComboVoice01, $ComboVoice02, $ComboVoice03,
	$ComboVoice04, $ComboVoice05, $ComboVoice06, $ComboVoice07,
	$ComboVoice08, $ComboVoice09, $ComboVoice10, $ComboVoice11,
	$ComboVoice12, $ComboVoice13, $ComboVoice14, $ComboVoice15,
	$ComboVoice16, $ComboVoice17, $ComboVoice18, $ComboVoice19,
]

# sounds the creatures make when they ask for their check
onready var _goodbye_voices := [$GoodbyeVoice0, $GoodbyeVoice1, $GoodbyeVoice2, $GoodbyeVoice3]

# we suppress the first door chime. we usually cheat and play the chime after the creature appears, but that doesn't
# work when we can see them appear
var _suppress_one_chime := true

# index of the most recent combo sound that was played
var _combo_voice_index := 0

# current voice stream player. we track this to prevent a creature from saying two things at once
var _current_voice_stream: AudioStreamPlayer2D

"""
Sets the relative position of sound effects related to the restaurant door. Each seat has a different position
relative to the restaurant's entrance; some are close to the door, some are far away.

Parameter: 'position' is the position of the door relative to this seat, in world coordinates.
"""
func set_door_sound_position(door_sound_position: Vector2) -> void:
	for chime_sound in chime_sounds:
		chime_sound.position = door_sound_position
	for hello_voice in hello_voices:
		hello_voice.position = door_sound_position


"""
Plays a 'mmm!' voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	_combo_voice_index = (_combo_voice_index + 1 + randi() % (_combo_voices.size() - 1)) % _combo_voices.size()
	_play_voice(_combo_voices[_combo_voice_index])


"""
Plays a 'hello!' voice sample, for when a creature enters the restaurant
"""
func play_hello_voice() -> void:
	if Global.should_chat():
		_play_voice(hello_voices[randi() % hello_voices.size()])


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice() -> void:
	if Global.should_chat():
		_play_voice(_goodbye_voices[randi() % _goodbye_voices.size()])


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
	chime_sounds[randi() % chime_sounds.size()].play()
	yield(get_tree().create_timer(0.5), "timeout")
	play_hello_voice()


"""
Plays a voice sample, interrupting any other voice samples which are currently playing for this specific creature.
"""
func _play_voice(audio_stream: AudioStreamPlayer2D) -> void:
	if _current_voice_stream and _current_voice_stream.playing:
		_current_voice_stream.stop()
	audio_stream.play()
	_current_voice_stream = _combo_voices[_combo_voice_index]


func _on_Creature_food_eaten() -> void:
	var munch_sound: AudioStreamPlayer2D = _munch_sounds[randi() % _munch_sounds.size()]
	munch_sound.pitch_scale = rand_range(0.96, 1.04)
	_play_voice(munch_sound)


func _on_Creature_creature_arrived() -> void:
	if Engine.is_editor_hint():
		# Skip the sound effects if we're using this as an editor tool
		pass
	else:
		if _suppress_one_chime:
			_suppress_one_chime = false
		else:
			play_door_chime()
