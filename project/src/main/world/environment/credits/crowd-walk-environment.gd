extends OverworldEnvironment
## Environment for a unique cutscene where the player and Fat Sensei walk through a cheering crowd.

signal midair_changed(value)

## 'true' if the player and Fat Sensei are soaring through the air.
var midair: bool setget set_midair

func set_midair(new_midair: bool) -> void:
	if midair == new_midair:
		return
	
	midair = new_midair
	emit_signal("midair_changed", new_midair)


## When the CrowdWalkDirector initializes the character positions, we reset the 'midair' value to false.
##
## This is mostly useful for demo and debugging purposes, as the animation should only play once during the credits.
func _on_Director_played() -> void:
	set_midair(false)
