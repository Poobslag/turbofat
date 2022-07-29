extends Node
## Plays sound effects at the start and end of a puzzle.

onready var _go_sound := $GoSound
onready var _go_voices := [$GoVoice0, $GoVoice1, $GoVoice2]
onready var _ready_sound := $ReadySound

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


func _on_PuzzleState_before_level_changed(_new_level_id: String) -> void:
	if CurrentLevel.settings.other.non_interactive or not CurrentLevel.settings.input_replay.empty():
		# no sound effect or fanfare for non-interactive levels
		return
	
	if PuzzleState.level_performance.lost:
		$SectionFailSound.play()
	else:
		$SectionCompleteSound.play()


func _on_PuzzleState_after_level_changed() -> void:
	$LevelChangeSound.play()


func _on_PuzzleState_game_ended() -> void:
	var sound: AudioStreamPlayer
	match PuzzleState.end_result():
		Levels.Result.LOST:
			sound = $GameOverSound
		Levels.Result.FINISHED:
			sound = $MatchEndSound
		Levels.Result.WON:
			sound = $ExcellentSound
	if sound:
		sound.play()
