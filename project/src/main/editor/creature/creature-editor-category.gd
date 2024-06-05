class_name CreatureEditorCategory
## Stores information about a creature editor category.
##
## This includes details like its name, which buttons should be shown, their positions, and when those buttons should
## be enabled or disabled.

## The category's name, such as 'Eyes'
var name: String

## List of String alleles and allele combos, such as "hair_0" or "body_1 belly_2"
var allele_combos: Array

## List of String color properties such as "cloth_rgb"
var color_properties: Array

## List of Operation instances describing unique operations for this category, such as "Save" or "Name"
var operations: Array

## List of conditions for which color buttons are enabled and disabled.
##
## key: (String) String color property such as "cloth_rgb"
## value: (Array, String) List of String alleles such as "hair_0" which cause the color button to be enabled. If
## 	empty, the button will always be enabled.
var color_property_enabled_if: Dictionary

func from_json_dict(json: Dictionary) -> void:
	name = json.get("name", "")
	allele_combos = json.get("allele_combos", [])
	color_properties = []
	
	color_property_enabled_if = {}
	for color in json.get("colors", []):
		var color_strings: Array = color.split(" ")
		color_properties.append(color_strings[0])
		for i in range(1, color_strings.size()):
			if not color_property_enabled_if.has(color_strings[0]):
				color_property_enabled_if[color_strings[0]] = []
			color_property_enabled_if[color_strings[0]].append(color_strings[i])
	
	operations = []
	for operation_json in json.get("operations", []):
		var operation := Operation.new()
		operation.from_json_dict(operation_json)
		operations.append(operation)
