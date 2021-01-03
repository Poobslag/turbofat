tool
extends Area2D
"""
An exit on the floor which the player can step on to go somewhere else.

Stepping on this exit results transitions to a new scene.
"""

# The direction the exit is facing. Also the direction the player needs to move to use the exit.
enum ExitDirection {
	NORTH,
	SOUTH
}

# the path of the scene to transition to when the player uses the exit
export (String) var destination_scene_path

# the direction the exit is facing. Also the direction the player needs to move to use the exit
export (ExitDirection) var exit_direction := ExitDirection.NORTH setget set_exit_direction

# the id of the spawn where the player will appear on the overworld after using the exit
export (String) var player_spawn_id: String

# the id of the spawn where the instructor will appear on the overworld after using the exit
export (String) var instructor_spawn_id: String

# 'true' if the player is currently overlapping the exit. this might not make them exit if they're sitting still or
# moving the wrong way
var _player_overlapping := false

# 'true' if the player stepped on this exit arrow and is exiting
var _player_exiting := false

func _ready() -> void:
	SceneTransition.connect("fade_out_ended", self, "_on_SceneTransition_fade_out_ended")
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
	_refresh_exit_direction()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# don't try to change scenes in the editor
		return
	
	if _player_overlapping and not SceneTransition.fading:
		var player: Player = ChattableManager.player
		
		var target_direction: Vector2
		match exit_direction:
			ExitDirection.NORTH: target_direction = Vector2.UP
			ExitDirection.SOUTH: target_direction = Vector2.DOWN
			_: target_direction = Vector2.ZERO
		
		# if the player is overlapping the exit and facing the exit direction, we transition to a new scene
		if player.non_iso_walk_direction and target_direction \
				and player.non_iso_walk_direction.dot(target_direction) >= 0.49:
			_player_exiting = true
			SceneTransition.start_fade_out()


func set_exit_direction(new_exit_direction: int) -> void:
	exit_direction = new_exit_direction
	if is_inside_tree():
		_refresh_exit_direction()


"""
Updates the appearance and collision shape based on the new exit direction.
"""
func _refresh_exit_direction() -> void:
	if exit_direction == ExitDirection.NORTH:
		$Sprite.scale.y = abs($Sprite.scale.y)
		$CollisionShape2D.position.y = -20.0
	elif exit_direction == ExitDirection.SOUTH:
		$Sprite.scale.y = -abs($Sprite.scale.y)
		$CollisionShape2D.position.y = 20.0


func _on_body_entered(body: Node) -> void:
	if body == ChattableManager.player:
		_player_overlapping = true


func _on_body_exited(body: Node) -> void:
	if body == ChattableManager.player:
		_player_overlapping = false


func _on_SceneTransition_fade_out_ended() -> void:
	if not _player_exiting:
		# ignore the event unless the player stepped on this specific exit arrow
		return
	
	Global.player_spawn_id = player_spawn_id
	Global.instructor_spawn_id = instructor_spawn_id
	Breadcrumb.replace_trail(destination_scene_path)
