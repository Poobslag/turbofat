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
	{"line_rgb": "6c4331", "body_rgb": "b23823", "belly_rgb": "c9442a",
		"hair_rgb": "af845c", "eye_rgb": "282828 dedede", "horn_rgb": "f1e398",
		"cloth_rgb": "282828", "glass_rgb": "72d2eb", "plastic_rgb": "292828"}, # dark red
	{"line_rgb": "6c4331", "body_rgb": "f9bb4a", "belly_rgb": "fff4b2",
		"hair_rgb": "b47922", "eye_rgb": "f9a74c fff6df", "horn_rgb": "b3b2b5",
		"cloth_rgb": "f9a74c", "glass_rgb": "1d1d1d", "plastic_rgb": "f55034"}, # yellow
	{"line_rgb": "6c4331", "body_rgb": "41a740", "belly_rgb": "6dcb4c",
		"hair_rgb": "f1e398", "eye_rgb": "c09a2f f1e398", "horn_rgb": "f6ff8c",
		"cloth_rgb": "c09a2f", "glass_rgb": "c5d1d1", "plastic_rgb": "785537"}, # dark green
	{"line_rgb": "6c4331", "body_rgb": "b47922", "belly_rgb": "e6cf62",
		"hair_rgb": "7f8f69", "eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398",
		"cloth_rgb": "7d4c21", "glass_rgb": "777668", "plastic_rgb": "3b2416"}, # brown
	{"line_rgb": "6c4331", "body_rgb": "6f83db", "belly_rgb": "92d8e5",
		"hair_rgb": "47465f", "eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398",
		"cloth_rgb": "374265", "glass_rgb": "202020", "plastic_rgb": "b5c4f2"}, # light blue

	{"line_rgb": "6c4331", "body_rgb": "a854cb", "belly_rgb": "bb73dd",
		"hair_rgb": "f1e398", "eye_rgb": "924a51 ffe8eb", "horn_rgb": "e38a61",
		"cloth_rgb": "4fa94e", "glass_rgb": "4e50a9", "plastic_rgb": "42a5be"}, # purple
	{"line_rgb": "6c4331", "body_rgb": "f57e7d", "belly_rgb": "fde8c9",
		"hair_rgb": "f57e7d", "eye_rgb": "7ac252 e9f4dc", "horn_rgb": "f1e398",
		"cloth_rgb": "7ac252", "glass_rgb": "d96079", "plastic_rgb": "6f6168"}, # light red
	{"line_rgb": "6c4331", "body_rgb": "e17827", "belly_rgb": "dbbd9e",
		"hair_rgb": "dfca7a", "eye_rgb": "1492d6 33d4f0", "horn_rgb": "e9ebf0",
		"cloth_rgb": "4aadc5", "glass_rgb": "c1ccce", "plastic_rgb": "3d3c3b"}, # fox orange
	{"line_rgb": "6c4331", "body_rgb": "8fea40", "belly_rgb": "e8fa95",
		"hair_rgb": "b47922", "eye_rgb": "f5d561 fcf3cd", "horn_rgb": "d3af43",
		"cloth_rgb": "816327", "glass_rgb": "333332", "plastic_rgb": "e5e6e0"}, # light green
	{"line_rgb": "6c4331", "body_rgb": "70843a", "belly_rgb": "a9aa2f",
		"hair_rgb": "f1e398", "eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "eabc75",
		"cloth_rgb": "7d4c21", "glass_rgb": "1a1919", "plastic_rgb": "442f1c"}, # goblin green

	{"line_rgb": "6c4331", "body_rgb": "ffbfcb", "belly_rgb": "fffaff",
			"hair_rgb": "ffffff", "eye_rgb": "fad4cf ffffff", "horn_rgb": "fde9e7",
			"cloth_rgb": "fad4cf", "glass_rgb": "f66451", "plastic_rgb": "f5dfdc"}, # pink
	{"line_rgb": "6c4331", "body_rgb": "b1edee", "belly_rgb": "dff2f0",
			"hair_rgb": "ffffff", "eye_rgb": "c1f1f2 ffffff", "horn_rgb": "e1f9f9",
			"cloth_rgb": "c1f1f2", "glass_rgb": "5376f1", "plastic_rgb": "e3fbfc"}, # cyan
	{"line_rgb": "6c4331", "body_rgb": "f9f7d9", "belly_rgb": "d7c2a4",
			"hair_rgb": "ffffff", "eye_rgb": "91e6ff ffffff", "horn_rgb": "fdfcec",
			"cloth_rgb": "91e6ff", "glass_rgb": "728eff", "plastic_rgb": "e8e8fe"}, # white
	{"line_rgb": "41281e", "body_rgb": "1a1a1e", "belly_rgb": "65412e",
			"hair_rgb": "222222", "eye_rgb": "b8260b f45e40", "horn_rgb": "282828",
			"cloth_rgb": "b8260b", "glass_rgb": "2d2b2b", "plastic_rgb": "1f1f1f"}, # doberman black
	{"line_rgb": "6c4331", "body_rgb": "7a8289", "belly_rgb": "c8c3b5",
			"hair_rgb": "282828", "eye_rgb": "f5f0d1 ffffff", "horn_rgb": "1e1e1e",
			"cloth_rgb": "f5f0d1", "glass_rgb": "a9b2b2", "plastic_rgb": "1e1e1e"}, # grey

	{"line_rgb": "41281e", "body_rgb": "0b45a6", "belly_rgb": "eec086",
			"hair_rgb": "282828", "eye_rgb": "fad541 ffffff", "horn_rgb": "3c3b3b",
			"cloth_rgb": "fad541", "glass_rgb": "f5e194", "plastic_rgb": "282828"}, # dark blue
	{"line_rgb": "6c4331", "body_rgb": "db2a25", "belly_rgb": "ffcd78",
			"hair_rgb": "fbebe5", "eye_rgb": "5ba964 a9e0bb", "horn_rgb": "f4ffff",
			"cloth_rgb": "5ba964", "glass_rgb": "303630", "plastic_rgb": "66ca72"}, # dragon red
	{"line_rgb": "3c3c3d", "body_rgb": "725e96", "belly_rgb": "a9d252",
			"hair_rgb": "4f5651", "eye_rgb": "41f2ff d6ffff", "horn_rgb": "5a635d",
			"cloth_rgb": "41f2ff", "glass_rgb": "f9c0f9", "plastic_rgb": "de64d9"}, # dragon muted purple
	{"line_rgb": "41281e", "body_rgb": "3b494f", "belly_rgb": "7b8780",
			"hair_rgb": "1f1e1e", "eye_rgb": "ad1000 b73a36", "horn_rgb": "282727",
			"cloth_rgb": "ad1000", "glass_rgb": "690a00", "plastic_rgb": "252423"}, # gargoyle gray
	{"line_rgb": "6c4331", "body_rgb": "68d50a", "belly_rgb": "4baf20",
			"hair_rgb": "ffffed", "eye_rgb": "994dbd b392df", "horn_rgb": "d59fef",
			"cloth_rgb": "994dbd", "glass_rgb": "bac5d6", "plastic_rgb": "2b2a29"}, # hulk green

	{"line_rgb": "6c4331", "body_rgb": "9a7f5d", "belly_rgb": "c9dac6",
			"hair_rgb": "40342d", "eye_rgb": "25291b 606060", "horn_rgb": "b9b9b9",
			"cloth_rgb": "25291b", "glass_rgb": "1f201e", "plastic_rgb": "3b3724"}, # goblin tan
	{"line_rgb": "6c4331", "body_rgb": "ffb12c", "belly_rgb": "ffffff",
			"hair_rgb": "d37725", "eye_rgb": "cb5340 ffb597", "horn_rgb": "d2c9cd",
			"cloth_rgb": "cb5340", "glass_rgb": "dcd2d0", "plastic_rgb": "545050"}, # goober yellow
	{"line_rgb": "6c4331", "body_rgb": "fa5c2c", "belly_rgb": "ffd461",
			"hair_rgb": "3e7e32", "eye_rgb": "a7b958 ecf1bf", "horn_rgb": "529e43",
			"cloth_rgb": "a7b958", "glass_rgb": "a8db69", "plastic_rgb": "3d7d4b"}, # pumpkin orange
	{"line_rgb": "6c4331", "body_rgb": "99ffb5", "belly_rgb": "ffffff",
			"hair_rgb": "c5b871", "eye_rgb": "e9c57d ffffff", "horn_rgb": "f2f1f1",
			"cloth_rgb": "c49877", "glass_rgb": "2e2d2d", "plastic_rgb": "c49877"}, # angelic green
	{"line_rgb": "6c4331", "body_rgb": "23a2e3", "belly_rgb": "35e1e0",
			"hair_rgb": "477d5b", "eye_rgb": "415a73 c8cbd6", "horn_rgb": "ffe7e5",
			"cloth_rgb": "415a73", "glass_rgb": "bf3a3a", "plastic_rgb": "34373a"}, # fishy blue

	{"line_rgb": "6c4331", "body_rgb": "9d3df6", "belly_rgb": "e055a0",
			"hair_rgb": "28252a", "eye_rgb": "ecdf32 fcfcdb", "horn_rgb": "ac4577",
			"cloth_rgb": "ecdf32", "glass_rgb": "f4ec80", "plastic_rgb": "31302d"}, # mystic purple
	{"line_rgb": "6c4331", "body_rgb": "25785f", "belly_rgb": "876edb",
			"hair_rgb": "a6a1a1", "eye_rgb": "ff5c6f fff1f0", "horn_rgb": "bdc6c5",
			"cloth_rgb": "ff5c6f", "glass_rgb": "c42b3d", "plastic_rgb": "fc7d8c"}, # sea monster turquoise
	{"line_rgb": "6c4331", "body_rgb": "411c17", "belly_rgb": "e29b6e",
			"hair_rgb": "d98227", "eye_rgb": "ff912e ffd061", "horn_rgb": "c9d9bd",
			"cloth_rgb": "cb1b2e", "glass_rgb": "e7bb76", "plastic_rgb": "3f2a1f"}, # ogre brown
	{"line_rgb": "6c4331", "body_rgb": "dbffc8", "belly_rgb": "d69e63",
			"hair_rgb": "bdab30", "eye_rgb": "8bb253 ffebff", "horn_rgb": "caf877",
			"cloth_rgb": "95c152", "glass_rgb": "232521", "plastic_rgb": "5e885a"}, # celtic white
	{"line_rgb": "41281e", "body_rgb": "8f1b21", "belly_rgb": "838382",
			"hair_rgb": "1e1e1e", "eye_rgb": "546127 a8ad89", "horn_rgb": "2b2b2b",
			"cloth_rgb": "546127", "glass_rgb": "cbde88", "plastic_rgb": "546127"}, # heckraiser red

	{"line_rgb": "41281e", "body_rgb": "b24b10", "belly_rgb": "d58944",
			"hair_rgb": "2e261f", "eye_rgb": "7c4725 b8ad9f", "horn_rgb": "4c5245",
			"cloth_rgb": "ffd256", "glass_rgb": "ffd256", "plastic_rgb": "252422"}, # muddy orange
	{"line_rgb": "41281e", "body_rgb": "907027", "belly_rgb": "e5d6b7",
			"hair_rgb": "544e42", "eye_rgb": "d5c26a ffffff", "horn_rgb": "afa7ae",
			"cloth_rgb": "d5c26a", "glass_rgb": "232221", "plastic_rgb": "d5c26a"}, # golem bronze
	{"line_rgb": "41281e", "body_rgb": "48366e", "belly_rgb": "8b70a1",
			"hair_rgb": "3e2d62", "eye_rgb": "121011 4d6c6a", "horn_rgb": "828863",
			"cloth_rgb": "121011", "glass_rgb": "331d4b", "plastic_rgb": "121011"}, # grape jelly
	{"line_rgb": "41281e", "body_rgb": "2c4b9e", "belly_rgb": "c78e69",
			"hair_rgb": "e7b658", "eye_rgb": "a58900 e3d48e", "horn_rgb": "98a49a",
			"cloth_rgb": "a58900", "glass_rgb": "282514", "plastic_rgb": "a59131"}, # bold blue
	{"line_rgb": "41281e", "body_rgb": "025d28", "belly_rgb": "67aa0f",
			"hair_rgb": "2c3c2b", "eye_rgb": "ccd44d ffffd9", "horn_rgb": "959f78",
			"cloth_rgb": "ccd44d", "glass_rgb": "508e44", "plastic_rgb": "d4aa4d"}, # broccoli green

	{"line_rgb": "41281e", "body_rgb": "664437", "belly_rgb": "eaf9c7",
			"hair_rgb": "c58549", "eye_rgb": "74a27f fffaff", "horn_rgb": "e8a261",
			"cloth_rgb": "74a27f", "glass_rgb": "d2d1be", "plastic_rgb": "923b3b"}, # chocolate brown
	{"line_rgb": "6c4331", "body_rgb": "68af25", "belly_rgb": "8fff54",
			"hair_rgb": "587f44", "eye_rgb": "ce4224 fff6e3", "horn_rgb": "49663a",
			"cloth_rgb": "ce4224", "glass_rgb": "e65738", "plastic_rgb": "37302e"}, # tomato green
	{"line_rgb": "6c4331", "body_rgb": "f6bd44", "belly_rgb": "2a2a2a",
			"hair_rgb": "2c2c2c", "eye_rgb": "f0f3bd ffffff", "horn_rgb": "383838",
			"cloth_rgb": "f0f3bd", "glass_rgb": "f0f3bd", "plastic_rgb": "292927"}, # honeybee yellow
	{"line_rgb": "3c3c3d", "body_rgb": "171419", "belly_rgb": "b0b4d1",
			"hair_rgb": "b0b4d1", "eye_rgb": "4e8eee f8ffff", "horn_rgb": "c4c4c5",
			"cloth_rgb": "4e8eee", "glass_rgb": "1c1c1d", "plastic_rgb": "abb7f5"}, # penguin black
	{"line_rgb": "3c3c3d", "body_rgb": "e63f2d", "belly_rgb": "f77429",
			"hair_rgb": "3b5854", "eye_rgb": "f2c12a ffffa2", "horn_rgb": "486965",
			"cloth_rgb": "f2c12a", "glass_rgb": "fad669", "plastic_rgb": "f28c2a"}, # magma orange
]

