extends Node
## Plays sound effects at the start and end of a level.

## sounds played at the start of a level
onready var _go_sound := $GoSound
onready var _go_voices := [$GoVoice0, $GoVoice1, $GoVoice2]
onready var _ready_sound := $ReadySound

## sounds played during tutorials
onready var _level_change_sound := $LevelChangeSound
onready var _section_complete_sound := $SectionCompleteSound
onready var _section_fail_sound := $SectionFailSound

## sounds played at the end of a level
onready var _excellent_sound := $ExcellentSound
onready var _game_over_sound := $GameOverSound
onready var _match_end_sound := $MatchEndSound

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("before_level_changed", self, "_on_PuzzleState_before_level_changed")
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")


func play_ready_sound() -> void:
	_ready_sound.play()


func play_go_sound() -> void:
	_go_sound.play()
	Utils.rand_value(_go_voices).play()


func _on_PuzzleState_game_prepared() -> void:
	if CurrentLevel.settings.other.skip_intro:
		# when skipping the intro, we don't play startup sounds
		return
	
	play_ready_sound()


func _on_PuzzleState_game_started() -> void:
	if CurrentLevel.settings.other.skip_intro:
		# when skipping the intro, we don't play startup sounds
		return
	
	play_go_sound()


func _on_PuzzleState_before_level_changed(new_level_id: String) -> void:
	if CurrentLevel.settings.other.non_interactive or not CurrentLevel.settings.input_replay.empty():
		# no sound effect or fanfare for non-interactive levels
		return
	
	if PuzzleState.level_performance.lost:
		_section_fail_sound.play()
	elif new_level_id == CurrentLevel.settings.id:
		# retrying a level; don't play any sfx
		pass
	else:
		_section_complete_sound.play()


func _on_PuzzleState_after_level_changed() -> void:
	_level_change_sound.play()


func _on_PuzzleState_game_ended() -> void:
	var sound: AudioStreamPlayer
	match PuzzleState.end_result():
		Levels.Result.LOST:
			sound = _game_over_sound
		Levels.Result.FINISHED:
			sound = _match_end_sound
		Levels.Result.WON:
			sound = _excellent_sound
	if sound:
		sound.play()
