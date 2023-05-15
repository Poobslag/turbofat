extends Node2D
## Combo/Spin/Squish indicators which appear when the player builds a combo or performs tech moves in puzzle mode.

export (NodePath) var piece_manager_path: NodePath
export (NodePath) var playfield_path: NodePath

export (PackedScene) var ComboBurstScene: PackedScene
export (PackedScene) var MoneyBurstScene: PackedScene
export (PackedScene) var TechMoveBurstScene: PackedScene

## Stores the x position of the previous combo burst to ensure consecutive bursts aren't vertically aligned
var _previous_cell_x := -1

## Tracks the x position of the most recent piece placed in each row
## key: (int) y value of a recently dropped piece
## value: (float) average x position of the piece's blocks in that row
var _piece_x_by_y: Dictionary

onready var _piece_manager: PieceManager = get_node(piece_manager_path)
onready var _playfield: Playfield = get_node(playfield_path)

## Containers for combo bursts and tech bursts. Tech bursts appear on top.
onready var _combo_container := $Combo
onready var _money_container := $Money
onready var _tech_container := $Tech

func _ready() -> void:
	PuzzleState.connect("before_piece_written", self, "_on_PuzzleState_before_piece_written")
	PuzzleState.connect("added_unusual_cell_score", self, "_on_PuzzleState_added_unusual_cell_score")


## Adds a combo burst to the specified cell.
##
## A combo burst is an indicator like '6x' which appears when the player clears multiple lines in succession.
##
## Parameters:
## 	'target_cell': The cell to add the combo burst to.
##
## 	'combo': The combo to display.
func _add_combo_burst(target_cell: Vector2, combo: int) -> void:
	var combo_burst: ComboBurst = ComboBurstScene.instance()
	combo_burst.position = Utils.map_to_world_centered(_playfield.tile_map, target_cell + Vector2(0, -3))
	combo_burst.position *= _playfield.tile_map.scale
	combo_burst.combo = combo
	_combo_container.add_child(combo_burst)


## Adds a money burst to the specified cell.
##
## A money burst is an indicator like '¥20' which appears when the player earns money from a puzzle critter. This
## occurs during very specific levels with gimmicks like sharks. It mostly gets treated the same way as pickups, but
## also triggers a money UI popup.
##
## Parameters:
## 	'target_cell': The cell to add the money burst to.
##
## 	'money': The money to display.
func _add_money_burst(target_cell: Vector2, money: int) -> void:
	var money_burst: MoneyBurst = MoneyBurstScene.instance()
	money_burst.position = Utils.map_to_world_centered(_playfield.tile_map, target_cell + Vector2(0, -3))
	money_burst.position *= _playfield.tile_map.scale
	money_burst.money = money
	_money_container.add_child(money_burst)


## Adds a tech move burst to the specified cell.
##
## A tech move burst is an indicator like 'J-Squish' or 'P-Spin Double' which appears when the player locks in a piece
## in a special way.
##
## Parameters:
## 	'target_cell': The cell to add the tech move burst to.
##
## 	'piece_type': The piece type, such as 'U piece' or 'V piece'
##
## 	'tech_type': Enum from TechMoveBurst.TechType such as 'Spin' or 'Squish'
##
## 	'lines_cleared': The number of lines cleared by this tech move

func _add_tech_move_burst(target_cell: Vector2, piece_type: PieceType, tech_type: int, lines_cleared: int) -> void:
	var tech_move_burst: TechMoveBurst = TechMoveBurstScene.instance()
	tech_move_burst.position = Utils.map_to_world_centered(_playfield.tile_map, target_cell + Vector2(0, -3))
	tech_move_burst.position *= _playfield.tile_map.scale
	tech_move_burst.piece_type = piece_type
	tech_move_burst.tech_type = tech_type
	tech_move_burst.lines_cleared = lines_cleared
	_tech_container.add_child(tech_move_burst)


