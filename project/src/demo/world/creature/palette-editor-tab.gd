class_name PaletteEditorTab
extends VBoxContainer
"""
A tab which lets the player pick and edit different creature palettes.
"""

export (PackedScene) var PaletteButtonScene: PackedScene
export (NodePath) var creature_editor_path: NodePath setget set_creature_editor_path

var _rng := RandomNumberGenerator.new()
var _creature_editor: CreatureEditor
var _creature_palettes := []

func _ready() -> void:
	if creature_editor_path:
		_creature_editor = get_node(creature_editor_path)
	for palette in DnaUtils.CREATURE_PALETTES:
		_add_palette(palette)


func set_creature_editor_path(new_creature_editor_path: NodePath) -> void:
	creature_editor_path = new_creature_editor_path
	_creature_editor = get_node(creature_editor_path)


func get_center_creature() -> Creature:
	return _creature_editor.center_creature


func _add_palette(palette: Dictionary) -> void:
	var palette_button: PaletteButton = PaletteButtonScene.instance()
	palette_button.set_palette(palette)
	$GridContainer.add_child(palette_button)
	palette_button.connect("pressed", self, "_on_PaletteButton_pressed", [palette])
	_creature_palettes.append(palette)


"""
Updates the creature's colors with the clicked palette.

Rotates the creature's current color to the outer creatures, so the player can go back if they liked the old colors.
"""
func _on_PaletteButton_pressed(palette: Dictionary) -> void:
	# rotate the creature's current color out
	_creature_editor.outer_creatures[0].dna = get_center_creature().dna
	for i in range(_creature_editor.outer_creatures.size() - 1):
		_creature_editor.outer_creatures[i].dna = _creature_editor.outer_creatures[i + 1].dna
	_creature_editor.outer_creatures[_creature_editor.outer_creatures.size() - 1].dna = get_center_creature().dna
	
	# update the center creature with new dna
	var dna := {}
	for allele in ["line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb",
			"cheek", "eye", "ear", "horn", "mouth", "nose", "collar", "belly"]:
		if get_center_creature().dna.has(allele):
			dna[allele] = get_center_creature().dna[allele]
	for allele in ["line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb"]:
		dna[allele] = palette[allele]
	get_center_creature().dna = dna
	
	# update editor elements which depend on the creature's colors
	_creature_editor.emit_signal("center_creature_changed")


"""
Prints a palette to the console.

This printed palette is valid GDScript, and can be copy/pasted into the DnaUtils constant.
"""
func _print_palette(palette: Dictionary) -> void:
	var result := ""
	result += "\t{\"line_rgb\": \"%s\", " % palette["line_rgb"]
	result += "\"body_rgb\": \"%s\", " % palette["body_rgb"]
	result += "\"belly_rgb\": \"%s\", " % palette["belly_rgb"]
	result += "\"cloth_rgb\": \"%s\",\n\t\t\t" % palette["cloth_rgb"]
	result += "\"eye_rgb\": \"%s\", " % palette["eye_rgb"]
	result += "\"horn_rgb\": \"%s\"}, # ??????" % palette["horn_rgb"]
	print(result)


"""
Prints all palettes to the console.
"""
func _on_Print_pressed() -> void:
	print("const CREATURE_PALETTES := [")
	for palette in _creature_palettes:
		_print_palette(palette)
	print("]")


"""
Appends a palette and prints it to the console.
"""
func _on_Add_pressed() -> void:
	var palette := {}
	for allele in ["line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb"]:
		palette[allele] = get_center_creature().dna[allele]
	_print_palette(palette)
	_add_palette(palette)
