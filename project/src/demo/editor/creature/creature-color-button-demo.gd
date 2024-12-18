extends Node
## Shows off the creature color buttons, and provides utilities for editing creature color palettes.
##
## Keys:
## 	[Q/W/E/R/T]: Assign a palette with 0/4/8/24/100 colors.
## 	[Z]: Extract new palettes from old palettes.
## 	[X]: Report duplicate colors from our new palettes.
## 	[C]: Report creature colors not present in our new palettes.

onready var _tab_container := $TabContainer
onready var _text_edit := $TabContainer/ColorAnalysis/TextEdit

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Z:
			_extract_colors_from_creature_palettes()
		KEY_X:
			_show_similar_colors()
		KEY_C:
			_show_missing_colors()
		KEY_Q:
			_assign_color_presets(0)
		KEY_W:
			_assign_color_presets(4)
		KEY_E:
			_assign_color_presets(8)
		KEY_R:
			_assign_color_presets(24)
		KEY_T:
			_assign_color_presets(100)


func _assign_color_presets(count: int) -> void:
	var new_color_presets := color_presets(count)
	for button in [
		$TabContainer/CreatureColorButton/ButtonTopLeft,
		$TabContainer/CreatureColorButton/ButtonTopRight,
		$TabContainer/CreatureColorButton/ButtonCenter,
		$TabContainer/CreatureColorButton/ButtonBottomLeft,
		$TabContainer/CreatureColorButton/ButtonBottomRight,
	]:
		button.set_color_presets(new_color_presets)


func color_presets(count: int) -> Array:
	var result := []
	if count >= 8:
		result.append(Color.white)
		result.append(Color.gray)
		result.append(Color.black)
	while result.size() < count:
		var random_color := Color(randf(), randf(), randf())
		result.append(random_color)
	return result


## Extract palettes from the old creature editor format and prints them in the new format.
##
## The old creature editor relied on the "DnaUtils.CREATURE_PALETTES" field which had unified palettes for all of a
## creature's parts, such as "Green scales, red eyes and a yellow belly." By contrast, the new creature editor relies
## on the CreatureEditorLibrary.COLOR_PRESETS_BY_COLOR_PROPERTY field which has independent fields for each of a
## creature's parts, such as "Red eyes, green eyes, blue eyes."
func _extract_colors_from_creature_palettes() -> void:
	var lines := []
	var color_properties: Array = DnaUtils.CREATURE_PALETTES[0].keys()
	color_properties.sort()
	
	var colors_by_property := {}
	for color_property in color_properties:
		colors_by_property[color_property] = {}
		for palette in DnaUtils.CREATURE_PALETTES:
			colors_by_property[color_property][Color(palette[color_property])] = true
	
	for color_property in colors_by_property:
		var colors_string := _string_from_color_array(colors_by_property[color_property].keys())
		lines.append("\"%s\": [%s]," % [color_property, colors_string])
	_show_color_analysis(lines)


## Converts an array of colors into a GDScript string.
##
## Parameters:
## 	'colors': Color instances to convert
##
## Returns:
## 	A combined color string such as 'Color("ffffff"), Color("eeeeee")'
func _string_from_color_array(colors: Array) -> String:
	var result := ""
	for color in colors:
		if result:
			result += ", "
		result += "Color(\"%s\")" % [color.to_html(false)]
	return result


## Reports any duplicate colors in our color presets.
##
## These colors are shown as color swatches in the creature editor, where we don't want to present the player with
## duplicates. This method checks for any duplicates or near-duplicates and reports them.
func _show_similar_colors() -> void:
	var lines := []
	
	for color_property in CreatureEditorLibrary.COLOR_PRESETS_BY_COLOR_PROPERTY:
		var old_color_presets: Array = CreatureEditorLibrary.COLOR_PRESETS_BY_COLOR_PROPERTY[color_property]
		var redundant_color_presets := _find_redundant_color_presets(old_color_presets)
		if redundant_color_presets:
			var new_color_presets := old_color_presets.duplicate()
			for redundant_color_preset in redundant_color_presets:
				new_color_presets.remove(new_color_presets.find(redundant_color_preset))
			lines.append("# %s redundant %s colors found: %s" \
					% [redundant_color_presets.size(), color_property,
						_string_from_color_array(redundant_color_presets)])
			lines.append("\"%s\": [%s]," \
					% [color_property, _string_from_color_array(new_color_presets)])
	
	if not lines:
		lines.append("No redundant colors found.");
	
	_show_color_analysis(lines)


