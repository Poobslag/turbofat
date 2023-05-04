@tool
extends Sprite2D
## Exit on the floor which the player can step on to go somewhere else.
##
## Stepping on this exit results transitions to a new scene.

## Direction the exit is facing. Also the direction the player needs to move to use the exit.
enum ExitDirection {
	NORTH,
	NORTHEAST,
	EAST,
	SOUTHEAST,
	SOUTH,
	SOUTHWEST,
	WEST,
	NORTHWEST
}

const NORTH := ExitDirection.NORTH
const NORTHEAST := ExitDirection.NORTHEAST
const EAST := ExitDirection.EAST
const SOUTHEAST := ExitDirection.SOUTHEAST
const SOUTH := ExitDirection.SOUTH
const SOUTHWEST := ExitDirection.SOUTHWEST
const WEST := ExitDirection.WEST
const NORTHWEST := ExitDirection.NORTHWEST

## direction the exit is facing. Also the direction the player needs to move to use the exit
@export var exit_direction := ExitDirection.NORTH: set = set_exit_direction

## sprite sheet for when the exit faces east or west
var _exit_e_sheet := preload("res://assets/main/world/environment/exit-e-sheet.png")

## sprite sheet for when the exit faces north or south
var _exit_n_sheet := preload("res://assets/main/world/environment/exit-n-sheet.png")

## sprite sheet for when the exit faces northeast, southeast, southwest or northwest
var _exit_ne_sheet := preload("res://assets/main/world/environment/exit-ne-sheet.png")

## We embed the get_overworld_ui() call in a conditional to avoid errors in the editor
@onready var _overworld_ui: OverworldUi = null if Engine.is_editor_hint() else Global.get_overworld_ui()

func _ready() -> void:
	_refresh_exit_direction()


func set_exit_direction(new_exit_direction: ExitDirection) -> void:
	exit_direction = new_exit_direction
	
	if is_inside_tree():
		_refresh_exit_direction()


## Updates the appearance and collision shape based on the new exit direction.
func _refresh_exit_direction() -> void:
	scale.x = abs(scale.x) * (-1 if exit_direction in [SOUTHWEST, WEST, NORTHWEST] else 1)
	scale.y = abs(scale.y) * (-1 if exit_direction in [SOUTHWEST, SOUTH, SOUTHEAST] else 1)
	
	match exit_direction:
		NORTH, SOUTH: texture = _exit_n_sheet
		NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST: texture = _exit_ne_sheet
		EAST, WEST: texture = _exit_e_sheet
