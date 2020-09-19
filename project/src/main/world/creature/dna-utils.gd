#tool #uncomment to view creature in editor
extends Node
"""
Provides utilities for manipulating DNA definitions.

DNA is defined using dictionaries. The keys or 'alleles' include things like eye color or mouth shape.
"""

# Colors used for creature's outlines
const LINE_COLORS := ["6c4331", "41281e", "3c3c3d"]

# Palettes used for recoloring creatures
const CREATURE_PALETTES := [
	{"line_rgb": "6c4331", "body_rgb": "b23823", "belly_rgb": "c9442a", "cloth_rgb": "282828",
			"hair_rgb": "f1e398", "eye_rgb": "282828 dedede", "horn_rgb": "f1e398"}, # dark red
	{"line_rgb": "6c4331", "body_rgb": "f9bb4a", "belly_rgb": "fff4b2", "cloth_rgb": "f9a74c",
			"hair_rgb": "b47922", "eye_rgb": "f9a74c fff6df", "horn_rgb": "b47922"}, # yellow
	{"line_rgb": "6c4331", "body_rgb": "41a740", "belly_rgb": "6dcb4c", "cloth_rgb": "c09a2f",
			"hair_rgb": "f1e398", "eye_rgb": "c09a2f f1e398", "horn_rgb": "f1e398"}, # dark green
	{"line_rgb": "6c4331", "body_rgb": "b47922", "belly_rgb": "d0ec5c", "cloth_rgb": "7d4c21",
			"hair_rgb": "f1e398", "eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398"}, # brown
	{"line_rgb": "6c4331", "body_rgb": "6f83db", "belly_rgb": "92d8e5", "cloth_rgb": "374265",
			"hair_rgb": "f1e398", "eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398"}, # light blue
	{"line_rgb": "6c4331", "body_rgb": "a854cb", "belly_rgb": "bb73dd", "cloth_rgb": "4fa94e",
			"hair_rgb": "f1e398", "eye_rgb": "4fa94e dbe28e", "horn_rgb": "f1e398"}, # purple
	{"line_rgb": "6c4331", "body_rgb": "f57e7d", "belly_rgb": "fde8c9", "cloth_rgb": "7ac252",
			"hair_rgb": "f1e398", "eye_rgb": "7ac252 e9f4dc", "horn_rgb": "f1e398"}, # light red
	{"line_rgb": "6c4331", "body_rgb": "e17827", "belly_rgb": "dbbd9e", "cloth_rgb": "4aadc5",
			"hair_rgb": "dfca7a", "eye_rgb": "1492d6 33d4f0", "horn_rgb": "e9ebf0"}, # fox orange
	{"line_rgb": "6c4331", "body_rgb": "8fea40", "belly_rgb": "e8fa95", "cloth_rgb": "f5d561",
			"hair_rgb": "b47922", "eye_rgb": "f5d561 fcf3cd", "horn_rgb": "b47922"}, # light green
	{"line_rgb": "6c4331", "body_rgb": "70843a", "belly_rgb": "a9aa2f", "cloth_rgb": "7d4c21",
			"hair_rgb": "f1e398", "eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398"}, # goblin green
	{"line_rgb": "6c4331", "body_rgb": "ffbfcb", "belly_rgb": "fffaff", "cloth_rgb": "fad4cf",
			"hair_rgb": "ffffff", "eye_rgb": "fad4cf ffffff", "horn_rgb": "ffffff"}, # pink
	{"line_rgb": "6c4331", "body_rgb": "b1edee", "belly_rgb": "dff2f0", "cloth_rgb": "c1f1f2",
			"hair_rgb": "ffffff", "eye_rgb": "c1f1f2 ffffff", "horn_rgb": "ffffff"}, # cyan
	{"line_rgb": "6c4331", "body_rgb": "f9f7d9", "belly_rgb": "d7c2a4", "cloth_rgb": "91e6ff",
			"hair_rgb": "ffffff", "eye_rgb": "91e6ff ffffff", "horn_rgb": "ffffff"}, # white
	{"line_rgb": "41281e", "body_rgb": "1a1a1e", "belly_rgb": "65412e", "cloth_rgb": "b8260b",
			"hair_rgb": "282828", "eye_rgb": "b8260b f45e40", "horn_rgb": "282828"}, # doberman black
	{"line_rgb": "6c4331", "body_rgb": "7a8289", "belly_rgb": "c8c3b5", "cloth_rgb": "f5f0d1",
			"hair_rgb": "282828", "eye_rgb": "f5f0d1 ffffff", "horn_rgb": "282828"}, # grey
	{"line_rgb": "41281e", "body_rgb": "0b45a6", "belly_rgb": "eec086", "cloth_rgb": "fad541",
			"hair_rgb": "282828", "eye_rgb": "fad541 ffffff", "horn_rgb": "282828"}, # dark blue
	{"line_rgb": "6c4331", "body_rgb": "db2a25", "belly_rgb": "ffcd78", "cloth_rgb": "5ba964",
			"hair_rgb": "f4ffff", "eye_rgb": "5ba964 a9e0bb", "horn_rgb": "f4ffff"}, # dragon red
	{"line_rgb": "3c3c3d", "body_rgb": "725e96", "belly_rgb": "a9d252", "cloth_rgb": "41f2ff",
			"hair_rgb": "5a635d", "eye_rgb": "41f2ff d6ffff", "horn_rgb": "5a635d"}, # dragon muted purple
	{"line_rgb": "41281e", "body_rgb": "3b494f", "belly_rgb": "7b8780", "cloth_rgb": "ad1000",
			"hair_rgb": "1f1e1e", "eye_rgb": "ad1000 b73a36", "horn_rgb": "1f1e1e"}, # gargoyle gray
	{"line_rgb": "6c4331", "body_rgb": "68d50a", "belly_rgb": "4baf20", "cloth_rgb": "994dbd",
			"hair_rgb": "ffffed", "eye_rgb": "994dbd b392df", "horn_rgb": "ffffed"}, # hulk green
	{"line_rgb": "6c4331", "body_rgb": "9a7f5d", "belly_rgb": "c9dac6", "cloth_rgb": "25291b",
			"hair_rgb": "b9b9b9", "eye_rgb": "25291b 606060", "horn_rgb": "b9b9b9"}, # goblin tan
	{"line_rgb": "6c4331", "body_rgb": "ffb12c", "belly_rgb": "ffffff", "cloth_rgb": "cb5340",
			"hair_rgb": "d2c9cd", "eye_rgb": "cb5340 ffb597", "horn_rgb": "d2c9cd"}, # goober yellow
	{"line_rgb": "6c4331", "body_rgb": "fa5c2c", "belly_rgb": "ffd461", "cloth_rgb": "a7b958",
			"hair_rgb": "529e43", "eye_rgb": "a7b958 ecf1bf", "horn_rgb": "529e43"}, # pumpkin orange
	{"line_rgb": "6c4331", "body_rgb": "99ffb5", "belly_rgb": "ffffff", "cloth_rgb": "c49877",
			"hair_rgb": "f0ffe5", "eye_rgb": "e9c57d ffffff", "horn_rgb": "f2f1f1"}, # angelic green
	{"line_rgb": "6c4331", "body_rgb": "23a2e3", "belly_rgb": "35e1e0", "cloth_rgb": "415a73",
			"hair_rgb": "ffe7e5", "eye_rgb": "415a73 c8cbd6", "horn_rgb": "ffe7e5"}, # fishy blue
	{"line_rgb": "6c4331", "body_rgb": "9d3df6", "belly_rgb": "e055a0", "cloth_rgb": "ecdf32",
			"hair_rgb": "e1dabb", "eye_rgb": "ecdf32 fcfcdb", "horn_rgb": "ac4577"}, # mystic purple
	{"line_rgb": "6c4331", "body_rgb": "25785f", "belly_rgb": "876edb", "cloth_rgb": "ff5c6f",
			"hair_rgb": "a6a1a1", "eye_rgb": "ff5c6f fff1f0", "horn_rgb": "a6a1a1"}, # sea monster turquoise
	{"line_rgb": "6c4331", "body_rgb": "411c17", "belly_rgb": "e29b6e", "cloth_rgb": "cb1b2e",
			"hair_rgb": "d98227", "eye_rgb": "ff912e ffd061", "horn_rgb": "c9d9bd"}, # ogre brown
	{"line_rgb": "6c4331", "body_rgb": "dbffc8", "belly_rgb": "d69e63", "cloth_rgb": "95c152",
			"hair_rgb": "bdab30", "eye_rgb": "8bb253 ffebff", "horn_rgb": "caf877"}, # celtic white
	{"line_rgb": "41281e", "body_rgb": "8f1b21", "belly_rgb": "838382", "cloth_rgb": "546127",
			"hair_rgb": "2b2b2b", "eye_rgb": "546127 a8ad89", "horn_rgb": "2b2b2b"}, # heckraiser red
	{"line_rgb": "41281e", "body_rgb": "b24b10", "belly_rgb": "d58944", "cloth_rgb": "ffd256",
			"hair_rgb": "464a40", "eye_rgb": "7c4725 b8ad9f", "horn_rgb": "4c5245"}, # muddy orange
	{"line_rgb": "41281e", "body_rgb": "907027", "belly_rgb": "e5d6b7", "cloth_rgb": "d5c26a",
			"hair_rgb": "afa7ae", "eye_rgb": "d5c26a ffffff", "horn_rgb": "afa7ae"}, # golem bronze
	{"line_rgb": "41281e", "body_rgb": "48366e", "belly_rgb": "8b70a1", "cloth_rgb": "121011",
			"hair_rgb": "828863", "eye_rgb": "121011 4d6c6a", "horn_rgb": "828863"}, # grape jelly
	{"line_rgb": "41281e", "body_rgb": "2c4b9e", "belly_rgb": "c78e69", "cloth_rgb": "a58900",
			"hair_rgb": "98a49a", "eye_rgb": "a58900 e3d48e", "horn_rgb": "98a49a"}, # bold blue
	{"line_rgb": "41281e", "body_rgb": "025d28", "belly_rgb": "67aa0f", "cloth_rgb": "ccd44d",
			"hair_rgb": "959f78", "eye_rgb": "ccd44d ffffd9", "horn_rgb": "959f78"}, # broccoli green
	{"line_rgb": "41281e", "body_rgb": "664437", "belly_rgb": "eaf9c7", "cloth_rgb": "74a27f",
			"hair_rgb": "e8a261", "eye_rgb": "74a27f fffaff", "horn_rgb": "e8a261"}, # chocolate brown
	{"line_rgb": "6c4331", "body_rgb": "68af25", "belly_rgb": "8fff54", "cloth_rgb": "ce4224",
			"hair_rgb": "587f44", "eye_rgb": "ce4224 fff6e3", "horn_rgb": "587f44"}, # tomato green
	{"line_rgb": "6c4331", "body_rgb": "f6bd44", "belly_rgb": "2a2a2a", "cloth_rgb": "f0f3bd",
			"hair_rgb": "2c2c2c", "eye_rgb": "f0f3bd ffffff", "horn_rgb": "2c2c2c"}, # honeybee yellow
	{"line_rgb": "3c3c3d", "body_rgb": "171419", "belly_rgb": "b0b4d1", "cloth_rgb": "4e8eee",
			"hair_rgb": "c4c4c5", "eye_rgb": "4e8eee f8ffff", "horn_rgb": "c4c4c5"}, # penguin black
	{"line_rgb": "3c3c3d", "body_rgb": "e63f2d", "belly_rgb": "f77429", "cloth_rgb": "f2c12a",
			"hair_rgb": "486965", "eye_rgb": "f2c12a ffffa2", "horn_rgb": "486965"}, # magma orange
]

