extends Node2D
"""
A small bubble which appears alongside the game window which shows the current creature. As the player drops blocks
and scores points, the creature eats and grows larger.
"""

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("combo_ended", self, "_on_PuzzleScore_combo_ended")


func get_creature_2d(creature_index: int = -1) -> Creature:
	return $SceneClip/CreatureSwitcher/Scene.get_creature_2d(creature_index)


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.
"""
func summon_creature(creature_index: int = -1) -> void:
	var dna: Dictionary
	if Global.creature_queue.empty():
		dna = CreatureLoader.random_def()
	else:
		dna = Global.creature_queue.pop_front()
	$SceneClip/CreatureSwitcher/Scene.summon_creature(dna, creature_index)


"""
Pans the camera to a new creature. This also changes which creature will be fed.
"""
func set_current_creature_index(new_index: int) -> void:
	$SceneClip/CreatureSwitcher/Scene.current_creature_index = new_index


"""
Scroll to a new creature and replace the old creature.
"""
func scroll_to_new_creature(new_creature_index: int = -1) -> void:
	var old_creature_index: int = get_current_creature_index()
	if new_creature_index == -1:
		new_creature_index = (old_creature_index + randi() % 2 + 1) % 3
	set_current_creature_index(new_creature_index)
	$SceneClip/CreatureSwitcher/Scene.get_creature_2d().restart_idle_timer()
	yield(get_tree().create_timer(0.5), "timeout")
	summon_creature(old_creature_index)


func get_current_creature_index() -> int:
	return $SceneClip/CreatureSwitcher/Scene.current_creature_index


"""
If they ended the previous game while serving a creature, we scroll to a new one
"""
func _on_PuzzleScore_game_prepared() -> void:
	if get_creature_2d().get_fatness() > 1 and not Scenario.settings.other.tutorial:
		# don't scroll if we're doing a tutorial; the tutorial will scroll back to the instructor if necessary.
		scroll_to_new_creature()


func _on_PuzzleScore_combo_ended() -> void:
	if PuzzleScore.game_active and not Scenario.settings.other.tutorial:
		get_creature_2d().play_goodbye_voice()
		scroll_to_new_creature()
