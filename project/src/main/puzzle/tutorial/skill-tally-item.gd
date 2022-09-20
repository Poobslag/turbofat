class_name SkillTallyItem
extends ProgressBar
## Provides feedback during tutorials when the player performs an action, such as rotating a piece or clearing a line.

## if 'true' the skill tally will be shown as '58%' instead of '52/90'
export (bool) var show_as_percent: bool

## description of the skill being tallied such as 'Rotate Left'
export (String) var label_text: String setget set_label_text

## name of the signals this skill tally monitors
export (Array, String) var signal_names: Array

## puzzle to monitor for things such as moving the piece and clearing lines
var puzzle: Puzzle setget set_puzzle

var _playfield: Playfield
var _piece_manager: PieceManager

## When the player performs a skill enough times, the skill tally plays a noise and lights up more brightly. This
## property is 'true' if the skill tally is lit up brightly.
var _bright_tween_active: bool
var _tween: SceneTreeTween

onready var _blink_panel := $Blink
onready var _label := $Label
onready var _task_complete_sound := $TaskCompleteSound

func _ready() -> void:
	reset()
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")


func set_puzzle(new_puzzle: Puzzle) -> void:
	puzzle = new_puzzle
	_refresh_puzzle()


func set_label_text(new_label_text: String) -> void:
	label_text = new_label_text
	update_label()


func is_complete() -> bool:
	return value >= max_value


## Resets the skill tally to 0 when starting/restarting a tutorial.
func reset() -> void:
	value = 0
	update_label()


## When the player performs a skill we blink and increment our value.
func increment() -> void:
	if not is_visible_in_tree():
		return
	
	if value < max_value:
		value += 1
		if value == max_value:
			_blink(true)
		else:
			_blink()
	else:
		_blink()
	update_label()


func update_label() -> void:
	if not is_inside_tree():
		return
	
	if show_as_percent:
		_label.text = "%s\n%d%%" % [label_text, int(100 * value / max_value)]
	else:
		_label.text = "%s\n(%d/%d)" % [label_text, value, max_value]


## Initializes this node when the puzzle field is assigned.
##
## Connects the signals in 'signal_names' to the appropriate nodes.
func _refresh_puzzle() -> void:
	_playfield = puzzle.get_playfield()
	_piece_manager = puzzle.get_piece_manager()
	
	for signal_name in signal_names:
		match signal_name:
			"":
				pass
			"line_cleared":
				_playfield.connect(signal_name, self, "_on_Playfield_line_cleared")
			"box_built":
				_playfield.connect(signal_name, self, "_on_Playfield_box_built")
			"squish_moved":
				_piece_manager.connect(signal_name, self, "_on_PieceManager_squish_moved")
			_:
				if signal_name in _get_signal_names(_piece_manager):
					_piece_manager.connect(signal_name, self, "_on_skill_performed")
				else:
					push_warning("Could not find sender for signal '%s'" % signal_name)


## Blinks the skill tally to catch the player's attention.
##
## Parameters:
## 	'bright': If true, the skill tally will blink very brightly and play a noise.
func _blink(bright: bool = false) -> void:
	if _bright_tween_active:
		return
	
	_tween = Utils.recreate_tween(self, _tween)
	_blink_panel.rect_scale = Vector2(1, 1)
	if bright:
		_bright_tween_active = true
		_blink_panel.modulate = Color.white
		_tween.tween_property(_blink_panel, "rect_scale", Vector2(2.0, 2.0), 1.2)
		_tween.parallel().tween_property(_blink_panel, "modulate", Color(0.111, 0.888, 0.111, 0.0), 1.2) \
				.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		$TaskCompleteSound.play()
	else:
		_blink_panel.modulate = Color(0.111, 0.888, 0.111, 0.5)
		_tween.tween_property(_blink_panel, "rect_scale", Vector2(1.5, 1.5), 0.6)
		_tween.parallel().tween_property(_blink_panel, "modulate:a", 0.0, 0.6) \
				.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	_tween.connect("finished", self, "_on_Tween_tween_all_completed")


func _on_PuzzleState_game_prepared() -> void:
	reset()


func _on_skill_performed(_piece: ActivePiece) -> void:
	increment()


func _on_PieceManager_squish_moved(_piece: ActivePiece, _old_pos: Vector2) -> void:
	increment()


func _on_Playfield_line_cleared(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	increment()


func _on_Playfield_box_built(_rect: Rect2, _box_type: int) -> void:
	increment()


func _on_Tween_tween_all_completed() -> void:
	_bright_tween_active = false


## Returns the signal names for a node.
static func _get_signal_names(object: Object) -> Dictionary:
	var result := {}
	for signal_dict in object.get_signal_list():
		result[signal_dict.name] = signal_dict.name
	return result