# alleles corresponding to creature body parts
const BODY_PART_ALLELES := [
	"belly", "bellybutton", "body", "cheek", "collar", "ear", "eye", "hair",
	"head", "horn", "mouth", "nose", "tail", "accessory"
]

# alleles corresponding to creature colors
const COLOR_ALLELES := [
	"line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "glass_rgb", "plastic_rgb",
	"hair_rgb", "eye_rgb", "horn_rgb",
]

# all alleles, including body parts and colors
const ALLELES := BODY_PART_ALLELES + COLOR_ALLELES

# body part names shown to the player
const ALLELE_NAMES := {
	"accessory-0": "(none)",
	"accessory-1": "Shades",
	"accessory-2": "Glasses",
	"accessory-3": "Headphones",
	"accessory-4": "Headbones",
	"accessory-5": "Dead Mouse",
	
	"belly-0": "(none)",
	"belly-1": "Full",
	"belly-2": "Half",
	
	"bellybutton-0": "(none)",
	"bellybutton-1": "Innie",
	"bellybutton-2": "Outie",
	"bellybutton-3": "Stabby",
	"bellybutton-4": "Puffy",
	
	"body-1": "Koala",
	"body-2": "Squirrel",
	
	"cheek-0": "Round",
	"cheek-1": "Razor Sharp",
	"cheek-2": "Fluffy Tuft",
	"cheek-3": "Fish Whisker",
	"cheek-4": "Fat Whisker",
	
	"collar-0": "(none)",
	"collar-1": "Handkerchief",
	"collar-2": "Bushy",
	"collar-3": "Scruffy",
	"collar-4": "Inner Tube",
	"collar-5": "Neckfro",
	
	"ear-0": "(none)",
	"ear-1": "Sausage",
	"ear-2": "Cannon",
	"ear-3": "Dangler",
	"ear-4": "Nubble",
	"ear-5": "Pancake",
	"ear-6": "Chonky Cat",
	"ear-7": "Darkling",
	"ear-8": "Darklord",
	"ear-9": "Beastie",
	"ear-10": "Dragon",
	"ear-11": "Orc",
	"ear-12": "Goblin",
	"ear-13": "Short Hare",
	"ear-14": "Long Hare",
	"ear-15": "Long Long Hare",
	
	"eye-0": "(none)",
	"eye-1": "Giant",
	"eye-2": "Zen",
	"eye-3": "Decaf",
	"eye-4": "Ping Pong",
	"eye-5": "Multi",
	"eye-6": "Hollow",
	"eye-7": "Skeleton",
	"eye-8": "Plug",
	
	"hair-0": "(none)", 
	"hair-1": "Lion", 
	"hair-2": "Shaggy",
	
	"head-1": "(none)",
	"head-2": "Chimp",
	"head-3": "Hedgehog",
	"head-4": "Raccoon",
	"head-5": "Marmoset",
	
	"horn-0": "(none)",
	"horn-1": "Straw Hole",
	"horn-2": "Rhino Nub",
	
	"mouth-0": "(none)",
	"mouth-1": "Ant",
	"mouth-2": "Illithid",
	"mouth-3": "Imp",
	"mouth-4": "Crow",
	"mouth-5": "Shark",
	"mouth-6": "Grumpy Cat",
	"mouth-7": "Turtle",
	
	"nose-0": "(none)",
	"nose-1": "Nub",
	"nose-2": "Speck",
	"nose-3": "Goblin",
	"nose-4": "Iguana",
	
	"tail-0": "(none)",
	"tail-1": "Kind Cat",
	"tail-2": "Cute Cat",
	"tail-3": "Devil",
	"tail-4": "Bunny",
	"tail-5": "Soft Squirrel",
	"tail-6": "Fancy Squirrel",
	"tail-7": "Lizard",
}

