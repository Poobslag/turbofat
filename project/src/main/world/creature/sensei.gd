class_name Sensei
extends Creature
## Script for manipulating the sensei in the overworld.
##
## The sensei follows the player around.

## sensei tries to keep a respectable distance from the player
const TOO_CLOSE_THRESHOLD := 140.0
const TOO_FAR_THRESHOLD := 280.0

## if 'true' the sensei is in free roam mode and will follow the player
var free_roam := false

## Cannot statically type as 'OverworldUi' because of cyclic reference
@onready var _overworld_ui: Node = Global.get_overworld_ui()

func _ready() -> void:
	set_creature_id(CreatureLibrary.SENSEI_ID)
	$MoveTimer.timeout.connect(_on_MoveTimer_timeout)


func _on_MoveTimer_timeout() -> void:
	if not free_roam:
		# disable movement outside of free roam mode
		return
	
	if not CreatureManager.player:
		return
	
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	var player_relative_pos: Vector2 = Global.from_iso(CreatureManager.player.position - position)
	# the sensei runs at isometric 45 degree angles to mimic the player's inputs
	var player_angle: float = snapped(player_relative_pos.normalized().angle(), PI / 4)
	
	var move_dir := Vector2.ZERO
	if player_relative_pos.length() > TOO_FAR_THRESHOLD:
		# if the sensei is too far from the player, they run closer
		move_dir = Vector2.RIGHT.rotated(player_angle)
	elif player_relative_pos.length() < TOO_CLOSE_THRESHOLD:
		# if the sensei is too close to the player, they run away
		move_dir = -Vector2.RIGHT.rotated(player_angle)
	
	set_non_iso_walk_direction(move_dir)
