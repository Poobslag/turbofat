extends HBoxContainer
## UI control for editing a creature's allele, such their nose or mouth.

## Allele property used internally when updating the creature. Not shown to the player
export (String) var allele: String

## Allele property used internally when updating the creature. Not shown to the player
export (String) var text: String

export (NodePath) var creature_editor_path: NodePath

## Allele values corresponding to the option button items. Used when updating the creature, not shown to the player.
var _allele_values: Array

onready var _creature_editor: CreatureEditor = get_node(creature_editor_path)
onready var _edit := $Edit
onready var _label := $Label

func _ready() -> void:
	_label.text = "%s:" % text
	_creature_editor.connect("center_creature_changed", self, "_on_CreatureEditor_center_creature_changed")


## Update the creature with the player's chosen allele value.
func _select_allele(index: int) -> void:
	_creature_editor.center_creature.dna[allele] = _allele_values[index]
	_creature_editor.center_creature.refresh_dna()


## Populate the option button with the available allele values.
func _on_Edit_pressed() -> void:
	_allele_values = DnaUtils.unique_allele_values(allele)
	
	var allele_index := 0
	while allele_index < _allele_values.size():
		var allele_value: String = _allele_values[allele_index]
		if DnaUtils.invalid_allele_value(_creature_editor.center_creature.dna, allele, allele_value):
			_allele_values.remove(allele_index)
		else:
			allele_index += 1
	
	_edit.clear()
	for value in _allele_values:
		_edit.add_item(DnaUtils.allele_name(allele, value))
	_edit.selected = _allele_values.find(_creature_editor.center_creature.dna[allele])


func _on_Edit_item_selected(index: int) -> void:
	_select_allele(index)


func _on_Edit_item_focused(index: int) -> void:
	_select_allele(index)


func _on_Dna_pressed() -> void:
	_creature_editor.tweak_all_creatures(allele)


## Update the option button with the creature's allele value.
func _on_CreatureEditor_center_creature_changed() -> void:
	if _creature_editor.center_creature.dna[allele]:
		_edit.text = DnaUtils.allele_name(allele, _creature_editor.center_creature.dna[allele])
	else:
		_edit.text = ""