# alleles corresponding to creature body parts
const BODY_PART_ALLELES := [
	"body", "head", "cheek", "eye", "ear", "horn", "mouth", "nose", "hair", "collar", "tail", "belly"
]

# alleles corresponding to creature colors
const COLOR_ALLELES := [
	"line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "hair_rgb", "eye_rgb", "horn_rgb"
]

# all alleles, including body parts and colors
const ALLELES := BODY_PART_ALLELES + COLOR_ALLELES

# body part names shown to the player
const ALLELE_NAMES := {
	"eye-0": "(none)",
	"eye-1": "Giant",
	"eye-2": "Zen",
	"eye-3": "Decaf",
	"eye-4": "Ping Pong",
	
	"nose-0": "(none)",
	"nose-1": "Nub",
	"nose-2": "Speck",
	"nose-3": "Goblin",
	
	"mouth-0": "(none)",
	"mouth-1": "Ant",
	"mouth-2": "Illithid",
	"mouth-3": "Imp",
	"mouth-4": "Crow",
	
	"body-1": "Koala",
	"body-2": "Squirrel",
	
	"cheek-0": "Round",
	"cheek-1": "Razor Sharp",
	"cheek-2": "Fluffy Tuft",
	"cheek-3": "Fish Whisker",
	"cheek-4": "Fat Whisker",
	
	"ear-0": "(none)",
	"ear-1": "Sausage",
	"ear-2": "Cannon",
	"ear-3": "Dangler",
	"ear-4": "Nubble",
	"ear-5": "Pancake",
	"ear-6": "Chonky Cat",
	
	"horn-0": "(none)",
	"horn-1": "Straw Hole",
	"horn-2": "Rhino Nub",
	
	"hair-0": "(none)", 
	"hair-1": "Lion", 
	"hair-2": "Shaggy",
	
	"collar-0": "(none)",
	"collar-1": "Handkerchief",
	"collar-2": "Bushy",
	"collar-3": "Scruffy",
	
	"belly-0": "(none)",
	"belly-1": "Full",
	"belly-2": "Half",
	
	"head-1": "(none)",
	"head-2": "Chimp",
	"head-3": "Hedgehog",
	"head-4": "Raccoon",
	"head-5": "Marmoset",
	
	"tail-0": "(none)",
	"tail-1": "Kind Cat",
	"tail-2": "Cute Cat",
	"tail-3": "Devil",
	"tail-4": "Bunny",
	"tail-5": "Soft Squirrel",
	"tail-6": "Fancy Squirrel",
}

