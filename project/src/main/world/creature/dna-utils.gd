class_name DnaUtils
extends Node
"""
Provides utilities for manipulating DNA definitions.

DNA is defined using dictionaries. The keys or 'alleles' include things like eye color or mouth shape.
"""

# Palettes used for recoloring creatures
const CREATURE_PALETTES := [
	{"line_rgb": "6c4331", "body_rgb": "b23823", "belly_rgb": "c9442a",
			"eye_rgb": "282828 dedede", "horn_rgb": "f1e398"}, # dark red
	{"line_rgb": "6c4331", "body_rgb": "eeda4d", "belly_rgb": "f7f0cc",
			"eye_rgb": "c0992f f1e398", "horn_rgb": "f1e398"}, # yellow
	{"line_rgb": "6c4331", "body_rgb": "41a740", "belly_rgb": "4fa94e",
			"eye_rgb": "c09a2f f1e398", "horn_rgb": "f1e398"}, # dark green
	{"line_rgb": "6c4331", "body_rgb": "b47922", "belly_rgb": "d0ec5c",
			"eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398"}, # brown
	{"line_rgb": "6c4331", "body_rgb": "6f83db", "belly_rgb": "92d8e5",
			"eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398"}, # light blue
	{"line_rgb": "6c4331", "body_rgb": "a854cb", "belly_rgb": "bb73dd",
			"eye_rgb": "4fa94e dbe28e", "horn_rgb": "f1e398"}, # purple
	{"line_rgb": "6c4331", "body_rgb": "f57e7d", "belly_rgb": "fde8c9",
			"eye_rgb": "7ac252 e9f4dc", "horn_rgb": "f1e398"}, # light red
	{"line_rgb": "6c4331", "body_rgb": "f9bb4a", "belly_rgb": "fff4b2",
			"eye_rgb": "f9a74c fff6df", "horn_rgb": "b47922"}, # orange
	{"line_rgb": "6c4331", "body_rgb": "8fea40", "belly_rgb": "e8fa95",
			"eye_rgb": "f5d561 fcf3cd", "horn_rgb": "b47922"}, # light green
	{"line_rgb": "6c4331", "body_rgb": "70843a", "belly_rgb": "8c9537",
			"eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398"}, # goblin green
	{"line_rgb": "6c4331", "body_rgb": "feceef", "belly_rgb": "ffeffc",
			"eye_rgb": "ffddf4 ffffff", "horn_rgb": "ffffff"}, # pink
	{"line_rgb": "6c4331", "body_rgb": "b1edee", "belly_rgb": "dff2f0",
			"eye_rgb": "c1f1f2 ffffff", "horn_rgb": "ffffff"}, # cyan
	{"line_rgb": "6c4331", "body_rgb": "f9f7d9", "belly_rgb": "d7c2a4",
			"eye_rgb": "91e6ff ffffff", "horn_rgb": "ffffff"}, # white
	{"line_rgb": "3c3c3d", "body_rgb": "1a1a1e", "belly_rgb": "433028",
			"eye_rgb": "b8260b f45e40", "horn_rgb": "282828"}, # black
	{"line_rgb": "6c4331", "body_rgb": "7a8289", "belly_rgb": "c8c3b5",
			"eye_rgb": "f5f0d1 ffffff", "horn_rgb": "282828"}, # grey
	{"line_rgb": "41281e", "body_rgb": "0b45a6", "belly_rgb": "eec086",
			"eye_rgb": "fad541 ffffff", "horn_rgb": "282828"}  # dark blue
]


"""
If the specified key is not associated with a value, this method associates it with the given value.
"""
static func put_if_absent(dna: Dictionary, key: String, value) -> void:
	dna[key] = dna.get(key, value)


"""
Fill in the creature's missing traits with random values.

Otherwise, missing values will be left empty, leading to invisible body parts or strange colors.
"""
static func fill_dna(dna: Dictionary) -> Dictionary:
	# duplicate the dna so that we don't modify the original
	var result := dna.duplicate()
	put_if_absent(result, "line_rgb", "6c4331")
	put_if_absent(result, "body_rgb", "b23823")
	put_if_absent(result, "belly_rgb", "ffa86d")
	put_if_absent(result, "eye_rgb", "282828 dedede")
	put_if_absent(result, "horn_rgb", "f1e398")
	
	if ResourceCache.minimal_resources:
		# avoid loading unnecessary resources for things like the level editor
		pass
	else:
		for allele in ["cheek", "eye", "ear", "horn", "mouth", "nose", "belly"]:
			put_if_absent(result, allele, Utils.rand_value(allele_values(result, allele)))
	put_if_absent(result, "body", "1")
	return result


"""
Returns a list of potential values for the specified allele.

This uses the creature's current dna to avoid combining creature parts that don't look good together.
"""
static func allele_values(dna: Dictionary, property: String) -> Array:
	var result := []
	
	if property in ["eye_rgb", "horn_rgb", "body_rgb", "belly_rgb", "line_rgb"]:
		# color palette properties
		for palette in CREATURE_PALETTES:
			result.append(palette[property])
	else:
		# other properties
		match property:
			"belly": result = ["0", "0", "1", "1", "2"]
			"cheek": result = ["0", "0", "0", "1", "1", "2", "2", "3"]
			"ear": result = ["1", "1", "1", "2", "3"]
			"eye": result = ["1", "1", "1", "2", "3"]
			"horn": result = ["0", "0", "0", "1", "2"]
			"mouth":
				result = ["1", "1", "2", "3", "3"]
				if dna.has("nose") and dna["nose"] != "0":
					# creatures with nose are less likely to have beaky mouth
					result = ["1", "1", "2", "3", "3", "3", "3", "3", "3"]
			"nose":
				result = ["0", "1", "1", "2", "2", "3", "3"]
				if dna.has("mouth") and dna["mouth"] in ["1", "2"]:
					# creatures with beaky mouths are less likely to have nose
					result = ["0", "0", "0", "0", "0", "0", "0", "1", "1", "2", "2", "3"]
	
	return result