## Calculates the cell for a new combo burst.
##
## Combo bursts appear in front of the previous piece placed in the specified row, although they also never appear
## adjacent to the previous combo burst.
func _combo_burst_cell(y: int) -> Vector2:
	var target_cell := Vector2(_piece_x_by_y.get(y, 4), y)
	if fmod(target_cell.x, 1.0) > 0.0:
		# if a piece has two blocks side-by-side, we position the combo burst over one or the other
		if floor(target_cell.x) == _previous_cell_x or ceil(target_cell.x) == _previous_cell_x:
			# ensure the combo burst doesn't vertically align with the previous counter
			target_cell.x = floor(target_cell.x) if _previous_cell_x == ceil(target_cell.x) else ceil(target_cell.x)
		else:
			# decide randomly between the two blocks
			target_cell.x = floor(target_cell.x) if randf() > 0.5 else ceil(target_cell.x)
	elif target_cell.x == _previous_cell_x:
		# if a combo burst vertically aligns with the previous counter, we move it horizontally
		if target_cell.x == 0:
			target_cell.x += 1
		elif target_cell.x == PuzzleTileMap.COL_COUNT - 1:
			target_cell.x -= 1
		else:
			target_cell.x += Utils.rand_value([-1, 1])
	_previous_cell_x = target_cell.x
	return target_cell


## Calculates the cell for a new tech move burst.
##
## Tech move bursts appear in the middle of the current piece.
func _tech_move_cell(piece: ActivePiece) -> Vector2:
	var center := piece.center()
	center.x = floor(center.x) if randf() < 0.5 else ceil(center.x)
	center.y = floor(center.y) if randf() < 0.5 else ceil(center.y)
	return center


## When the player places a piece, we store the piece's position in _piece_x_by_y
##
## This allows combo bursts to appear horizontally aligned with the most recent piece.
func _on_PuzzleState_before_piece_written() -> void:
	var piece_min_x_by_y := {}
	var piece_max_x_by_y := {}
	for pos_arr_item in _piece_manager.piece.get_pos_arr():
		var target_cell: Vector2 = pos_arr_item + _piece_manager.piece.pos
		if not piece_min_x_by_y.has(target_cell.y):
			piece_min_x_by_y[target_cell.y] = target_cell.x
			piece_max_x_by_y[target_cell.y] = target_cell.x
		else:
			piece_min_x_by_y[target_cell.y] = min(piece_min_x_by_y[target_cell.y], target_cell.x)
			piece_max_x_by_y[target_cell.y] = max(piece_max_x_by_y[target_cell.y], target_cell.x)
	
	for y in piece_min_x_by_y:
		_piece_x_by_y[int(y)] = (piece_min_x_by_y[y] + piece_max_x_by_y[y]) / 2


## When the player earns money from a puzzle critter we add a new money burst.
func _on_PuzzleState_added_unusual_cell_score(cell: Vector2, cell_score: int) -> void:
	_add_money_burst(cell, cell_score)


## When a line is cleared we add a new combo burst.
func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	if PuzzleState.combo < 3:
		# no combo bursts below 3x
		return
	
	var target_cell := _combo_burst_cell(y)
	_add_combo_burst(target_cell, PuzzleState.combo)


## When a spin move is performed we add a new tech move burst.
func _on_PieceManager_finished_spin_move(piece: ActivePiece, lines_cleared: int) -> void:
	var target_cell := _tech_move_cell(piece)
	_add_tech_move_burst(target_cell, piece.type, TechMoveBurst.SPIN, lines_cleared)


## When a squish move is performed we add a new tech move burst.
func _on_PieceManager_finished_squish_move(piece: ActivePiece, lines_cleared: int) -> void:
	var target_cell := _tech_move_cell(piece)
	_add_tech_move_burst(target_cell, piece.type, TechMoveBurst.SQUISH, lines_cleared)