# key: alleles
# value: positive numeric weights [0.0-100.0]. high values for common alleles
var _allele_weights := {}

# key: allele combo key, such as 'mouth-1-nose-2'
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
	
	for nose in ["1", "2", "3", "4"]:
		# creatures with beak can NEVER have nose
		_set_allele_combo_adjustment("mouth", "4", "nose", nose, -999)
	
	# goblin nose goes behind skull mask in a weird way
	_set_allele_combo_adjustment("accessory", "4", "nose", "3", -999)
	
	# fat whisker goes behind orc ear in a weird way
	_set_allele_combo_adjustment("cheek", "4", "ear", "11", -999)
	
	# zen eyes aren't very visible through masks
	_set_allele_combo_adjustment("accessory", "4", "eye", "2", -2)
	_set_allele_combo_adjustment("accessory", "5", "eye", "2", -2)
	
	# bird beaks and goblin ears look a little strange together
	_set_allele_combo_adjustment("mouth", "4", "ear", "11", -2)
	_set_allele_combo_adjustment("mouth", "4", "ear", "12", -2)
	
	# birds and turtles often don't have ears
	_set_allele_combo_adjustment("mouth", "4", "ear", "0", 2)
	_set_allele_combo_adjustment("mouth", "7", "ear", "0", 2)
	
	_set_allele_weight("accessory", "0", 12.0)
	
	_set_allele_weight("belly", "0", 2.0)
	_set_allele_weight("belly", "1", 2.0)
	_set_allele_weight("bellybutton", "0", 8.0)
	_set_allele_weight("bellybutton", "1", 2.0)
	_set_allele_weight("body", "1", 6.0)
	_set_allele_weight("collar", "0", 8.0)
	_set_allele_weight("collar", "1", 2.0)
	_set_allele_weight("ear", "0", 0.2)
	_set_allele_weight("ear", "1", 3.0)
	_set_allele_weight("ear", "4", 2.0)
	
	_set_allele_weight("eye", "0", 0.1)
	_set_allele_weight("eye", "1", 3.0)
	
	# skeletons are scary! let's not spook people too often
	_set_allele_weight("eye", "6", 0.4)
	_set_allele_weight("eye", "7", 0.6)
	
	_set_allele_weight("eye", "1", 3.0)
	_set_allele_weight("hair", "0", 5.0)
	_set_allele_weight("head", "1", 6.0)
	_set_allele_weight("horn", "0", 3.0)
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
	
	var new_palette: Dictionary = DnaUtils.random_creature_palette()
	for allele in COLOR_ALLELES:
		Utils.put_if_absent(result, allele, new_palette[allele])
	
	if ResourceCache.minimal_resources:
		# avoid loading unnecessary resources for things like the level editor
		pass
	else:
		var alleles := BODY_PART_ALLELES.duplicate()
		alleles.shuffle()
		for allele in alleles:
			Utils.put_if_absent(result, allele, Utils.weighted_rand_value(allele_weights(result, allele)))
		Utils.put_if_absent(result, "emote-eye", "0" if result.get("eye", "0") == "0" else "1")
	return result


