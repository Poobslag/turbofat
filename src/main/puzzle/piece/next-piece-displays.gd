class_name NextPieceDisplays
extends Control
"""
Displays upcoming pieces to the player and manages the next piece displays.
"""

const DISPLAY_COUNT := 9

var _piece_queue := PieceQueue.new()

export (PackedScene) var NextPieceDisplay

# The "next piece displays" which are shown to the user
var _next_piece_displays := []

func _ready() -> void:
	for i in range(DISPLAY_COUNT):
		_add_display(i, 5, 5 + i * (486 / (DISPLAY_COUNT - 1)), 0.5)


"""
Hides all next piece displays. We can't let the player see the upcoming pieces before the game starts.
"""
func hide_pieces() -> void:
	for next_piece_display in _next_piece_displays:
		next_piece_display.hide()


"""
Starts a new game, randomizing the pieces and filling the piece queues.
"""
func start_game() -> void:
	_piece_queue.clear()
	for next_piece_display in _next_piece_displays:
		next_piece_display.show()


"""
Pops the next piece off the queue.
"""
func pop_next_piece() -> PieceType:
	return _piece_queue.pop_next_piece()


"""
Adds a new next piece display.
"""
func _add_display(piece_index: int, x: float, y: float, scale: float) -> void:
	var new_display: NextPieceDisplay = NextPieceDisplay.instance()
	new_display.initialize(_piece_queue, piece_index)
	new_display.scale = Vector2(scale, scale)
	new_display.position = Vector2(x, y)
	add_child(new_display)
	_next_piece_displays.append(new_display)
