tool
class_name CreatureEditorLibrary
extends Node
## Manages data for the creature editor. This includes the list of category names, which buttons should be shown,
## their positions, and when those buttons should be enabled or disabled.

const CATEGORIES_PATH := "res://assets/main/editor/creature/creature-editor-categories.json"

## key: (String) color property
## value: (Array, Color) color presets to show in the creature editor
const COLOR_PRESETS_BY_COLOR_PROPERTY := {
	"belly_rgb": [
			Color("c9442a"), Color("fff4b2"), Color("6dcb4c"), Color("e6cf62"), Color("92d8e5"), Color("bb73dd"),
			Color("fde8c9"), Color("dbbd9e"), Color("e8fa95"), Color("a9aa2f"), Color("fffaff"), Color("dff2f0"),
			Color("65412e"), Color("eec086"), Color("ffcd78"), Color("a9d252"), Color("7b8780"), Color("4baf20"),
			Color("c9dac6"), Color("35e1e0"), Color("e055a0"), Color("876edb"), Color("e29b6e"), Color("d58944"),
			Color("e5d6b7"), Color("8b70a1"), Color("c78e69"), Color("67aa0f"), Color("8fff54"), Color("2a2a2a"),
			Color("b0b4d1"), Color("f77429"), Color("8f5786"), Color("4e4f4f"), Color("601000"), Color("6a6994"),
			Color("fed73d"), Color("fe5911"), Color("b72226"), Color("af361f"), Color("0094ea"), Color("f6e183"),
			Color("afc09a"), Color("de3021"), Color("8c9537"), Color("000000"), Color("f74b29")
		],
	"body_rgb": [
			Color("b23823"), Color("f9bb4a"), Color("41a740"), Color("b47922"), Color("6f83db"), Color("a854cb"),
			Color("f57e7d"), Color("e17827"), Color("8fea40"), Color("70843a"), Color("ffbfcb"), Color("b1edee"),
			Color("f9f7d9"), Color("1a1a1e"), Color("7a8289"), Color("0b45a6"), Color("db2a25"), Color("725e96"),
			Color("3b494f"), Color("68d50a"), Color("9a7f5d"), Color("ffb12c"), Color("fa5c2c"), Color("99ffb5"),
			Color("23a2e3"), Color("9d3df6"), Color("25785f"), Color("411c17"), Color("dbffc8"), Color("8f1b21"),
			Color("b24b10"), Color("907027"), Color("48366e"), Color("2c4b9e"), Color("025d28"), Color("664437"),
			Color("68af25"), Color("e63f2d"), Color("2e2e2e"), Color("a1c48c"), Color("ed9805"), Color("737373"),
			Color("772628"), Color("feceef"), Color("f5e0c6"), Color("f48fbc"), Color("5ac8e6"), Color("762c97"),
			Color("fbaf98"), Color("3d95f3"), Color("072b87"), Color("c7ac78"), Color("206fd5"), Color("e60202")
		],
	"cloth_rgb": [
			Color("282828"), Color("f9a74c"), Color("c09a2f"), Color("7d4c21"), Color("374265"), Color("4fa94e"),
			Color("7ac252"), Color("4aadc5"), Color("816327"), Color("fad4cf"), Color("c1f1f2"), Color("91e6ff"),
			Color("b8260b"), Color("f5f0d1"), Color("fad541"), Color("41f2ff"), Color("ad1000"), Color("994dbd"),
			Color("cb5340"), Color("a7b958"), Color("c49877"), Color("415a73"), Color("ecdf32"), Color("ff5c6f"),
			Color("cb1b2e"), Color("95c152"), Color("546127"), Color("d5c26a"), Color("121011"), Color("a58900"),
			Color("ccd44d"), Color("74a27f"), Color("ce4224"), Color("4e8eee"), Color("f2c12a"), Color("010000"),
			Color("a2a500"), Color("777d6f"), Color("88df41"), Color("fffb00"), Color("7786b3"), Color("9999f4"),
			Color("326728"), Color("ffa2ec"), Color("ffffff"), Color("ffb2ef"), Color("f05236"), Color("6e99ca"),
			Color("ff73e1"), Color("00e3d8"), Color("c421ac"), Color("280edd")
		],
	"eye_rgb_0": [
			Color("282828"), Color("f9a74c"), Color("c09a2f"), Color("7d4c21"), Color("374265"), Color("924a51"),
			Color("7ac252"), Color("1492d6"), Color("f5d561"), Color("fad4cf"), Color("c1f1f2"), Color("91e6ff"),
			Color("b8260b"), Color("f5f0d1"), Color("5ba964"), Color("41f2ff"), Color("ad1000"), Color("994dbd"),
			Color("cb5340"), Color("a7b958"), Color("e9c57d"), Color("415a73"), Color("ecdf32"), Color("ff5c6f"),
			Color("ff912e"), Color("8bb253"), Color("546127"), Color("d5c26a"), Color("121011"), Color("a58900"),
			Color("ccd44d"), Color("74a27f"), Color("ce4224"), Color("4e8eee"), Color("f2c12a"), Color("a6001e"),
			Color("f92a2a"), Color("13c39e"), Color("d25e00"), Color("87b8f6"), Color("866c95"), Color("000000"),
			Color("276127"), Color("54c35c"), Color("373535"), Color("8458b9"), Color("977968"), Color("f05236"),
			Color("084f10"), Color("7c5a46"), Color("9cc6ef"), Color("2c8619"), Color("f6f200")
		],
	"eye_rgb_1": [
			Color("dedede"), Color("fff6df"), Color("f1e398"), Color("e5cd7d"), Color("eaf2f4"), Color("ffe8eb"),
			Color("33d4f0"), Color("ffffff"), Color("f45e40"), Color("a9e0bb"), Color("d6ffff"), Color("b73a36"),
			Color("b392df"), Color("606060"), Color("ffb597"), Color("c8cbd6"), Color("ffd061"), Color("a8ad89"),
			Color("4d6c6a"), Color("ffffa2"), Color("20383f"), Color("ff9c9c"), Color("ec3333"), Color("617d7c"),
			Color("879f9d"), Color("daaed8"), Color("aba4ce"), Color("828fac")
		],
	"glass_rgb": [
			Color("72d2eb"), Color("1d1d1d"), Color("c5d1d1"), Color("777668"), Color("4e50a9"), Color("d96079"),
			Color("333332"), Color("f66451"), Color("5376f1"), Color("728eff"), Color("a9b2b2"), Color("f5e194"),
			Color("f9c0f9"), Color("690a00"), Color("dcd2d0"), Color("a8db69"), Color("bf3a3a"), Color("f4ec80"),
			Color("c42b3d"), Color("e7bb76"), Color("cbde88"), Color("ffd256"), Color("331d4b"), Color("508e44"),
			Color("e65738"), Color("f0f3bd"), Color("5d1b2b"), Color("ee2b91"), Color("d0f29f"), Color("000000"),
			Color("41b34e"), Color("b8d229"), Color("ffffff"), Color("ff8600")
		],
	"hair_rgb": [
			Color("af845c"), Color("b47922"), Color("f1e398"), Color("7f8f69"), Color("47465f"), Color("f57e7d"),
			Color("dfca7a"), Color("ffffff"), Color("222222"), Color("fbebe5"), Color("4f5651"), Color("40342d"),
			Color("d37725"), Color("3e7e32"), Color("c5b871"), Color("a6a1a1"), Color("d98227"), Color("bdab30"),
			Color("3e2d62"), Color("e7b658"), Color("2c3c2b"), Color("c58549"), Color("b0b4d1"), Color("3b5854"),
			Color("c4c4c5"), Color("73b693"), Color("f50808"), Color("4b974b"), Color("e8a261"), Color("596de6"),
			Color("d3a01c"), Color("000000"), Color("f05236"), Color("a05f35"), Color("696864"), Color("e5d6b7"),
			Color("f4351c")
		],
	"horn_rgb": [
			Color("f1e398"), Color("b3b2b5"), Color("f6ff8c"), Color("e38a61"), Color("e9ebf0"), Color("d3af43"),
			Color("eabc75"), Color("fde9e7"), Color("e1f9f9"), Color("fdfcec"), Color("282828"), Color("1e1e1e"),
			Color("3c3b3b"), Color("5a635d"), Color("d59fef"), Color("d2c9cd"), Color("529e43"), Color("ac4577"),
			Color("bdc6c5"), Color("c9d9bd"), Color("caf877"), Color("4c5245"), Color("afa7ae"), Color("828863"),
			Color("98a49a"), Color("e8a261"), Color("49663a"), Color("63426b"), Color("b47922"), Color("fecbd3"),
			Color("fa6400"), Color("090909"), Color("9787a2"), Color("404094")
		],
	"line_rgb": [
			Color("6c4331"), Color("41281e"), Color("3c3c3d")
		],
	"plastic_rgb": [
			Color("292828"), Color("f55034"), Color("785537"), Color("3b2416"), Color("b5c4f2"), Color("42a5be"),
			Color("6f6168"), Color("3d3c3b"), Color("e5e6e0"), Color("442f1c"), Color("f5dfdc"), Color("e3fbfc"),
			Color("1f1f1f"), Color("66ca72"), Color("de64d9"), Color("545050"), Color("3d7d4b"), Color("c49877"),
			Color("fc7d8c"), Color("5e885a"), Color("546127"), Color("d5c26a"), Color("121011"), Color("a59131"),
			Color("d4aa4d"), Color("923b3b"), Color("abb7f5"), Color("f28c2a"), Color("a3a2a6"), Color("79ff19"),
			Color("ae2222"), Color("e699a1")
		],
}

