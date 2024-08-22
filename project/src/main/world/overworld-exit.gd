tool
extends Sprite
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

## sprite sheet for when the exit faces east or west
const EXIT_E_SHEET := preload("res://assets/main/world/environment/exit-e-sheet.png")

## sprite sheet for when the exit faces north or south
const EXIT_N_SHEET := preload("res://assets/main/world/environment/exit-n-sheet.png")

## sprite sheet for when the exit faces northeast, southeast, southwest or northwest
const EXIT_NE_SHEET := preload("res://assets/main/world/environment/exit-ne-sheet.png")

## direction the exit is facing. Also the direction the player needs to move to use the exit
export (ExitDirection) var exit_direction := ExitDirection.NORTH setget set_exit_direction

func _ready() -> void:
	_refresh_exit_direction()


func set_exit_direction(new_exit_direction: int) -> void:
	exit_direction = new_exit_direction
	
	if is_inside_tree():
		_refresh_exit_direction()


## Updates the appearance and collision shape based on the new exit direction.
func _refresh_exit_direction() -> void:
	scale.x = abs(scale.x) * (-1 if exit_direction in [SOUTHWEST, WEST, NORTHWEST] else 1)
	scale.y = abs(scale.y) * (-1 if exit_direction in [SOUTHWEST, SOUTH, SOUTHEAST] else 1)
	
	match exit_direction:
		NORTH, SOUTH: texture = EXIT_N_SHEET
		NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST: texture = EXIT_NE_SHEET
		EAST, WEST: texture = EXIT_E_SHEET
