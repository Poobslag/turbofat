class_name NextPieceDisplays
extends Control
## Displays upcoming pieces to the player and manages the next piece displays.

const DISPLAY_COUNT := 9

@export var piece_queue_path: NodePath
@export var NextPieceDisplayScene: PackedScene

## array of NextPieceDisplays which are shown to the player
var _next_piece_displays := []

@onready var _piece_queue: PieceQueue = get_node(piece_queue_path)

func _ready() -> void:
	PuzzleState.game_prepared.connect(_on_PuzzleState_game_prepared)
	Pauser.paused_changed.connect(_on_Pauser_paused_changed)
	for i in range(DISPLAY_COUNT):
		_add_display(i, 5, 5 + i * (486.0 / (DISPLAY_COUNT - 1)), 0.5)


func get_display(piece_index: int) -> NextPieceDisplay:
	return _next_piece_displays[piece_index]


## Adds a new next piece display.
func _add_display(piece_index: int, x: float, y: float, scale: float) -> void:
	var new_display: NextPieceDisplay = NextPieceDisplayScene.instantiate()
	new_display.initialize(_piece_queue, piece_index)
	new_display.scale = Vector2(scale, scale)
	new_display.position = Vector2(x, y)
	new_display.hide()
	add_child(new_display)
	_next_piece_displays.append(new_display)


## Gets ready for a new game, randomizing the pieces and filling the piece queues.
func _on_PuzzleState_game_prepared() -> void:
	for next_piece_display in _next_piece_displays:
		next_piece_display.show()


## When the player pauses, we hide the playfield so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	for display in _next_piece_displays:
		display.visible = not value
