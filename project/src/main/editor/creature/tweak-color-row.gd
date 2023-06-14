extends HBoxContainer
## UI control for editing one of a creature's colors.

## Allele property used internally when updating the creature. Not shown to the player
@export (String) var allele: String

## Allele property used internally when updating the creature. Not shown to the player
@export (String) var text: String

@export (NodePath) var creature_editor_path: NodePath

@onready var _creature_editor: CreatureEditor = get_node(creature_editor_path)

func _ready() -> void:
	$Label.text = "%s:" % text
	_creature_editor.connect("center_creature_changed", Callable(self, "_on_CreatureEditor_center_creature_changed"))
	if allele == "all_rgb":
		$Edit.visible = false


## Update the creature with the player's chosen color.
func _on_Edit_color_changed(_color: Color) -> void:
	_creature_editor.center_creature.dna[allele] = $Edit.color.to_html(false).to_lower()
	_creature_editor.center_creature.refresh_dna()


func _on_Edit_popup_closed() -> void:
	get_tree().paused = false


func _on_Edit_pressed() -> void:
	get_tree().paused = true


func _on_RainbowDna_pressed() -> void:
	_creature_editor.tweak_all_creatures(allele, CreatureEditor.RANDOM_COLORS)


func _on_PurpleDna_pressed() -> void:
	_creature_editor.tweak_all_creatures(allele, CreatureEditor.THEME_COLORS)


func _on_GreyDna_pressed() -> void:
	_creature_editor.tweak_all_creatures(allele, CreatureEditor.SIMILAR_COLORS)


## Update the color picker button with the creature's color.
func _on_CreatureEditor_center_creature_changed() -> void:
	if allele != "all_rgb":
		$Edit.color = Color(_creature_editor.center_creature.dna[allele])
