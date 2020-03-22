"""
A small bubble which appears alongside the game window which shows the current customer. As the player drops blocks
and scores points, the customer eats and grows larger.
"""
extends Node2D

"""
Increases/decreases the customer's fatness, playing an animation which gradually applies the change.

Parameters: The 'fatness' parameter controls how fat the customer should be; 5.0 = 5x normal size
"""
func set_fatness(fatness: float) -> void:
	$SceneClip/Scene.set_fatness(fatness)
	$FatPlayer.set_fatness(fatness)

func get_fatness() -> float:
	return $FatPlayer.get_fatness()