## Reports any missing colors in our color presets.
##
## Turbo Fat's creatures include many fanmade submissions, but ideally all of their colors should be approximated by
## color swatches in the creature editor. This method checks for any colors used by creatures which are absent from
## the creature editor.
func _show_missing_colors() -> void:
	var lines := []
	
	var creature_dnas := []
	for creature_id in PlayerData.creature_library.creature_ids():
		if creature_id == CreatureLibrary.PLAYER_ID:
			continue
		creature_dnas.append(PlayerData.creature_library.get_creature_def(creature_id).dna)
	
	for color_property in CreatureEditorLibrary.COLOR_PRESETS_BY_COLOR_PROPERTY:
		if color_property == "line_rgb":
			# line colors are static
			continue
		
		var old_color_presets: Array = CreatureEditorLibrary.COLOR_PRESETS_BY_COLOR_PROPERTY[color_property]
		old_color_presets = old_color_presets.duplicate(true)
		
		var dna_colors := _colors_from_creature_dna(creature_dnas, color_property)
		var missing_color_presets := _find_missing_color_presets(old_color_presets, dna_colors)
		if missing_color_presets:
			var new_color_presets := old_color_presets.duplicate()
			new_color_presets.append_array(missing_color_presets)
			lines.append("# %s missing %s colors found: %s" \
					% [missing_color_presets.size(), color_property, _string_from_color_array(missing_color_presets)])
			lines.append("\"%s\": [%s]," \
					% [color_property, _string_from_color_array(new_color_presets)])
	
	if not lines:
		lines.append("No missing colors found.");
	
	_show_color_analysis(lines)


## Extracts unique Color values for a specified body part from a list of dna definitions.
##
## Parameters:
## 	'creature_dnas': A list of dna definitions to extract Color values from
##
## 	'color_property': The body part to extract Color values for
##
## Returns:
## 	A list of unique Color values for the specified body part.
func _colors_from_creature_dna(creature_dnas: Array, color_property: String) -> Array:
	var result := {}
	for creature_dna in creature_dnas:
		if creature_dna.has(color_property):
			result[Color(creature_dna[color_property])] = true
	if not result:
		push_warning("Color property '%s' is absent from creature dna" % [color_property])
	return result.keys()


## Returns a list of dna colors which are missing from a list of color presets.
##
## Parameters:
## 	'color_presets': Color presets to compare against.
##
## 	'dna_colors': Dna Color instances to search for.
##
## Returns:
## 	List of Color values from 'dna_colors' not present in 'color_presets'.
func _find_missing_color_presets(color_presets: Array, dna_colors: Array) -> Array:
	var result := []
	
	for dna_color in dna_colors:
		var dna_color_found := false
		
		if not dna_color_found:
			for color_preset in color_presets:
				if _is_color_similar(color_preset, dna_color, 0.09):
					dna_color_found = true
					break
		
		if not dna_color_found:
			for color_preset in result:
				if _is_color_similar(color_preset, dna_color, 0.09):
					dna_color_found = true
					break
		
		if not dna_color_found:
			result.append(dna_color)
	
	return result


## Reports the specified lines of text in the 'ColorAnalysis' tab.
##
## Parameters:
## 	'lines': List of String instances to show the user.
func _show_color_analysis(lines: Array) -> void:
	_tab_container.current_tab = 2
	_text_edit.text = PoolStringArray(lines).join("\n")


## Returns any duplicate colors in a list of color presets.
##
## Parameters:
## 	'color_presets': Color presets to examine.
##
## Returns:
## 	List of duplicate colors which should be removed. If 4 copies of the same color are found, only 3 copies are
## 	returned, because we want to preserve one of them.
func _find_redundant_color_presets(color_presets: Array) -> Array:
	var result := []
	
	for i in range(color_presets.size()):
		var is_redundant := false
		
		for j in range(i):
			if _is_color_similar(color_presets[i], color_presets[j], 0.06):
				is_redundant = true
				break
		
		if is_redundant:
			result.append(color_presets[i])
		
	return result


## Returns 'true' if two colors fall within a similarity threshold.
##
## Parameters:
## 	'color_0': The first color to compare.
##
## 	'color_1': The second color to compare.
##
## 	'threshold': A number roughly in the range of [0, 1], where 0.1 means colors must be very similar, and 0.9
## 		means colors do not need to be similar at all.
##
## Returns:
## 	'True' if the two specified colors fall within the given similarity threshold.
func _is_color_similar(color_0: Color, color_1: Color, threshold: float) -> bool:
	return Utils.color_distance_rgb(color_0, color_1) <= threshold
