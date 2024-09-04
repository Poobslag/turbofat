class_name CreatureDef
## Stores information about a creature such as their name, appearance, and chat lines.

## default chat theme when starting a new game
const DEFAULT_CHAT_THEME_JSON := {
	"accent_scale": 1.33,
	"accent_swapped": true,
	"accent_texture": 13,
	"color": "b23823"
}

## default creature appearance when starting a new game
const DEFAULT_DNA := {
	"accessory": "0",
	"belly": "1",
	"belly_rgb": "c9442a",
	"bellybutton": "0",
	"body": "1",
	"body_rgb": "b23823",
	"cheek": "3",
	"cloth_rgb": "282828",
	"collar": "0",
	"ear": "1",
	"eye": "1",
	"eye_rgb_0": "282828",
	"eye_rgb_1": "dedede",
	"glass_rgb": "282828",
	"hair": "0",
	"hair_rgb": "f1e398",
	"head": "1",
	"horn": "1",
	"horn_rgb": "f1e398",
	"line_rgb": "6c4331",
	"mouth": "2",
	"nose": "0",
	"plastic_rgb": "282828",
	"tail": "0",
}

## default name when starting a new game
const DEFAULT_NAME := "Spira"

## creature's id, e.g 'boatricia'
var creature_id: String

## creature's name, e.g 'Boatricia'
var creature_name: String

## shortened version of the creature's name, for use in conversation
var creature_short_name: String

## defines the creature's appearance such as eye color and mouth shape
var dna: Dictionary

## dictionaries containing metadata for which chat sequences should be launched in which order
var chat_selectors: Array

## defines the chat window's appearance, such as 'blue', 'soccer balls' and 'giant'.
var chat_theme := ChatTheme.new()

## Boolean condition which enables this creature to appear as a random chef, such as
## 'chat_finished chat/career/marsh/030_c_end'
##
## 'false' if they should never be a chef.
var chef_if := "true"

## Boolean condition which enables this creature to appear as a random customer, such as
## 'chat_finished chat/career/marsh/030_c_end'
##
## 'false' if they should never be a customer.
var customer_if := "true"

## how fast the creature should lose weight between puzzles. 0.25x = four times slower than normal.
var metabolism_scale := 1.0

## how fat the creature's body is; 5.0 = 5x normal size
var min_fatness := 1.0

## how fast the creature should gain weight during a puzzle. 4.0x = four times faster than normal.
var weight_gain_scale := 1.0

func from_json_dict(json: Dictionary) -> void:
	var version: String = json.get("version", "")
	while version != Creatures.CREATURE_DATA_VERSION:
		match version:
			"375c":
				if json.has("dna"):
					if json["dna"].has("eye_rgb"):
						json["dna"]["eye_rgb_0"] = json["dna"]["eye_rgb"].split(" ")[0]
						json["dna"]["eye_rgb_1"] = json["dna"]["eye_rgb"].split(" ")[1]
						json["dna"].erase("eye_rgb")
				version = "5923"
			"19dd":
				if json.has("chat_theme_def"):
					json["chat_theme"] = json["chat_theme_def"]
					json.erase("chat_theme_def")
				version = "375c"
			"19a3":
				if json.has("dna"):
					json.get("dna")["accessory"] = "0"
				version = "19dd"
			"187d":
				if json.has("dna"):
					json.get("dna")["bellybutton"] = "0"
				version = "19a3"
			"170e":
				# old save data might have an empty array; we need to overwrite this with an empty dictionary to avoid
				# type issues
				json["chat"] = {}
				version = "187d"
			_:
				push_warning("Unrecognized creature data version: '%s'" % json.get("version"))
				break
	
	creature_id = json.get("id", "")
	creature_name = json.get("name", DEFAULT_NAME)
	creature_short_name = json.get("short_name", NameUtils.sanitize_short_name(creature_name))
	dna = json.get("dna", {})
	chat_selectors = json.get("chat_selectors", [])
	chat_theme.from_json_dict(json.get("chat_theme", DEFAULT_CHAT_THEME_JSON))
	chef_if = json.get("chef_if", "true")
	customer_if = json.get("customer_if", "true")
	metabolism_scale = json.get("metabolism_scale", 1.0)
	min_fatness = json.get("fatness", 1.0)
	weight_gain_scale = json.get("weight_gain_scale", 1.0)
	
	# populate default values when importing incomplete json
	for allele in DnaUtils.ALLELES:
		Utils.put_if_absent(dna, allele, DEFAULT_DNA[allele])


func to_json_dict() -> Dictionary:
	var result := {}
	result["version"] = Creatures.CREATURE_DATA_VERSION
	if creature_id: result["id"] = creature_id
	if creature_name: result["name"] = creature_name
	if creature_short_name: result["short_name"] = creature_short_name
	if dna: result["dna"] = dna
	if chat_selectors: result["chat_selectors"] = chat_selectors
	var chat_theme_json := chat_theme.to_json_dict()
	if chat_theme_json: result["chat_theme"] = chat_theme_json
	if not chef_if in ["True", "TRUE", "true", "1"]: result["chef_if"] = chef_if
	if not customer_if in ["True", "TRUE", "true", "1"]: result["customer_if"] = customer_if
	if metabolism_scale != 1.0: result["metabolism_scale"] = metabolism_scale
	if min_fatness != 1.0: result["fatness"] = min_fatness
	if weight_gain_scale != 1.0: result["weight_gain_scale"] = weight_gain_scale
	
	return result


## Loads creature data from a json path. Substitutes any missing data.
##
## Returns:
## 	The newly loaded creature data, or 'null' if there was a problem loading the json data.
func from_json_path(path: String) -> CreatureDef:
	var result := self
	var creature_def_text: String = FileUtils.get_file_as_text(path)
	var parsed = parse_json(creature_def_text)
	if typeof(parsed) == TYPE_DICTIONARY:
		var json_creature_def: Dictionary = parsed
		from_json_dict(json_creature_def)
	else:
		result = null
	return result


## Changes the creature's name, and derives a new short name and creature id from their new name.
##
## A creature's name shouldn't change during regular gameplay. This is only for the creature editor and for other
## randomly generated creatures.
func rename(new_creature_name: String) -> void:
	creature_name = new_creature_name
	creature_short_name = NameUtils.sanitize_short_name(creature_name)


## Returns true if this creature can show up as a random customer.
func is_chef() -> bool:
	return BoolExpressionEvaluator.evaluate(chef_if)


## Returns true if this creature can show up as a random customer.
func is_customer() -> bool:
	return BoolExpressionEvaluator.evaluate(customer_if)
