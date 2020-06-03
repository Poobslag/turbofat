extends Node2D
"""
A small bubble which appears alongside the game window which shows the current creature. As the player drops blocks
and scores points, the creature eats and grows larger.
"""

# the amount of time spent panning the camera to a new creature
const PAN_DURATION_SECONDS := 0.4


func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("combo_ended", self, "_on_PuzzleScore_combo_ended")


func _physics_process(delta: float) -> void:
	if $FatPlayer.get_fatness() != get_creature().get_fatness():
		$FatPlayer.set_fatness(get_creature().get_fatness())


func get_creature(creature_index: int = -1) -> Creature:
	return $SceneClip/CreatureSwitcher/Scene.get_creature(creature_index)


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.
"""
func summon_creature(creature_index: int = -1) -> void:
	var creature_def: Dictionary
	if Global.creature_queue.empty():
		creature_def = CreatureLoader.random_def()
	else:
		creature_def = Global.creature_queue.pop_front()
	$SceneClip/CreatureSwitcher/Scene.summon_creature(creature_def, creature_index)


"""
Pans the camera to a new creature. This also changes which creature will be fed.
"""
func set_current_creature_index(current_creature_index: int) -> void:
	$SceneClip/CreatureSwitcher/Scene.current_creature_index = current_creature_index
	$SceneClip/CreatureSwitcher/CreatureSwitchTween.interpolate_property(
			$SceneClip/CreatureSwitcher, "position:x",
			$SceneClip/CreatureSwitcher.position.x, -1000 * current_creature_index, PAN_DURATION_SECONDS,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$SceneClip/CreatureSwitcher/CreatureSwitchTween.start()


"""
Scroll to a new creature and replace the old creature.
"""
func scroll_to_new_creature() -> void:
	var creature_index: int = $SceneClip/CreatureSwitcher/Scene.current_creature_index
	var new_creature_index: int = (creature_index + randi() % 2 + 1) % 3
	set_current_creature_index(new_creature_index)
	yield(get_tree().create_timer(0.5), "timeout")
	summon_creature(creature_index)


"""
If they ended the previous game while serving a creature, we scroll to a new one
"""
func _on_PuzzleScore_game_prepared() -> void:
	if get_creature().get_fatness() > 1:
		scroll_to_new_creature()


func _on_PuzzleScore_combo_ended() -> void:
	if PuzzleScore.game_active and not Scenario.settings.other.tutorial:
		get_creature().play_goodbye_voice()
		scroll_to_new_creature()
