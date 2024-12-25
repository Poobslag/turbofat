## Singleton for hosting AudioStreamPlayers to ensure they persist between scenes.
extends Node

## Duplicates an AudioStreamPlayer and ensures it persists between scenes.
##
## Parameters:
## 	'player': The AudioStreamPlayer, AudioStreamPlayer2D or AudioStreamPlayer3D to duplicate.
##
## Returns:
## 	A copy of the specified AudioStreamPlayer, AudioStreamPlayer2D or AudioStreamPlayer3D which will persist
## 	between scenes.
func copy(player: Node) -> Node:
	if not player:
		return null
	
	if not player is AudioStreamPlayer \
			and not player is AudioStreamPlayer2D \
			and not player is AudioStreamPlayer3D:
		push_warning("Unrecognized AudioStreamPlayer: %s (%s)" % [player.get_path(), player.get_class()])
		return null
	
	var new_player: Node = player.duplicate()
	add_child(new_player)
	new_player.connect("finished", self, "_cleanup_player", [new_player])
	
	# Clean up unplayed audio streams after a short delay
	if is_inside_tree():
		get_tree().create_timer(0.1).connect("timeout", self, "_cleanup_player", [new_player])

	return new_player


func _cleanup_player(player: Node) -> void:
	if is_instance_valid(player) and not player.playing:
		player.queue_free()
