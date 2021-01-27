class_name Sensei
extends Creature
"""
Script for manipulating the sensei in the overworld.

The sensei follows the player around.
"""

# the sensei tries to keep a respectable distance from the player
const TOO_CLOSE_THRESHOLD := 140.0
const TOO_FAR_THRESHOLD := 280.0

func _ready() -> void:
	set_creature_id(CreatureLibrary.SENSEI_ID)
	$MoveTimer.connect("timeout", self, "_on_MoveTimer_timeout")
	ChattableManager.sensei = self


func _on_MoveTimer_timeout() -> void:
	var player_relative_pos: Vector2 = Global.from_iso(ChattableManager.player.position - position)
	# the sensei runs at isometric 45 degree angles to mimic the player's inputs
	var player_angle := stepify(player_relative_pos.normalized().angle(), PI / 4)
	
	var move_dir := Vector2.ZERO
	if player_relative_pos.length() > TOO_FAR_THRESHOLD:
		# if the sensei is too far from the player, they run closer
		move_dir = Vector2.RIGHT.rotated(player_angle)
	elif player_relative_pos.length() < TOO_CLOSE_THRESHOLD:
		# if the sensei is too close to the player, they run away
		move_dir = -Vector2.RIGHT.rotated(player_angle)
	
	move_dir = Global.to_iso(move_dir)
	set_non_iso_walk_direction(move_dir)
