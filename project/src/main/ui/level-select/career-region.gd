class_name CareerRegion
## Stores information about a block of levels for career mode.

## A chef/customer who appears in a career region.
class CreatureAppearance:
	## the id of the creature who appears
	var id: String
	
	## number in the range [0.0, 1.0] describing how often the creature appears
	var chance: float = 0.0
	
	## True if this creature is tightly coupled to specific levels.
	##
	## 'Quirky' creatures only appear when their levels are selected, and they never appear if their levels are not
	## selected.
	var quirky: bool = false
	
	func from_json_string(json: String) -> void:
		# parse a string like '(quirky) skins'
		if json.begins_with("(quirky)"):
			quirky = true
			json = StringUtils.substring_after(json, "(quirky)").strip_edges()
		
		# parse a string like 'bones 35%'
		if " " in json and json.ends_with("%"):
			var percent_string := StringUtils.substring_after_last(json, " ")
			# convert a string like '35%' to a number like 0.35
			chance = float(percent_string.rstrip("%")) / 100
			json = StringUtils.substring_before_last(json, " ")
		
		id = json


## A flag for regions where Fat Sensei is not following the player
const FLAG_NO_SENSEI := "no_sensei"

## A flag for regions where the player does not operate a restaurant.
const FLAG_NO_RESTAURANT := "no_restaurant"

## Chat key containing each region's prologue cutscene, which plays before any other cutscenes/levels
const PROLOGUE_CHAT_KEY_NAME := "prologue"

## Chat key containing each region's intro level cutscene, which plays before/after the intro level
const INTRO_LEVEL_CHAT_KEY_NAME := "intro_level"

## Chat key containing each region's boss level cutscene, which plays before/after the boss level
const BOSS_LEVEL_CHAT_KEY_NAME := "boss_level"

## Chat key containing each region's epilogue cutscene, which plays after all other cutscenes/levels
const EPILOGUE_CHAT_KEY_NAME := "epilogue"

## A human-readable region name, such as 'Lemony Thickets'
var name: String

## The smallest distance the player must travel to enter this region.
var start := 0

## The smallest distance the player must travel to exit this region.
##
## If the length is CareerData.MAX_DISTANCE_TRAVELLED, this region cannot be exited.
var length := 0

## The furthest distance the player can travel while remaining within this region.
##
## Immutable value. Calculated by combining 'start' and 'length'
var end := 0 setget ,get_end

## Final level which must be cleared to advance past this region.
var boss_level: CareerLevel

## CreatureAppearance instances for chefs who randomly show up in levels
var chefs := []

## CreatureAppearance instances for customers who randomly show up in levels
var customers := []

## A resource chat key prefix for cutscenes for this region, such as 'chat/career/marsh'
var cutscene_path: String

## Returns 'true' if this region has the specified flag.
##
## Regions can have flags for unusual qualities, such as regions where Fat Sensei is not following the player, or
## where the player does not operate a restaurant.
var flags: Dictionary = {}

## A human-readable icon name, such as 'forest' or 'cactus'
var icon_name: String

## First level which must be cleared before any other levels in this region.
var intro_level: CareerLevel

## List of CareerLevel instances which store career-mode-specific information about this region's levels.
var levels := []

## The minimum/maximum piece speeds for this region. Levels are adjusted to these piece speeds, if possible.
var min_piece_speed := "0"
var max_piece_speed := "0"

## CreatureAppearance instances for observers who randomly show up to watch levels
var observers := []

## A human-readable environment name, such as 'lemon' or 'marsh' for the overworld environment
var overworld_environment_name: String

## A human-readable environment name, such as 'lemon' or 'marsh' for the puzzle environment
var puzzle_environment_name: String

func from_json_dict(json: Dictionary) -> void:
	name = json.get("name", "")
	start = int(json.get("start", 0))
	
	if json.has("boss_level"):
		boss_level = CareerLevel.new()
		boss_level.from_json_dict(json.get("boss_level"))
	if json.has("chefs"):
		_parse_creature_appearances(json, "chefs")
	if json.has("customers"):
		_parse_creature_appearances(json, "customers")
	cutscene_path = json.get("cutscene_path", "")
	for flags_string in json.get("flags", []):
		flags[flags_string] = true
	icon_name = json.get("icon", "")
	if json.has("intro_level"):
		intro_level = CareerLevel.new()
		intro_level.from_json_dict(json.get("intro_level"))
	for level_json in json.get("levels", []):
		var level: CareerLevel = CareerLevel.new()
		level.from_json_dict(level_json)
		levels.append(level)
	if json.has("observers"):
		_parse_creature_appearances(json, "observers")
	overworld_environment_name = json.get("overworld_environment", "")
	var piece_speed_string: String = json.get("piece_speed", "0")
	if "-" in piece_speed_string:
		min_piece_speed = StringUtils.substring_before(piece_speed_string, "-")
		max_piece_speed = StringUtils.substring_after(piece_speed_string, "-")
	else:
		min_piece_speed = piece_speed_string
		max_piece_speed = piece_speed_string
	puzzle_environment_name = json.get("puzzle_environment", "")


func get_prologue_chat_key() -> String:
	return "%s/%s" % [cutscene_path, PROLOGUE_CHAT_KEY_NAME] if cutscene_path else ""