# key: alleles
# value: positive numeric weights [0.0-100.0]. high values for common alleles
var _allele_weights := {}

# key: alleles
# value: positive/negative adjustments [-100, 100]. positive for good combos, negative for bad combos
var _allele_combo_adjustments := {}

func _ready() -> void:
	for mouth in ["1", "2"]:
		for nose in ["1", "2", "3"]:
			# creatures with ant/illithid mouth are less likely to have noses
			_set_allele_combo_adjustment("mouth", mouth, "nose", nose, -2)
		
		# creatures with ant/illithid mouth are less likely to have fuzzy hair
		_set_allele_combo_adjustment("mouth", mouth, "hair", "1", -2)
		_set_allele_combo_adjustment("mouth", mouth, "hair", "2", -2)
		
		# creatures with ant/illithid mouth are less likely to have fuzzy neck
		_set_allele_combo_adjustment("mouth", mouth, "collar", "2", -2)
		_set_allele_combo_adjustment("mouth", mouth, "collar", "3", -2)
	
	for nose in ["1", "2", "3"]:
		# creatures with beak can NEVER have nose
		_set_allele_combo_adjustment("mouth", "4", "nose", nose, -999)
	
	_set_allele_weight("body", "1", 6.0)
	_set_allele_weight("head", "1", 6.0)
	_set_allele_weight("belly", "0", 2.0)
	_set_allele_weight("belly", "1", 2.0)
	_set_allele_weight("ear", "1", 3.0)
	_set_allele_weight("ear", "4", 2.0)
	_set_allele_weight("eye", "1", 3.0)
	_set_allele_weight("horn", "0", 3.0)
	_set_allele_weight("mouth", "1", 2.0)
	_set_allele_weight("mouth", "2", 2.0)
	_set_allele_weight("hair", "0", 5.0)
	_set_allele_weight("collar", "0", 5.0)
	_set_allele_weight("collar", "1", 2.0)
	_set_allele_weight("tail", "0", 5.0)


