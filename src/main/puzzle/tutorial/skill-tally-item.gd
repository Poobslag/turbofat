extends ProgressBar
"""
Provides feedback to the player when they perform an action, such as rotating a piece or clearing a line.

This is used during tutorials so the player can see what to do.
"""

# if 'true' the skill tally will be shown as '58%' instead of '52/90'
export (bool) var show_as_percent: bool

# path of the Puzzle node to monitor
export (NodePath) var puzzle_path: NodePath

# description of the skill being tallied such as 'Rotate Left'
export (String) var label_text: String setget set_label_text

# name of the signals this skill tally monitors
export (Array, String) var signal_names: Array

onready var _puzzle: Puzzle = get_node(puzzle_path)
var _playfield: Playfield
var _piece_manager: PieceManager

# When the player performs a skill enough times, the skill tally plays a noise and lights up more brightly. This
# property is 'true' if the skill tally is lit up brightly.
var _bright_tween_active: bool

func _ready() -> void:
	if not Engine.is_editor_hint():
		_playfield = _puzzle.get_playfield()
		_piece_manager = _puzzle.get_piece_manager()
	reset()
	_connect_signals()


func set_label_text(new_label_text: String) -> void:
	label_text = new_label_text
	if is_inside_tree():
		_update_label()


"""
Resets the skill tally to 0 when starting/restarting a tutorial.
"""
func reset() -> void:
	value = 0
	_update_label()


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
	_update_label()


"""
Connects the signals in 'signal_names' to the appropriate puzzle nodes.
"""
func _connect_signals() -> void:
	if Engine.is_editor_hint():
		return
	
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	for signal_name in signal_names:
		if not signal_name:
			pass
		elif signal_name == "line_cleared":
			_playfield.connect("line_cleared", self, "_on_Playfield_line_cleared")
		elif signal_name == "box_made":
			_playfield.connect("box_made", self, "_on_Playfield_box_made")
		elif signal_name in _get_signal_names(_piece_manager):
			_piece_manager.connect(signal_name, self, "_on_skill_performed")
		else:
			push_error("Could not find sender for signal '%s'" % signal_name)


"""
Returns the signal names for a node.
"""
static func _get_signal_names(object: Object) -> Dictionary:
	var signal_names: Dictionary = {}
	for signal_dict in object.get_signal_list():
		signal_names[signal_dict.name] = signal_dict.name
	return signal_names


"""
Blinks the skill tally to catch the player's attention.

Parameters:
	'bright': If true, the skill tally will blink very brightly and play a noise.
"""
func _blink(bright: bool = false) -> void:
	if _bright_tween_active:
		return
	
	$Tween.remove_all()
	$Blink.rect_scale = Vector2(1, 1)
	if bright:
		_bright_tween_active = true
		$Blink.modulate = Color.white
		$Tween.interpolate_property($Blink, "rect_scale", $Blink.rect_scale, Vector2(2.0, 2.0), 1.2)
		$Tween.interpolate_property($Blink, "modulate", $Blink.modulate, Color(0.111, 0.888, 0.111, 0.0),
				1.2, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		$TaskCompleteSound.play()
	else:
		$Blink.modulate = Color(0.111, 0.888, 0.111, 0.5)
		$Tween.interpolate_property($Blink, "rect_scale", $Blink.rect_scale, Vector2(1.5, 1.5), 0.6)
		$Tween.interpolate_property($Blink, "modulate:a", $Blink.modulate.a, 0.0,
				0.6, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	$Tween.start()


func _update_label() -> void:
	if show_as_percent:
		$Label.text = "%s\n%d%%" % [label_text, int(100 * value / max_value)]
	else:
		$Label.text = "%s\n(%d/%d)" % [label_text, value, max_value]


func _on_PuzzleScore_game_prepared() -> void:
	reset()


"""
When the player performs a skill we blink and increment our value.
"""
func _on_skill_performed() -> void:
	increment()


func _on_Playfield_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	_on_skill_performed()


func _on_Playfield_box_made(x: int, y: int, width: int, height: int, color: int) -> void:
	_on_skill_performed()


func _on_Tween_tween_all_completed() -> void:
	_bright_tween_active = false
