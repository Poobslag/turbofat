extends Node2D
"""
A small bubble which appears alongside the game window which shows the current creature. As the player drops blocks
and scores points, the creature eats and grows larger.
"""

# the amount of time spent panning the camera to a new creature
const PAN_DURATION_SECONDS := 0.4

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")


"""
Increases/decreases the camera and creature's fatness, playing an animation which gradually applies the change.

Parameters:
	'fatness': How fat the creature should be; 5.0 = 5x normal size
"""
func set_fatness(fatness: float, creature_index: int = -1) -> void:
	$SceneClip/CreatureSwitcher/Scene.set_fatness(fatness, creature_index)
	if creature_index == -1 or creature_index == $SceneClip/CreatureSwitcher/Scene.current_creature_index:
		$FatPlayer.set_fatness(fatness)


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.
"""
func summon_creature(creature_index: int = -1) -> void:
	var creature_def: Dictionary
	if Global.creature_queue.empty():
		creature_def = CreatureLoader.DEFINITIONS[randi() % CreatureLoader.DEFINITIONS.size()]
	else:
		creature_def = Global.creature_queue.pop_front()
	$SceneClip/CreatureSwitcher/Scene.summon_creature(creature_def, creature_index)


"""
Returns the camera's 'fatness' -- when fatness is 1.0 the camera is zoomed in, and when the fatness is at 10.0 it's
zoomed out so that the creature is in frame.
"""
func get_fatness() -> float:
	return $FatPlayer.get_fatness()


"""
Pans the camera to a new creature. This also changes which creature will be fed.
"""
func set_current_creature_index(current_creature_index: int) -> void:
	$SceneClip/CreatureSwitcher/Scene.current_creature_index = current_creature_index
	$SceneClip/CreatureSwitcher/CreatureSwitchTween.interpolate_property(
			$SceneClip/CreatureSwitcher, "position:x",
			$SceneClip/CreatureSwitcher.position.x, -1000 * current_creature_index, PAN_DURATION_SECONDS,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$FatPlayer.set_fatness($SceneClip/CreatureSwitcher/Scene.get_fatness(current_creature_index))
	$SceneClip/CreatureSwitcher/CreatureSwitchTween.start()


"""
Returns the index of the creature which the camera is currently focused on.
"""
func get_current_creature_index() -> int:
	return $SceneClip/CreatureSwitcher/Scene.current_creature_index


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice() -> void:
	$SceneClip/CreatureSwitcher/Scene.play_goodbye_voice()


"""
Scroll to a new creature and replace the old creature.
"""
func scroll_to_new_creature() -> void:
	var creature_index: int = get_current_creature_index()
	var new_creature_index: int = (creature_index + randi() % 2 + 1) % 3
	set_current_creature_index(new_creature_index)
	yield(get_tree().create_timer(0.5), "timeout")
	set_fatness(1, creature_index)
	summon_creature(creature_index)


"""
If they ended the previous game while serving a creature, we scroll to a new one
"""
func _on_PuzzleScore_game_prepared() -> void:
	if get_fatness() > 1:
		scroll_to_new_creature()
