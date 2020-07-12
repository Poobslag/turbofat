class_name CreatureDef
"""
Stores information about a creature such as their name, appearance, and dialog.
"""

# creature's id, e.g 'boatricia'
var creature_id: String

# creature's name, e.g 'Boatricia'
var creature_name: String

# the path with the json containing the creature's dialog
var chat_path: String

# defines the creature's appearance such as eye color and mouth shape
var dna: Dictionary

# defines the chat window's appearance, such as 'blue', 'soccer balls' and 'giant'.
var chat_theme_def: Dictionary

# filenames containing dialog
var dialog: Array

# how fat the creature's body is; 5.0 = 5x normal size
var fatness := 1.0

func from_json_dict(json: Dictionary) -> void:
	if json.get("version") != "170e":
		push_warning("Unrecognized creature data version: '%s'" % json.get("version"))
	creature_id = json.get("id", "")
	creature_name = json.get("name", "")
	dna = json.get("dna", {})
	chat_theme_def = json.get("chat_theme_def", {})
	dialog = json.get("dialog", [])
	fatness = json.get("fatness", 1.0)
	if dialog:
		chat_path = "res://assets/main/dialog/%s/%s.json" % [creature_id, dialog[0]]