## Unique creature ID for the player's offscreen doppelganger in the creature editor.
##
## Changing a creature's appearance forces all their textures and shaders to regenerate, making them look strange for
## a moment. We apply these changes to a doppelganger and then swap them in after the changes are applied.
const PLAYER_SWAP_ID := "#player_swap#"

## List of Category instances with information about the creature editor categories.
var categories: Array = []

func _ready() -> void:
	_load_raw_json_data()


## Returns a category's name, such as "Eyes".
##
## Parameters:
## 	'category_index': Index of the category to return
##
## 	'default': Default value to return if the category index is invalid or the category does not have a name.
##
## Returns:
## 	The category's name, such as "Eyes".
func get_name_by_category_index(category_index: int, default: String = "") -> String:
	var result := default
	if category_index < categories.size() and categories[category_index].name:
		result = categories[category_index].name
	return result


## Returns a category's alleles or allele combos such as "hair_0" or "body_1 belly_2".
##
## These correspond to buttons on the left side of the creature editor.
##
## Parameters:
## 	'category_index': Index of the category to return
##
## Returns:
## 	List of String alleles or allele combos such as "hair_0" or "body_1 belly_2".
func get_allele_combos_by_category_index(category_index: int) -> Array:
	var result := []
	if category_index < categories.size():
		result = categories[category_index].allele_combos
	return result


