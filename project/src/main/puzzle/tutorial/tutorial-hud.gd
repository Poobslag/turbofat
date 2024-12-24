class_name TutorialHud
extends Control
## UI items specific for puzzle tutorials.

## emitted when the HUD should be refreshed during initial setup or for a level change.
signal refreshed

export (NodePath) var puzzle_path: NodePath

export (NodePath) var hud_flash_path: NodePath

onready var messages: TutorialMessages = $Messages
onready var diagram: TutorialDiagram = $Diagram
onready var skill_tally_panel: SkillTallyPanel = $SkillTallyPanel

onready var puzzle: Puzzle = get_node(puzzle_path)
onready var _hud_flash: HudFlash = get_node(hud_flash_path)

func _ready() -> void:
	visible = false
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	replace_tutorial_module()


## Loads a new tutorial module corresponding to the current level.
##
## Tutorial modules show messages and advance the player through the tutorial as they complete tasks.
func replace_tutorial_module() -> void:
	if has_node("TutorialModule"):
		var child := get_node("TutorialModule")
		remove_child(child)
		child.queue_free()
	
	var module_path: String
	if CurrentLevel.settings.id.begins_with("tutorial/basics_"):
		module_path = "res://src/main/puzzle/tutorial/TutorialBasicsModule.tscn"
	elif CurrentLevel.settings.id.begins_with("tutorial/cakes_"):
		module_path = "res://src/main/puzzle/tutorial/TutorialCakesModule.tscn"
	elif CurrentLevel.settings.id.begins_with("tutorial/combo_"):
		module_path = "res://src/main/puzzle/tutorial/TutorialComboModule.tscn"
	elif CurrentLevel.settings.id.begins_with("tutorial/squish_"):
		module_path = "res://src/main/puzzle/tutorial/TutorialSquishModule.tscn"
	elif CurrentLevel.settings.id.begins_with("tutorial/spins_"):
		module_path = "res://src/main/puzzle/tutorial/TutorialSpinsModule.tscn"
	
	if module_path:
		var tutorial_module_scene: PackedScene = ResourceCache.get_resource(module_path)
		var tutorial_module: Node = tutorial_module_scene.instance()
		tutorial_module.hud = self
		tutorial_module.name = "TutorialModule"
		add_child(tutorial_module)
	
	# pause to ensure the 'ready' signal is emitted before the 'refreshed' signal
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
	refresh()


## Shows or hides the tutorial hud based on the current level.
func refresh() -> void:
	# only visible for tutorial levels
	visible = CurrentLevel.is_tutorial() or CurrentLevel.settings.other.after_tutorial
	diagram.hide()
	emit_signal("refreshed")


## Returns a specific SkillTallyItem instance in the panel.
func skill_tally_item(name: String) -> SkillTallyItem:
	return skill_tally_panel.skill_tally_item(name)


## Returns all SkillTallyItem instances in the panel.
func skill_tally_items() -> Array:
	return skill_tally_panel.skill_tally_items()


## Adds a new SkillTallyItem instance to the panel.
func add_skill_tally_item(item: SkillTallyItem) -> void:
	skill_tally_panel.add_skill_tally_item(item)


## Shows the panel containing skill tally items.
func show_skill_tally_items() -> void:
	skill_tally_panel.show_skill_tally_items()


## Displays a sequence of messages from the sensei.
func set_messages(new_messages: Array) -> void:
	messages.set_messages(new_messages)


## Displays a message from the sensei.
func set_message(new_message: String) -> void:
	messages.set_message(new_message)


## Displays a BIG message from the sensei, for use in easter eggs.
func set_big_message(new_message: String) -> void:
	messages.set_big_message(new_message)


## Displays a message after a short delay.
##
## If other messages are already in the queue, this message will be appended to the queue.
func enqueue_message(message: String) -> void:
	messages.enqueue_message(message)


## Hides the currently shown message after a short delay.
##
## If other messages are already in the queue, this operation will be appended to the queue.
func enqueue_pop_out() -> void:
	messages.enqueue_pop_out()


## Plays a camera flash effect for transitions.
func flash_for_level_change() -> void:
	_hud_flash.flash()


func _on_PuzzleState_after_level_changed() -> void:
	flash_for_level_change()


func _on_PuzzleState_game_prepared() -> void:
	refresh()


func _on_Level_settings_changed() -> void:
	refresh()
