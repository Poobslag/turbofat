class_name DnaUtils
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
	
	"body-1": "Koala",
	"body-2": "Squirrel",
	
	"cheek-0": "Round",
	"cheek-1": "Razor Sharp",
	"cheek-2": "Fluffy Tuft",
	"cheek-3": "Fish Whisker",
	"cheek-4": "Fat Whisker",
	
	"ear-0": "(none)",
	"ear-1": "Cattail",
	"ear-2": "Cannon",
	"ear-3": "Dangler",
	"ear-4": "Nubble",
	"ear-5": "Pancake",
	
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
	put_if_absent(result, "cloth_rgb", "282828")
	put_if_absent(result, "hair_rgb", "f1e398")
	put_if_absent(result, "eye_rgb", "282828 dedede")
	put_if_absent(result, "horn_rgb", "f1e398")
	
	if ResourceCache.minimal_resources:
		# avoid loading unnecessary resources for things like the level editor
		pass
	else:
		for allele in ["body", "head", "cheek", "ear", "eye", "horn", "mouth",
				"nose", "hair", "collar", "tail", "belly"]:
			put_if_absent(result, allele, Utils.rand_value(weighted_allele_values(result, allele)))
	return result


"""
Returns a human-readable allele name for use in the editor.
"""
static func allele_name(key: String, value: String) -> String:
	var combo_key := "%s-%s" % [key, value]
	return ALLELE_NAMES.get(combo_key, combo_key)


"""
Returns a unique list of values for the specified allele.
"""
static func unique_allele_values(property: String) -> Array:
	var result := []
	
	if property in ["line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb", "line_rgb"]:
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
			"ear": result = ["1", "2", "3", "4", "5"]
			"eye": result = ["1", "2", "3", "4"]
			"horn": result = ["0", "1", "2"]
			"mouth": result = ["1", "2", "3"]
			"nose": result = ["0", "1", "2", "3"]
			"hair": result = ["0", "1", "2"]
			"collar": result = ["0", "1", "2", "3"]
			"tail": result = ["0", "1", "2", "3", "4", "5", "6"]
	
	return result


"""
Returns a random palette from a list of preset palettes.
"""
static func random_creature_palette() -> Dictionary:
	return Utils.rand_value(CREATURE_PALETTES).duplicate()


"""
Returns a weighted list of values for the specified allele.

The values are weighted to make some values more common than others. The values uses the creature's current dna to
avoid combining creature parts that don't look good together.
"""
static func weighted_allele_values(dna: Dictionary, property: String) -> Array:
	var result := []
	
	if property in ["line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb", "line_rgb"]:
		# color palette properties
		for palette in CREATURE_PALETTES:
			result.append(palette[property])
	else:
		# other properties
		match property:
			"body": result = ["1", "1", "1", "1", "1", "1", "2"]
			"head": result = ["1", "1", "1", "1", "1", "1", "2", "3", "4", "5"]
			"belly": result = ["0", "0", "1", "1", "2"]
			"cheek": result = ["0", "0", "0", "1", "1", "2", "2", "3", "4", "4"]
			"ear": result = ["1", "1", "1", "2", "3", "4", "4", "5"]
			"eye": result = ["1", "1", "1", "2", "3", "4"]
			"horn": result = ["0", "0", "0", "1", "2"]
			"mouth":
				result = ["1", "1", "2", "3", "3"]
				if dna.has("nose") and dna["nose"] != "0" \
						or dna.has("hair") and dna["hair"] != "0" \
						or dna.has("mouth") and dna["mouth"] in ["2", "3"]:
					# creatures with nose/hair are less likely to have beaky mouth
					result += ["3", "3", "3", "3", "3"]
			"nose":
				result = ["0", "1", "1", "2", "2", "3", "3"]
				if dna.has("mouth") and dna["mouth"] in ["1", "2"]:
					# creatures with beaky mouths are less likely to have nose
					result += ["0", "0", "0", "0", "0", "0", "0"]
			"hair":
				result = ["0", "0", "0", "0", "0", "1", "2"]
				if dna.has("mouth") and dna["mouth"] in ["1", "2"]:
					# creatures with beaky mouths are less likely to have hair
					result += ["0", "0", "0", "0", "0", "0", "0"]
			"collar":
				result = ["0", "0", "0", "0", "0", "1", "1", "2", "3"]
				if dna.has("mouth") and dna["mouth"] in ["1", "2"]:
					# creatures with beaky mouths are less likely to have a fuzzy neck
					result += ["0", "0", "0", "0", "0", "0", "0", "1", "1"]
			"tail":
				result = ["0", "0", "0", "0", "0", "0", "0", "0", "1", "2", "3", "4", "5", "6"]
	
	return result
