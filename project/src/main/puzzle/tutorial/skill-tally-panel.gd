class_name SkillTallyPanel
extends Panel
## UI elements for 'skill tally items' which provides feedback during tutorials when the player performs an action,
## such as rotating a piece or clearing a line.

onready var _grid_container := $GridContainer

func _ready() -> void:
	visible = false
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")


## Returns a specific SkillTallyItem instance in the panel.
func skill_tally_item(name: String) -> SkillTallyItem:
	return _grid_container.get_node(name) as SkillTallyItem


## Returns all SkillTallyItem instances in the panel.
func skill_tally_items() -> Array:
	return _grid_container.get_children()


## Adds a new SkillTallyItem instance to the panel.
func add_skill_tally_item(item: SkillTallyItem) -> void:
	_grid_container.add_child(item)


## Shows the panel containing skill tally items.
func show_skill_tally_items() -> void:
	show()
	for skill_tally_item in skill_tally_items():
		skill_tally_item.visible = true


## Pauses and plays a camera flash effect for transitions.
func _on_PuzzleState_after_level_changed() -> void:
	visible = CurrentLevel.is_tutorial()