"""
Returns unique list of line colors for the specified dna.

This includes some fixed brownish/greyish colors, as well as a darker version of the body color.
"""
func line_colors(dna: Dictionary) -> Array:
	var result := LINE_COLORS.duplicate()
	if dna.has("body_rgb"):
		var darker_line_rgb := Color(dna["body_rgb"])
		darker_line_rgb.v -= max(darker_line_rgb.v * 0.33, 0.08)
		result.append(darker_line_rgb.to_html(false))
	return result


"""
Return a minimal copy of the specified dna.

CreatureLoader populates the dna dictionary with redundant properties such as textures and shader properties. This
returns a version of the dna with that extra stuff stripped out so it doesn't clutter our save files.
"""
func trim_dna(dna: Dictionary) -> Dictionary:
	var result := {}
	for allele in ALLELES:
		if dna.has(allele):
			result[allele] = dna[allele]
	return result


"""
Fill in the creature's missing traits with random values.

Otherwise, missing values will be left empty, leading to invisible body parts or strange colors.
"""
func fill_dna(dna: Dictionary) -> Dictionary:
	# duplicate the dna so that we don't modify the original
	var result := dna.duplicate()
	Utils.put_if_absent(result, "line_rgb", "6c4331")
	Utils.put_if_absent(result, "body_rgb", "b23823")
	Utils.put_if_absent(result, "belly_rgb", "ffa86d")
	Utils.put_if_absent(result, "cloth_rgb", "282828")
	Utils.put_if_absent(result, "hair_rgb", "f1e398")
	Utils.put_if_absent(result, "eye_rgb", "282828 dedede")
	Utils.put_if_absent(result, "horn_rgb", "f1e398")
	
	if ResourceCache.minimal_resources:
		# avoid loading unnecessary resources for things like the level editor
		pass
	else:
		for allele in BODY_PART_ALLELES:
			Utils.put_if_absent(result, allele, Utils.weighted_rand_value(allele_weights(result, allele)))
	return result


