extends Node
## Demonstrates the creature palettes, and lets you view/edit them.
##
## This adds a third 'palette' tab to the creature editor. Clicking the themes in that tab recolors the creature. There
## are also buttons for adding themes and printing them to the console.

@export var PaletteEditorTabScene: PackedScene

func _ready() -> void:
	var palette_editor_tab: PaletteEditorTab = PaletteEditorTabScene.instantiate()
	$CreatureEditor/Ui/TabContainer.add_child(palette_editor_tab)
	palette_editor_tab.creature_editor_path = palette_editor_tab.get_path_to($CreatureEditor)