## Returns a category's color properties such as "body_rgb".
##
## These correspond to buttons on the right side of the creature editor.
##
## Parameters:
## 	'category_index': Index of the category to return
##
## Returns:
## 	List of String color properties such as "body_rgb".
func get_color_properties_by_category_index(category_index: int) -> Array:
	var result := []
	if category_index < categories.size():
		result = categories[category_index].color_properties
	return result


## Returns the allele combos for which a color button should be enabled.
##
## Parameters:
## 	'category_index': Index of the category to return
##
## 	'color_property': Color property such as "body_rgb".
##
## Returns:
## 	List of String allele combos for which the specified color button should be enabled.
func get_color_property_enabled_if(category_index: int, color_property: String) -> Array:
	var result := []
	if category_index < categories.size():
		result = categories[category_index].color_property_enabled_if.get(color_property, [])
	return result


## Returns the Operation instances describing unique operations for this category, such as "Save" or "Name".
##
## Parameters:
## 	'category_index': Index of the category to return
##
## Returns:
## 	List of Operation instances describing unique operations for this category.
func get_operations_by_category_index(category_index: int) -> Array:
	var result := []
	if category_index < categories.size():
		result = categories[category_index].operations
	return result


func _load_raw_json_data() -> void:
	var categories_text := FileUtils.get_file_as_text(CATEGORIES_PATH)
	var categories_json: Dictionary = parse_json(categories_text)
	for category_json in categories_json.get("categories", []):
		var category := CreatureEditorCategory.new()
		category.from_json_dict(category_json)
		categories.append(category)


## Return the color presets to show in the creature editor.
##
## Parameters:
## 	'creature_dna': The dna for the creature whose presets should be shown.
##
## 	'color_property': The color property being edited, such as 'belly_rgb'.
static func get_color_presets(creature_dna: Dictionary, color_property: String) -> Array:
	var result := []
	result.append_array(COLOR_PRESETS_BY_COLOR_PROPERTY[color_property])
	
	match color_property:
		"line_rgb":
			result.append(DnaUtils.darker_line_color(Color(creature_dna["body_rgb"])))
		"hair_rgb":
			result.append(Color(creature_dna["body_rgb"]))
	
	return result
