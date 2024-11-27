#tool #uncomment to view creature in editor
class_name CreatureSfx
extends Node2D
## Plays creature-related sound effects.

signal should_play_sfx_changed

## sounds the creatures make when they enter the restaurant
const HELLO_VOICES := [
	preload("res://assets/main/world/creature/hello-voice-0.wav"),
	preload("res://assets/main/world/creature/hello-voice-1.wav"),
	preload("res://assets/main/world/creature/hello-voice-2.wav"),
	preload("res://assets/main/world/creature/hello-voice-3.wav"),
]

## sounds which get played when the creature eats
const CHEW_SOUNDS := [
	preload("res://assets/main/world/creature/chew0.wav"),
	preload("res://assets/main/world/creature/chew1.wav"),
	preload("res://assets/main/world/creature/chew2.wav"),
	preload("res://assets/main/world/creature/chew3.wav"),
	preload("res://assets/main/world/creature/chew4.wav"),
]

## sounds which get played when the creature eats if 'chewing sounds' are disabled
const CHEW_ALT_SOUNDS := [
	preload("res://assets/main/world/creature/chew-alt.wav"),
]

## satisfied sounds the creatures make when a player builds a big combo
const COMBO_VOICES := [
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

## sounds the creatures make when they ask for their check
const GOODBYE_VOICES := [
	preload("res://assets/main/world/creature/goodbye-voice-0.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-1.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-2.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-3.wav"),
]

## The duration in seconds for 'alternate chewing sounds' to return to their normal pitch.
const CHEW_ALT_SFX_RESET_DURATION := 2.500

## 'true' if the creature should not make any sounds when walking/loading. Used for the creature editor.
var suppress_sfx := false setget set_suppress_sfx

var should_play_sfx := false

## index of the most recent combo sound that was played
var _combo_voice_index := 0

## system clock for most recent munch sound that was played
var _prev_munch_msec := 0.0

## AudioStreamPlayer which plays all of the creature's voices. We reuse the same player so that they can't say two
## things at once.
onready var _voice_player := $VoicePlayer

onready var _munch_sound := $MunchSound
onready var _hop_sound := $HopSound
onready var _bonk_sound := $BonkSound

onready var _suppress_sfx_timer := $SuppressSfxTimer

func _ready() -> void:
	_refresh_should_play_sfx()


## Plays a 'mmm!' voice sample for when a player builds a big combo.
func play_combo_voice() -> void:
	if not should_play_sfx:
		return
	
	_combo_voice_index = (_combo_voice_index + 1 + randi() % (COMBO_VOICES.size() - 1)) % COMBO_VOICES.size()
	_voice_player.stream = COMBO_VOICES[_combo_voice_index]
	_voice_player.play()


## Plays a 'hello!' voice sample for when a creature enters the restaurant.
func play_hello_voice() -> void:
	if not should_play_sfx:
		return
	
	_voice_player.stream = Utils.rand_value(HELLO_VOICES)
	_voice_player.play()


## Plays a 'check please!' voice sample for when a creature is ready to leave.
func play_goodbye_voice() -> void:
	if not should_play_sfx:
		return
	
	_voice_player.stream = Utils.rand_value(GOODBYE_VOICES)
	_voice_player.play()


func play_bonk_sound() -> void:
	if not should_play_sfx:
		return
	
	_bonk_sound.play()


func play_hop_sound() -> void:
	if not should_play_sfx:
		return
	
	_hop_sound.play()


## Temporarily suppresses creature-related sound effects.
##
## This includes voices, eating sounds, and movement sound effects emitted by the CreatureSfx class.
##
## Other creature-related nodes can monitor the 'should_play_sfx' property to mute their own sound effects as well, to
## mute sounds made while emoting for example.
func briefly_suppress_sfx(duration: float = 1.0) -> void:
	if not _suppress_sfx_timer.is_stopped() and _suppress_sfx_timer.wait_time > duration:
		# sfx are already suppressed for a longer duration; let the timer run
		return
	
	_suppress_sfx_timer.start(duration)
	_refresh_should_play_sfx()


func set_suppress_sfx(new_suppress_sfx: bool) -> void:
	suppress_sfx = new_suppress_sfx
	_refresh_should_play_sfx()


func _refresh_should_play_sfx() -> void:
	if not is_inside_tree():
		return
	
	var old_should_play_sfx := should_play_sfx
	
	if Engine.editor_hint:
		# Skip the sound effects if we're using this as an editor tool
		should_play_sfx = false
	elif not _suppress_sfx_timer.is_stopped():
		# Skip the sound effects temporarily, such as during the first few seconds of a level
		should_play_sfx = false
	elif suppress_sfx:
		# Skip the sound effects permanently, for creatures that should never make noise
		should_play_sfx = false
	else:
		should_play_sfx = true
	
	if should_play_sfx != old_should_play_sfx:
		emit_signal("should_play_sfx_changed")


## Use a different AudioStreamPlayer for munch sounds, to avoid interrupting speech.
##
## Of course in real life you can't talk with your mouth full -- but combo sounds are positive feedback, so it's nice
## to avoid interrupting them.
func _on_Creature_food_eaten(_food_type: int) -> void:
	if not should_play_sfx:
		return
	
	if SystemData.volume_settings.chewing_sounds:
		# play a random chewing sound with random variance
		_munch_sound.volume_db = 0.0
		_munch_sound.stream = Utils.rand_value(CHEW_SOUNDS)
		_munch_sound.pitch_scale = rand_range(0.96, 1.04)
	else:
		# play an alternate 'pop!' sound which escalates in pitch
		_munch_sound.volume_db = -6.0

		# decrease the pitch if it hasn't been played recently
		var decrease_amount := clamp((Time.get_ticks_msec() - _prev_munch_msec) \
				/ (1000 * CHEW_ALT_SFX_RESET_DURATION), 0.0, 1.0)
		_munch_sound.pitch_scale = lerp(_munch_sound.pitch_scale, rand_range(0.66, 0.72), decrease_amount)

		# increase the pitch a random amount
		_munch_sound.pitch_scale = lerp(_munch_sound.pitch_scale, 2.0, rand_range(0.04, 0.12))

		_munch_sound.stream = Utils.rand_value(CHEW_ALT_SOUNDS)

		_prev_munch_msec = Time.get_ticks_msec()
	_munch_sound.play()


func _on_Creature_landed() -> void:
	play_hop_sound()


func _on_SuppressSfxTimer_timeout() -> void:
	_refresh_should_play_sfx()
