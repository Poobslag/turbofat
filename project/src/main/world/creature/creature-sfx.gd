class_name CreatureSfx
extends Node2D
## Plays creature-related sound effects.

## sounds the creatures make when they enter the restaurant
onready var hello_voices := [
	preload("res://assets/main/world/creature/hello-voice-0.wav"),
	preload("res://assets/main/world/creature/hello-voice-1.wav"),
	preload("res://assets/main/world/creature/hello-voice-2.wav"),
	preload("res://assets/main/world/creature/hello-voice-3.wav"),
]

## sounds which get played when the creature eats
onready var _munch_sounds := [
	preload("res://assets/main/world/creature/munch0.wav"),
	preload("res://assets/main/world/creature/munch1.wav"),
	preload("res://assets/main/world/creature/munch2.wav"),
	preload("res://assets/main/world/creature/munch3.wav"),
	preload("res://assets/main/world/creature/munch4.wav"),
]

## satisfied sounds the creatures make when a player builds a big combo
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

## sounds the creatures make when they ask for their check
onready var _goodbye_voices := [
	preload("res://assets/main/world/creature/goodbye-voice-0.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-1.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-2.wav"),
	preload("res://assets/main/world/creature/goodbye-voice-3.wav"),
]

## index of the most recent combo sound that was played
var _combo_voice_index := 0

## 'true' if the creature should not make any sounds when walking/loading. Used for the creature editor.
var suppress_sfx := false

var creature_visuals: CreatureVisuals setget set_creature_visuals

## AudioStreamPlayer which plays all of the creature's voices. We reuse the same player so that they can't say two
## things at once.
onready var _voice_player := $VoicePlayer

onready var _munch_sound := $MunchSound
onready var _hop_sound := $HopSound
onready var _bonk_sound := $BonkSound

onready var _hello_timer := $HelloTimer
onready var _suppress_sfx_timer := $SuppressSfxTimer

func _ready() -> void:
	_connect_creature_visuals_listeners()


func set_creature_visuals(new_creature_visuals: CreatureVisuals) -> void:
	if creature_visuals:
		creature_visuals.disconnect("dna_loaded", self, "_on_CreatureVisuals_dna_loaded")
		creature_visuals.disconnect("food_eaten", self, "_on_CreatureVisuals_food_eaten")
		creature_visuals.disconnect("landed", self, "_on_CreatureVisuals_landed")
	creature_visuals = new_creature_visuals
	_connect_creature_visuals_listeners()


## Plays a 'mmm!' voice sample, for when a player builds a big combo.
func play_combo_voice() -> void:
	if suppress_sfx:
		return
	
	_combo_voice_index = (_combo_voice_index + 1 + randi() % (_combo_voices.size() - 1)) % _combo_voices.size()
	_voice_player.stream = _combo_voices[_combo_voice_index]
	_voice_player.play()


## Plays a 'hello!' voice sample, for when a creature enters the restaurant
func play_hello_voice(force: bool = false) -> void:
	if suppress_sfx:
		return
	
	if Global.should_chat() or force:
		_voice_player.stream = Utils.rand_value(hello_voices)
		_voice_player.play()


## Plays a 'check please!' voice sample, for when a creature is ready to leave
func play_goodbye_voice(force: bool = false) -> void:
	if suppress_sfx:
		return
	
	if Global.should_chat() or force:
		_voice_player.stream = Utils.rand_value(_goodbye_voices)
		_voice_player.play()


func play_bonk_sound() -> void:
	if suppress_sfx:
		return
	
	_bonk_sound.play()


func play_hop_sound() -> void:
	if suppress_sfx:
		return
	
	_hop_sound.play()


func start_suppress_sfx_timer() -> void:
	_suppress_sfx_timer.start(1.0)


func _connect_creature_visuals_listeners() -> void:
	if not creature_visuals:
		return
	
	creature_visuals.connect("dna_loaded", self, "_on_CreatureVisuals_dna_loaded")
	creature_visuals.connect("food_eaten", self, "_on_CreatureVisuals_food_eaten")
	creature_visuals.connect("landed", self, "_on_CreatureVisuals_landed")


## Use a different AudioStreamPlayer for munch sounds, to avoid interrupting speech.
##
## Of course in real life you can't talk with your mouth full -- but combo sounds are positive feedback, so it's nice
## to avoid interrupting them.
func _on_CreatureVisuals_food_eaten(_food_type: int) -> void:
	if suppress_sfx:
		return
	
	_munch_sound.stream = Utils.rand_value(_munch_sounds)
	_munch_sound.pitch_scale = rand_range(0.96, 1.04)
	_munch_sound.play()


func _on_CreatureVisuals_dna_loaded() -> void:
	if Engine.is_editor_hint():
		# Skip the sound effects if we're using this as an editor tool
		return
	if not _suppress_sfx_timer.is_stopped():
		# suppress greeting for first few seconds of a level
		return
	if suppress_sfx:
		return
	
	_hello_timer.start()


func _on_HelloTimer_timeout() -> void:
	play_hello_voice()


func _on_CreatureVisuals_landed() -> void:
	play_hop_sound()