func get_intro_level_preroll_chat_key() -> String:
	return "%s/%s" % [cutscene_path, INTRO_LEVEL_CHAT_KEY_NAME] if cutscene_path else ""


func get_intro_level_postroll_chat_key() -> String:
	return "%s/%s_end" % [cutscene_path, INTRO_LEVEL_CHAT_KEY_NAME] if cutscene_path else ""


func get_boss_level_preroll_chat_key() -> String:
	return "%s/%s" % [cutscene_path, BOSS_LEVEL_CHAT_KEY_NAME] if cutscene_path else ""


func get_boss_level_postroll_chat_key() -> String:
	return "%s/%s_end" % [cutscene_path, BOSS_LEVEL_CHAT_KEY_NAME] if cutscene_path else ""


func get_epilogue_chat_key() -> String:
	return "%s/%s" % [cutscene_path, EPILOGUE_CHAT_KEY_NAME] if cutscene_path else ""


func get_end() -> int:
	return start + length - 1


## Returns 'true' if this region has a quirky chef with the specified id.
##
## 'Quirky chefs' are chefs which impose special rules on the player. They show up for their own levels, but they
## don't show up for random levels.
func has_quirky_chef(chef_id: String) -> bool:
	var result := false
	for chef_obj in chefs:
		var chef: CreatureAppearance = chef_obj
		if chef.id == chef_id:
			result = chef.quirky
			break
	return result


## Returns 'true' if this region has a quirky customer with the specified id.
##
## 'Quirky customers' are customers which impose special rules on the player. They show up for their own levels, but
## they don't show up for random levels.
func has_quirky_customer(customer_id: String) -> bool:
	var result := false
	for customer_obj in customers:
		var customer: CreatureAppearance = customer_obj
		if customer.id == customer_id:
			result = customer.quirky
			break
	return result


## Returns 'true' if this region has a quirky observer with the specified id.
##
## 'Quirky observers' are observers which impose special rules on the player. They show up for their own levels, but
## they don't show up for random levels.
func has_quirky_observer(observer_id: String) -> bool:
	var result := false
	for observer_obj in observers:
		var observer: CreatureAppearance = observer_obj
		if observer.id == observer_id:
			result = observer.quirky
			break
	return result


## Returns a random nonquirky chef from this region's list of chefs.
##
## Returns null if this region does not define any nonquirky chefs.
func random_chef() -> CreatureAppearance:
	return _random_creature(chefs)


## Returns a random nonquirky customer from this region's list of customers.
##
## Returns null if this region does not define any nonquirky customers.
func random_customer() -> CreatureAppearance:
	return _random_creature(customers)


## Returns a random nonquirky observer from this region's list of observers.
##
## Returns null if this region does not define any nonquirky observers.
func random_observer() -> CreatureAppearance:
	return _random_creature(observers)


## Returns 'true' if this region has the specified flag.
##
## Regions can have flags for unusual qualities, such as regions where Fat Sensei is not following the player, or
## where the player does not operate a restaurant.
func has_flag(key: String) -> bool:
	return flags.has(key)


## Returns a random nonquirky appearance from the specified list.
##
## The randomly selected appearance is weighted based on their 'chance' values. If the chance values add up to more
## than 1.0, one of the appearances will be returned. If the chance values add up to less than 1.0, it is possible
## none of the appearances will be selected in which case a value of 'null' will be returned instead.
##
## Parameters:
## 	'appearances': A list of CreatureAppearance instances
##
## Returns:
## 	A CreatureAppearance from the specified list. Returns 'null' if list has no nonquirky appearances, or if their
## 	chance values add up to less than 1.0 and none of the creatures are randomly selected.
func _random_creature(appearances: Array) -> CreatureAppearance:
	var result: CreatureAppearance = null
	
	# Calculate the sum of the appearances' "chance" values.
	#
	# These values *should* add up to less than 1.0, in which case we'll pick a random number in the range [0.0, 1.0]
	# But if someone mistakenly gave ten creatures a 13% chance of showing up we'll pick a random number in the range
	# [0.0, 1.3] instead.
	var total_chance := 0.0
	for appearance in appearances:
		total_chance += appearance.chance
	total_chance = max(1.0, total_chance)
	
	# Select a random appearance.
	#
	# We pick a random number in the range [0.0, 1.0], decrementing it based on each appearance's 'chance' value until
	# it drops below 0.0.
	var remaining_chance := rand_range(0.0, total_chance)
	for appearance in appearances:
		remaining_chance -= appearance.chance
		if remaining_chance <= 0.0:
			result = appearance
			break
	
	return result


## Parses an array of 'CreatureAppearance' values from json, storing them in this CareerRegion
##
## The specified property name corresponds both to the field name in json, as well as the CareerRegion array property
## name which stores the CreatureAppearance values.
##
## Parameters:
## 	'json': The json representation of the entire CareerRegion, including CreatureAppearance data as well as other
## 		unrelated data.
##
## 	'property': The json dictionary key for retrieving the data, and also the CareerRegion property name for
## 		storing the data.
func _parse_creature_appearances(json: Dictionary, property: String) -> void:
	for creature_string in json.get(property):
		var creature_appearance := CreatureAppearance.new()
		creature_appearance.from_json_string(creature_string)
		get(property).append(creature_appearance)
