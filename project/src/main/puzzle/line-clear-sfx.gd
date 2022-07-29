extends Node
## Plays sound effects when lines are cleared.

onready var _combo_sounds := [null, null, # no combo sfx for the first two lines
		preload("res://assets/main/puzzle/combo-00.wav"),
		preload("res://assets/main/puzzle/combo-01.wav"),
		preload("res://assets/main/puzzle/combo-02.wav"),
		preload("res://assets/main/puzzle/combo-03.wav"),
		preload("res://assets/main/puzzle/combo-04.wav"),
		preload("res://assets/main/puzzle/combo-05.wav"),
		preload("res://assets/main/puzzle/combo-06.wav"),
		preload("res://assets/main/puzzle/combo-07.wav"),
		preload("res://assets/main/puzzle/combo-08.wav"),
		preload("res://assets/main/puzzle/combo-09.wav"),
		preload("res://assets/main/puzzle/combo-10.wav"),
		preload("res://assets/main/puzzle/combo-11.wav"),
		preload("res://assets/main/puzzle/combo-12.wav"),
		preload("res://assets/main/puzzle/combo-13.wav"),
		preload("res://assets/main/puzzle/combo-14.wav"),
		preload("res://assets/main/puzzle/combo-15.wav"),
		preload("res://assets/main/puzzle/combo-16.wav"),
		preload("res://assets/main/puzzle/combo-17.wav"),
		preload("res://assets/main/puzzle/combo-18.wav"),
		preload("res://assets/main/puzzle/combo-19.wav"),
		preload("res://assets/main/puzzle/combo-20.wav"),
		preload("res://assets/main/puzzle/combo-21.wav"),
		preload("res://assets/main/puzzle/combo-22.wav"),
		preload("res://assets/main/puzzle/combo-23.wav"),
	]

onready var _combo_endless_sounds := [
		preload("res://assets/main/puzzle/combo-e00.wav"),
		preload("res://assets/main/puzzle/combo-e01.wav"),
		preload("res://assets/main/puzzle/combo-e02.wav"),
		preload("res://assets/main/puzzle/combo-e03.wav"),
		preload("res://assets/main/puzzle/combo-e04.wav"),
		preload("res://assets/main/puzzle/combo-e05.wav"),
		preload("res://assets/main/puzzle/combo-e06.wav"),
		preload("res://assets/main/puzzle/combo-e07.wav"),
		preload("res://assets/main/puzzle/combo-e08.wav"),
		preload("res://assets/main/puzzle/combo-e09.wav"),
		preload("res://assets/main/puzzle/combo-e10.wav"),
		preload("res://assets/main/puzzle/combo-e11.wav"),
	]

onready var _all_clear_sound := $AllClearSound
onready var _clear_cake_piece_sound := $ClearCakePieceSound
onready var _clear_snack_piece_sound := $ClearSnackPieceSound
onready var _combo_sound := $ComboSound
onready var _line_erase_sounds := [$LineEraseSound1, $LineEraseSound2, $LineEraseSound3]
onready var _veg_erase_sounds := [$VegEraseSound1, $VegEraseSound2, $VegEraseSound3]

func _play_thump_sound(_y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	var sound_index := clamp(total_lines - remaining_lines - 1, 0, _line_erase_sounds.size() - 1)
	var sound: AudioStreamPlayer
	if box_ints:
		sound = _line_erase_sounds[sound_index]
	else:
		sound = _veg_erase_sounds[sound_index]
	if sound:
		sound.pitch_scale = rand_range(0.90, 1.10)
		sound.play()


## Plays an escalating sound for the current combo.
##
## For smaller combos this goes through a list of sound effects with higher pitches. For larger combos this loops
## through a repeating list where the repetition is concealed using a shepard tone.
func _play_combo_sound(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	var sound: AudioStream
	if PuzzleState.combo <= 0:
		# lines were cleared from top out or another unusual case. don't play combo sounds
		pass
	elif PuzzleState.combo < _combo_sounds.size():
		sound = _combo_sounds[PuzzleState.combo - 1]
	else:
		sound = _combo_endless_sounds[(PuzzleState.combo - 1 - _combo_sounds.size()) % _combo_endless_sounds.size()]
	if sound:
		_combo_sound.stream = sound
		_combo_sound.play()


func _play_box_sound(_y: int, _total_lines: int, _remaining_lines: int, box_ints: Array) -> void:
	var sound: AudioStreamPlayer
	if PuzzleTileMap.has_cake_box(box_ints):
		sound = _clear_cake_piece_sound
	elif not box_ints.empty():
		sound = _clear_snack_piece_sound
	if sound: sound.play()


## Clearing a line results in three overlapping sounds:
## 	1. A 'thump' sound
## 	2. A 'ding' sound for continuing a combo
## 	3. A 'glorp' sound when clearing a snack/cake box
func _on_Playfield_before_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	_play_combo_sound(y, total_lines, remaining_lines, box_ints)
	_play_box_sound(y, total_lines, remaining_lines, box_ints)


func _on_Playfield_line_erased(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	_play_thump_sound(y, total_lines, remaining_lines, box_ints)


func _on_Playfield_all_lines_cleared() -> void:
	if MilestoneManager.is_met(CurrentLevel.settings.finish_condition):
		# message is not shown at the end of a level
		return
	
	_all_clear_sound.play()
