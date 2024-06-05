tool
extends Node
## Manages data for the creature editor. This includes the list of category names, which buttons should be shown,
## their positions, and when those buttons should be enabled or disabled.

const CATEGORIES_PATH := "res://assets/main/editor/creature/creature-editor-categories.json"

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
