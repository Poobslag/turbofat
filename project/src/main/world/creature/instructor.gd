extends Creature
"""
Script for manipulating the instructor in the overworld.

The instructor follows the player around.
"""

# the instructor tries to keep a respectable distance from the player
const TOO_CLOSE_THRESHOLD := 140.0
const TOO_FAR_THRESHOLD := 280.0

export (NodePath) var player_path: NodePath

onready var _player: Creature = get_node(player_path)

func _ready() -> void:
	set_creature_id("#instructor#")
	$MoveTimer.connect("timeout", self, "_on_MoveTimer_timeout")


func _on_MoveTimer_timeout() -> void:
	var player_relative_pos := Global.from_iso(_player.position - position)
	# the instructor runs at isometric 45 degree angles to mimic the player's inputs
	var player_angle := stepify(player_relative_pos.normalized().angle(), PI / 4)
	
	var move_dir := Vector2.ZERO
	if player_relative_pos.length() > TOO_FAR_THRESHOLD:
		# if the instructor is too far from the player, they run closer
		move_dir = Vector2.RIGHT.rotated(player_angle)
	elif player_relative_pos.length() < TOO_CLOSE_THRESHOLD:
		# if the instructor is too close to the player, they run away
		move_dir = -Vector2.RIGHT.rotated(player_angle)
	
	move_dir = Global.to_iso(move_dir)
	set_non_iso_walk_direction(move_dir)
