class_name SharkSfx
extends Node
## Sound effects for sharks, puzzle critters which eat pieces.

## The pitch scale to apply to most shark noises. Smaller sharks make higher pitched noises.
var pitch_scale := 1.00

## The duration in seconds the shark takes to eat.
var eat_duration := Shark.DEFAULT_EAT_DURATION

## Friendly sounds the shark makes when it finishes eating.
onready var _voice_friendly_sounds := [
		preload("res://assets/main/puzzle/critter/shark-voice-friendly-0.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-friendly-1.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-friendly-2.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-friendly-3.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-friendly-4.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-friendly-5.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-friendly-6.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-friendly-7.wav"),
	]

## Brief sounds the shark makes when it is squished.
onready var _voice_short_sounds := [
		preload("res://assets/main/puzzle/critter/shark-voice-short-0.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-short-1.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-short-2.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-short-3.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-short-4.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-short-5.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-short-6.wav"),
		preload("res://assets/main/puzzle/critter/shark-voice-short-7.wav"),
	]

## Tweens properties of the eating sound as it plays.
##
## The eating sound is a long, sustained sound which is played for an arbitrary duration. We tween its pitch so that
## it ends less abruptly.
onready var _eat_tween: Tween = $EatTween

onready var _bite := $Bite
onready var _eat := $Eat
onready var _poof := $Poof
onready var _squish := $Squish
onready var _voice_friendly := $VoiceFriendly
onready var _voice_short := $VoiceShort

func play_poof_sound() -> void:
	_poof.pitch_scale = rand_range(0.95, 1.05)
	SfxDeconflicter.play(_poof)


func play_voice_friendly_sound() -> void:
	_voice_friendly.stream = Utils.rand_value(_voice_friendly_sounds)
	_voice_friendly.pitch_scale = rand_range(pitch_scale * 0.9, pitch_scale * 1.1)
	SfxDeconflicter.play(_voice_friendly)


func play_voice_short_sound() -> void:
	_voice_short.stream = Utils.rand_value(_voice_short_sounds)
	_voice_short.pitch_scale = rand_range(pitch_scale * 0.9, pitch_scale * 1.1)
	SfxDeconflicter.play(_voice_short)


## Plays a sustained eating sound, like a grinding saw.
func play_eat_sound() -> void:
	var pitch_scale_start := rand_range(pitch_scale * 0.9, pitch_scale * 1.1)
	var pitch_scale_end := pitch_scale_start * 0.75
	
	_eat_tween.remove(_eat, "pitch_scale")
	_eat_tween.interpolate_property(_eat, "pitch_scale",
			pitch_scale_start, pitch_scale_end, eat_duration,
			Tween.TRANS_CIRC, Tween.EASE_IN)
	_eat_tween.start()
	
	SfxDeconflicter.play(_eat, rand_range(0.0, 0.2))


## Plays a brief eating sound, like a cartoony "chomp" noise.
func play_bite_sound() -> void:
	_bite.pitch_scale = rand_range(pitch_scale * 0.95, pitch_scale * 1.05)
	SfxDeconflicter.play(_bite)


func stop_eat_sound() -> void:
	_eat.stop()


func play_squish_sound() -> void:
	SfxDeconflicter.play(_squish)
