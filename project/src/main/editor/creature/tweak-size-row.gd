extends HBoxContainer
## UI control for editing a creature's size.

@export (NodePath) var creature_editor_path: NodePath

@onready var _creature_editor: CreatureEditor = get_node(creature_editor_path)

func _ready() -> void:
	_creature_editor.connect("center_creature_changed", Callable(self, "_on_CreatureEditor_center_creature_changed"))


## Update the creature's size.
func _on_Edit_value_changed(value: float) -> void:
	_creature_editor.center_creature.min_fatness = value
	_creature_editor.center_creature.set_fatness(value)


## Update the slider with the creature's size.
func _on_CreatureEditor_center_creature_changed() -> void:
	$Edit.value = _creature_editor.center_creature.get_fatness()


func _on_Dna_pressed() -> void:
	_creature_editor.tweak_all_creatures("fatness")
