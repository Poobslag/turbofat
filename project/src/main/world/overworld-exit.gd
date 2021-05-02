tool
extends Area2D
"""
An exit on the floor which the player can step on to go somewhere else.

Stepping on this exit results transitions to a new scene.
"""

# The direction the exit is facing. Also the direction the player needs to move to use the exit.
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

const NORTH = ExitDirection.NORTH
const NORTHEAST = ExitDirection.NORTHEAST
const EAST = ExitDirection.EAST
const SOUTHEAST = ExitDirection.SOUTHEAST
const SOUTH = ExitDirection.SOUTH
const SOUTHWEST = ExitDirection.SOUTHWEST
const WEST = ExitDirection.WEST
const NORTHWEST = ExitDirection.NORTHWEST

# key: an enum from ExitDirection
# value: a non-isometric unit vector in the direction the exit is facing
const VECTOR_BY_EXIT_DIRECTION := {
	NORTH: Vector2.UP,
	NORTHEAST: Vector2(sqrt(2), -sqrt(2)),
	EAST: Vector2.RIGHT,
	SOUTHEAST: Vector2(sqrt(2), sqrt(2)),
	SOUTH: Vector2.DOWN,
	SOUTHWEST: Vector2(-sqrt(2), sqrt(2)),
	WEST: Vector2.LEFT,
	NORTHWEST: Vector2(-sqrt(2), -sqrt(2))
}

# the path of the scene to transition to when the player uses the exit
export (String) var destination_scene_path

# the direction the exit is facing. Also the direction the player needs to move to use the exit
export (ExitDirection) var exit_direction := ExitDirection.NORTH setget set_exit_direction

# the id of the spawn where the player will appear on the overworld after using the exit
export (String) var player_spawn_id: String

# the id of the spawn where the sensei will appear on the overworld after using the exit
export (String) var sensei_spawn_id: String

# sprite sheet for when the exit faces east or west
var _exit_e_sheet := preload("res://assets/main/world/environment/exit-e-sheet.png")

# sprite sheet for when the exit faces north or south
var _exit_n_sheet := preload("res://assets/main/world/environment/exit-n-sheet.png")

# sprite sheet for when the exit faces northeast, southeast, southwest or northwest
var _exit_ne_sheet := preload("res://assets/main/world/environment/exit-ne-sheet.png")

# 'true' if the player is currently overlapping the exit. this might not make them exit if they're sitting still or
# moving the wrong way
var _player_overlapping := false

# 'true' if the player stepped on this exit arrow and is exiting
var _player_exiting := false

# We embed the get_overworld_ui() call in a conditional to avoid errors in the editor
onready var _overworld_ui: OverworldUi = null if Engine.editor_hint else Global.get_overworld_ui()

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
	_refresh_exit_direction()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or not ChattableManager.player:
		# don't try to change scenes in the editor
		return
	if _overworld_ui.is_chatting():
		# don't change scenes while chatting
		return
	
	if _player_overlapping and not SceneTransition.fading:
		var player: Player = ChattableManager.player
		
		var target_direction: Vector2 = VECTOR_BY_EXIT_DIRECTION.get(exit_direction, Vector2.ZERO)
		
		# if the player is overlapping the exit and facing the exit direction, we transition to a new scene
		if player.non_iso_walk_direction and target_direction \
				and player.non_iso_walk_direction.dot(target_direction) >= 0.49:
			_player_exiting = true
			
			Global.player_spawn_id = player_spawn_id
			Global.sensei_spawn_id = sensei_spawn_id
			player.fade_out()
			SceneTransition.replace_trail(destination_scene_path)


func set_exit_direction(new_exit_direction: int) -> void:
	exit_direction = new_exit_direction
	if is_inside_tree():
		_refresh_exit_direction()


"""
Updates the appearance and collision shape based on the new exit direction.
"""
func _refresh_exit_direction() -> void:
	$CollisionShape2D.position = VECTOR_BY_EXIT_DIRECTION.get(exit_direction) * 20
	
	$Sprite.scale.x = abs($Sprite.scale.x) * (-1 if exit_direction in [SOUTHWEST, WEST, NORTHWEST] else 1)
	$Sprite.scale.y = abs($Sprite.scale.y) * (-1 if exit_direction in [SOUTHWEST, SOUTH, SOUTHEAST] else 1)
	
	match exit_direction:
		NORTH, SOUTH: $Sprite.texture = _exit_n_sheet
		NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST: $Sprite.texture = _exit_ne_sheet
		EAST, WEST: $Sprite.texture = _exit_e_sheet


func _on_body_entered(body: Node) -> void:
	if body == ChattableManager.player:
		_player_overlapping = true


func _on_body_exited(body: Node) -> void:
	if body == ChattableManager.player:
		_player_overlapping = false
