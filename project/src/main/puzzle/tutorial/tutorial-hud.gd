class_name TutorialHud
extends Control
"""
UI items specific for puzzle tutorials.
"""

# emitted when the HUD should be refreshed during initial setup or for a level change.
signal refreshed

export (NodePath) var puzzle_path: NodePath

onready var puzzle: Puzzle = get_node(puzzle_path)

func _ready() -> void:
	visible = false
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("after_level_changed", self, "_on_PuzzleScore_after_level_changed")
	Level.connect("settings_changed", self, "_on_Level_settings_changed")
	replace_tutorial_module()


func get_tutorial_diagram() -> TutorialDiagram:
	return $Diagram as TutorialDiagram


func get_tutorial_messages() -> TutorialMessages:
	return $Messages as TutorialMessages


"""
Loads a new tutorial module corresponding to the current level.

Tutorial modules show messages and advance the player through the tutorial as they complete tasks.
"""
func replace_tutorial_module() -> void:
	if has_node("TutorialModule"):
		remove_child(get_node("TutorialModule"))
	
	var module_path: String
	if Level.settings.id.begins_with("tutorial/basics"):
		module_path = "res://src/main/puzzle/tutorial/TutorialBasicsModule.tscn"
	elif Level.settings.id.begins_with("tutorial/squish"):
		module_path = "res://src/main/puzzle/tutorial/TutorialSquishModule.tscn"
	elif Level.settings.id.begins_with("tutorial/combo"):
		module_path = "res://src/main/puzzle/tutorial/TutorialComboModule.tscn"
	
	if module_path:
		var tutorial_module_scene: PackedScene = load(module_path)
		var tutorial_module: Node = tutorial_module_scene.instance()
		tutorial_module.hud = self
		tutorial_module.name = "TutorialModule"
		add_child(tutorial_module)
	
	# pause to ensure the 'ready' signal is emitted before the 'refreshed' signal
	yield(get_tree(), "idle_frame")
	refresh()


"""
Shows or hides the tutorial hud based on the current level.
"""
func refresh() -> void:
	# only visible for tutorial levels
	visible = Level.settings.other.tutorial or Level.settings.other.after_tutorial
	$Diagram.hide()
	emit_signal("refreshed")


"""
Returns a specific SkillTallyItem instance in the panel.
"""
func skill_tally_item(name: String) -> SkillTallyItem:
	return get_node("SkillTallyItems/GridContainer/%s" % name) as SkillTallyItem


"""
Returns all SkillTallyItem instances in the panel.
"""
func skill_tally_items() -> Array:
	return $SkillTallyItems/GridContainer.get_children()


"""
Adds a new SkillTallyItem instance to the panel.
"""
func add_skill_tally_item(item: SkillTallyItem) -> void:
	$SkillTallyItems/GridContainer.add_child(item)


"""
Displays a sequence of messages from the sensei.
"""
func set_messages(messages: Array) -> void:
	$Messages.set_messages(messages)


"""
Displays a message from the sensei.
"""
func set_message(message: String) -> void:
	$Messages.set_message(message)


"""
Displays a BIG message from the sensei, for use in easter eggs.
"""
func set_big_message(message: String) -> void:
	$Messages.set_big_message(message)


"""
Displays a message after a short delay.

If other messages are already in the queue, this message will be appended to the queue.
"""
func enqueue_message(message: String) -> void:
	$Messages.enqueue_message(message)


"""
Hides the currently shown message after a short delay.

If other messages are already in the queue, this operation will be appended to the queue.
"""
func enqueue_pop_out() -> void:
	$Messages.enqueue_pop_out()


"""
Shows the panel containing skill tally items.
"""
func show_skill_tally_items() -> void:
	$SkillTallyItems.show()
	for skill_tally_item in skill_tally_items():
		skill_tally_item.visible = true


"""
Pause and play a camera _flash effect for transitions.
"""
func _flash() -> void:
	puzzle.get_playfield().add_misc_delay_frames(30)
	$ZIndex/ColorRect.modulate.a = 0.25
	$Tween.remove_all()
	$Tween.interpolate_property($ZIndex/ColorRect, "modulate:a", $ZIndex/ColorRect.modulate.a, 0.0, 1.0)
	$Tween.start()


func _on_PuzzleScore_after_level_changed() -> void:
	$SkillTallyItems.visible = Level.settings.other.tutorial
	_flash()


func _on_PuzzleScore_game_prepared() -> void:
	refresh()


func _on_Level_settings_changed() -> void:
	refresh()
