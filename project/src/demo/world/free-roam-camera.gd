extends Camera2D
## Camera for the free roam overworld. Follows the main character.

func _process(_delta: float) -> void:
	if not CreatureManager.player:
		# The overworld camera follows the player. If there is no player, we have nothing to follow
		return
	
	position = lerp(position, CreatureManager.player.position, 0.10)
