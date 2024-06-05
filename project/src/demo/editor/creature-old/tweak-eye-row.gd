extends HBoxContainer
## UI control for tweaking a creature's eye color.
##
## The eye uses two different colors, and requires a specialized tool.

export (NodePath) var creature_editor_path: NodePath

## Allele property used internally when updating the creature. Not shown to the player
var _allele := "eye_rgb"

onready var _creature_editor: CreatureEditorOld = get_node(creature_editor_path)

func _ready() -> void:
	_creature_editor.connect("center_creature_changed", self, "_on_CreatureEditor_center_creature_changed")


## Update the creature with the player's chosen eye color.
func _on_Edit_color_changed(_color: Color) -> void:
	var color_string := "%s %s" % [$Edit1.color.to_html(false).to_lower(), $Edit2.color.to_html(false).to_lower()]
	_creature_editor.center_creature.dna[_allele] = color_string
	_creature_editor.center_creature.refresh_dna()


func _on_Edit_popup_closed() -> void:
	get_tree().paused = false


func _on_Edit_pressed() -> void:
	get_tree().paused = true


func _on_GrayDna_pressed() -> void:
	_creature_editor.tweak_all_creatures(_allele, CreatureEditorOld.SIMILAR_COLORS)


func _on_PurpleDna_pressed() -> void:
	_creature_editor.tweak_all_creatures(_allele, CreatureEditorOld.THEME_COLORS)


func _on_RainbowDna_pressed() -> void:
	_creature_editor.tweak_all_creatures(_allele, CreatureEditorOld.RANDOM_COLORS)


## Update the color picker buttons with the creature's eye color.
func _on_CreatureEditor_center_creature_changed() -> void:
	var rgb_split: Array = _creature_editor.center_creature.dna[_allele].split(" ")
	$Edit1.color = Color(rgb_split[0])
	$Edit2.color = Color(rgb_split[1])
