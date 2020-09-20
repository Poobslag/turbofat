class_name CreatureDef
"""
Stores information about a creature such as their name, appearance, and dialog.
"""

const CREATURE_DATA_VERSION := "19a3"

# creature's id, e.g 'boatricia'
var creature_id: String

# creature's name, e.g 'Boatricia'
var creature_name: String

# a shortened version of the creature's name, for use in conversation
var creature_short_name: String

# defines the creature's appearance such as eye color and mouth shape
var dna: Dictionary

# defines the chat window's appearance, such as 'blue', 'soccer balls' and 'giant'.
var chat_theme_def: Dictionary

# key: dialog key
# value: chat tree json
var dialog: Dictionary

# dictionaries containing metadata for which dialog sequences should be launched in which order
var chat_selectors: Array

# how fat the creature's body is; 5.0 = 5x normal size
var fatness := 1.0

func from_json_dict(json: Dictionary) -> void:
	match json.get("version"):
		CREATURE_DATA_VERSION:
			# latest version
			pass
		"187d":
			if json.has("dna"):
				json.get("dna")["bellybutton"] = "0"
		"170e":
			# old save data might have an empty array; we need to overwrite this with an empty dictionary to avoid
			# type issues
			json["dialog"] = {}
		_:
			push_warning("Unrecognized creature data version: '%s'" % json.get("version"))
	
	creature_id = json.get("id", "")
	creature_name = json.get("name", "")
	creature_short_name = json.get("short_name", NameUtils.sanitize_short_name(creature_name))
	dna = json.get("dna", {})
	chat_theme_def = json.get("chat_theme_def", {})
	dialog = json.get("dialog", {})
	chat_selectors = json.get("chat_selectors", [])
	fatness = json.get("fatness", 1.0)


func to_json_dict() -> Dictionary:
	return {
		"version": CREATURE_DATA_VERSION,
		"id": creature_id,
		"name": creature_name,
		"short_name": creature_short_name,
		"dna": dna,
		"chat_theme_def": chat_theme_def,
		"dialog": dialog,
		"chat_selectors": chat_selectors,
		"fatness": fatness,
	}
