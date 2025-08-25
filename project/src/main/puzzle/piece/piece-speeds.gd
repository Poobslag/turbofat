extends Node
## Stores data about the different 'piece speeds' such as how fast pieces should drop, how long it takes them to lock
## into the playfield, and how long to pause when clearing lines.
##
## Much of this speed data was derived from wikis for other piece-dropping games which have the concept of a 'hold
## piece' so it's likely it will change over time to become more lenient.

## All gravity constants are integers like '16', which actually correspond to fractions like '16/256' which means the
## piece takes 16 frames to drop one row. G is the denominator of that fraction.
const G := 256

## Maximum number of 'lock resets' the player is allotted for a single piece. A lock reset occurs when a piece is
## at the bottom of the screen but the player moves or rotates it to prevent from locking.
const MAX_LOCK_RESETS := 15

## Gravity constant used when the player soft-drops a piece.
const DROP_G := 128

## After the player does a 'squish move' the piece is unaffected by gravity for this many frames.
const POST_SQUISH_FRAMES := 4

## How fast the pieces are moving right now
var current_speed: PieceSpeed

## Array of speed ids in ascending order
var speed_ids := []

## Matrix of piece speed adjustments.
##
## Each row in the matrix represents a set of speeds in order from slowest to fastest. Speeds which give the player a
## speed advantage are given their own group (e.g playing with a 200 ms appearance delay instead of a 300 ms
## appearance delay.)
var speed_id_matrix := []

var _speeds := {}

func _ready() -> void:
	# tutorial; piece does not drop
	_add_speed_group()
	_add_speed(PieceSpeed.new("T",   0, 20, 36, 7, 16, 60, 24, 12))
	
	# beginner; 10-30 pieces per minute
	_add_speed_group()
	_add_speed(PieceSpeed.new("0",   4, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("1",   5, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("2",   6, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("3",   8, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("4",  10, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("5",  12, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("6",  16, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("7",  24, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("8",  32, 20, 36, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("9",  48, 20, 36, 7, 16, 60, 24, 12))
	
	# normal; 30-60 pieces per minute
	_add_speed_group()
	_add_speed(PieceSpeed.new("A0",    4, 20, 20, 7, 16, 60, 24, 12))
	_add_speed(PieceSpeed.new("A1",   32, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("A2",   48, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("A3",   64, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("A4",   96, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("A5",  128, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("A6",  152, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("A7",  176, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("A8",  200, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("A9",  224, 20, 20, 7, 16, 40, 24, 12))
	
	# hard; 60-120 pieces per minute
	_add_speed(PieceSpeed.new("AA",  1*G, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("AB",  2*G, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("AC",  3*G, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("AD",  5*G, 20, 20, 7, 16, 40, 24, 12))
	_add_speed(PieceSpeed.new("AE", 20*G, 20, 16, 7, 10, 30, 18,  9))
	_add_speed(PieceSpeed.new("AF", 20*G, 16, 12, 7, 10, 30, 12,  6))
	
	# crazy; 120-250 pieces per minute
	_add_speed_group()
	_add_speed(PieceSpeed.new( "F0",    4, 10, 6, 7,  8, 60, 6, 3))
	_add_speed(PieceSpeed.new( "F1",  1*G, 10, 6, 7,  8, 40, 6, 3))
	_add_speed(PieceSpeed.new( "FA", 20*G, 10, 6, 7,  8, 24, 6, 3))
	_add_speed(PieceSpeed.new( "FB", 20*G,  6, 4, 7,  8, 22, 5, 3))
	_add_speed(PieceSpeed.new( "FC", 20*G,  4, 2, 7,  8, 20, 4, 3))
	_add_speed(PieceSpeed.new( "FD", 20*G,  2, 2, 7,  8, 18, 3, 3))
	_add_speed(PieceSpeed.new( "FE", 20*G,  2, 2, 7,  8, 16, 3, 3))
	_add_speed(PieceSpeed.new( "FF", 20*G,  2, 2, 7,  8, 14, 3, 3))
	_add_speed(PieceSpeed.new("FFF", 20*G,  2, 2, 7,  8, 12, 3, 3))
	
	current_speed = PieceSpeeds.speed("0")
	PuzzleState.connect("speed_index_changed", self, "_on_PuzzleState_speed_index_changed")
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	
	PlayerData.difficulty.connect("speed_changed", self, "_on_DifficultyData_speed_changed")


func speed(string: String) -> PieceSpeed:
	return _speeds[string]


func _add_speed_group() -> void:
	speed_id_matrix.append([])


func _add_speed(speed: PieceSpeed) -> void:
	speed_ids.append(speed.id)
	speed_id_matrix.back().append(speed.id)
	_speeds[speed.id] = speed


func _update_current_speed() -> void:
	var piece_speed_string: String = MilestoneManager.prev_milestone().get_meta("speed")
	piece_speed_string = GameplayDifficultyAdjustments.adjust_piece_speed(CurrentLevel.settings, piece_speed_string)
	PieceSpeeds.current_speed = PieceSpeeds.speed(piece_speed_string)


func _on_PuzzleState_speed_index_changed(_value: int) -> void:
	_update_current_speed()


func _on_PuzzleState_game_prepared() -> void:
	_update_current_speed()


func _on_DifficultyData_speed_changed(_value: int) -> void:
	_update_current_speed()