"""
Returns a human-readable allele name for use in the editor.
"""
func allele_name(key: String, value: String) -> String:
	var combo_key := "%s-%s" % [key, value]
	return ALLELE_NAMES.get(combo_key, combo_key)


"""
Returns a unique list of values for the specified allele.
"""
func unique_allele_values(property: String) -> Array:
	var result := []
	
	if property in COLOR_ALLELES:
		# color palette properties
		for palette in CREATURE_PALETTES:
			result.append(palette[property])
	else:
		# other properties
		match property:
			"body": result = ["1", "2"]
			"head": result = ["1", "2", "3", "4", "5"]
			"belly": result = ["0", "1", "2"]
			"cheek": result = ["0", "1", "2", "3", "4"]
			"ear": result = ["1", "2", "3", "4", "5", "6"]
			"eye": result = ["1", "2", "3", "4"]
			"horn": result = ["0", "1", "2"]
			"mouth": result = ["1", "2", "3", "4"]
			"nose": result = ["0", "1", "2", "3"]
			"hair": result = ["0", "1", "2"]
			"collar": result = ["0", "1", "2", "3"]
			"tail": result = ["0", "1", "2", "3", "4", "5", "6"]
	
	return result


"""
Returns a random palette from a list of preset palettes.
"""
func random_creature_palette() -> Dictionary:
	return Utils.rand_value(CREATURE_PALETTES).duplicate()


func invalid_allele_value(dna: Dictionary, property: String, value: String) -> String:
	var invalid_property: String
	for other_property in BODY_PART_ALLELES:
		if other_property == property:
			continue
		var other_value: String = dna.get(other_property, "0")
		if _get_allele_combo_adjustment(property, value, other_property, other_value) < -50:
			invalid_property = other_property
			break
	return invalid_property


"""
Returns a dictionary with weights for the specified allele.

Some values are more common than others, and some combinations are more common as well.
"""
func allele_weights(dna: Dictionary, property: String) -> Dictionary:
	var result := {}
	
	if property in COLOR_ALLELES:
		for allele_value in unique_allele_values(property):
			result[allele_value] = 1.0
	elif property in BODY_PART_ALLELES:
		for allele_value in unique_allele_values(property):
			result[allele_value] = _get_allele_weight(property, allele_value)
		var invalid_allele_values := []
		for allele_value in result:
			var total_score := 0.0
			for other_property in BODY_PART_ALLELES:
				if other_property == property:
					continue
				var other_value: String = dna.get(other_property, "0")
				total_score += _get_allele_combo_adjustment(property, allele_value, other_property, other_value)
			if total_score < -50:
				invalid_allele_values.append(allele_value)
			elif total_score < 0:
				# chance decreases to 50%, 33%, 25%...
				result[allele_value] /= (1 - total_score)
			else:
				# chance increases to 200%, 300%, 400%...
				result[allele_value] += total_score
		for allele_value in invalid_allele_values:
			result.erase(allele_value)
	
	return result


func _set_allele_weight(key: String, value: String, weight: float) -> void:
	_allele_weights[_allele_value_key(key, value)] = weight


func _get_allele_weight(key: String, value: String) -> float:
	return _allele_weights.get(_allele_value_key(key, value), 1.0)


func _set_allele_combo_adjustment(key1: String, value1: String, key2: String, value2: String, score: int) -> void:
	var combo_key := _allele_combo_key(key1, value1, key2, value2)
	_allele_combo_adjustments[combo_key] = score


func _get_allele_combo_adjustment(key1: String, value1: String, key2: String, value2: String) -> int:
	var combo_key := _allele_combo_key(key1, value1, key2, value2)
	return _allele_combo_adjustments.get(combo_key, 0)


func _allele_combo_key(key1: String, value1: String, key2: String, value2: String) -> String:
	var combo_key: String
	if key1 <= key2:
		combo_key = "%s-%s-%s-%s" % [key1, value1, key2, value2]
	else:
		combo_key = "%s-%s-%s-%s" % [key2, value2, key1, value1]
	return combo_key


func _allele_value_key(key: String, value: String) -> String:
	return "%s-%s" % [key, value]