"""
Returns a dna dictionary containing sensible random values.

This includes an aesthetically pleasing palette and body parts that look good together.
"""
func random_dna() -> Dictionary:
	return fill_dna({})


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
			"accessory": result = ["0", "1", "2", "3", "4", "5"]
			"belly": result = ["0", "1", "2"]
			"bellybutton": result = ["0", "1", "2", "3", "4"]
			"body": result = ["1", "2"]
			"cheek": result = ["0", "1", "2", "3", "4"]
			"collar": result = ["0", "1", "2", "3", "4", "5"]
			"ear": result = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
			"eye": result = ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
			"hair": result = ["0", "1", "2"]
			"head": result = ["1", "2", "3", "4", "5"]
			"horn": result = ["0", "1", "2"]
			"mouth": result = ["1", "2", "3", "4", "5", "6", "7"]
			"nose": result = ["0", "1", "2", "3", "4"]
			"tail": result = ["0", "1", "2", "3", "4", "5", "6", "7"]
	
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


"""
A key corresponding to an allele combination, such as 'bird beak with tiny eyes'.

A combination such as 'bird beak with tiny eyes' gets turned into a string key such as 'mouth-4-eye-2' which is
compatible with dictionaries.
"""
func _allele_combo_key(key1: String, value1: String, key2: String, value2: String) -> String:
	var combo_key: String
	if key1 <= key2:
		combo_key = "%s-%s-%s-%s" % [key1, value1, key2, value2]
	else:
		combo_key = "%s-%s-%s-%s" % [key2, value2, key1, value1]
	return combo_key


func _allele_value_key(key: String, value: String) -> String:
	return "%s-%s" % [key, value]
