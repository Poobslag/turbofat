class_name Population
## Describes the creatures in a career region.

## Chef/customer who appears in a career region.
class CreatureAppearance:
	## id of the creature who appears
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
			chance = float(percent_string.rstrip("%")) / 100.0
			json = StringUtils.substring_before_last(json, " ")
		
		id = json


## Describes the chance of a creature type appearing in a region.
class Demographic:
	
	## Enum from Creatures.Type for a creature type
	var type: int = Creatures.Type.DEFAULT
	
	## Creature type's chance of appearing
	var chance: float = 0.0
	
	func from_json_string(json: String) -> void:
		type = Utils.enum_from_snake_case(Creatures.Type, json.split(" ")[0])
		var percent_string := json.split(" ")[1]
		# convert a string like '35%' to a number like 0.35
		chance = float(percent_string.rstrip("%")) / 100.0

## Array of Demographic instances describing the chance of different creature types appearing in a region.
var demographics := []

## CreatureAppearance instances for chefs who randomly show up in levels
var chefs := []

## CreatureAppearance instances for customers who randomly show up in levels
var customers := []

## CreatureAppearance instances for observers who randomly show up to watch levels
var observers := []

func from_json_dict(json: Dictionary) -> void:
	if json.has("chefs"):
		_parse_creature_appearances(json, "chefs")
	if json.has("customers"):
		_parse_creature_appearances(json, "customers")
	if json.has("observers"):
		_parse_creature_appearances(json, "observers")
	if json.has("demographics"):
		for demographic_json in json.get("demographics"):
			var demographic := Demographic.new()
			demographic.from_json_string(demographic_json)
			demographics.append(demographic)


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


## Returns a random creature type weighted such that certain creature types show up more frequently.
##
## Returns:
## 	Enum from Creatures.Type for a creature type such as 'squirrel'
func random_creature_type() -> int:
	# Populate a weights map from the demographic values.
	var weights_map := {}
	var total_chance := 0.0
	for demographic in demographics:
		weights_map[demographic] = demographic.chance
		total_chance += demographic.chance
	
	# If the sum of the demographics' "chance" values is less than 1.0 we add a 'default demographic'
	if total_chance < 1.0:
		var default_demographic := Demographic.new()
		default_demographic.type = Creatures.Type.DEFAULT
		default_demographic.chance = 1.0 - total_chance
		weights_map[default_demographic] = default_demographic.chance
	
	return Utils.weighted_rand_value(weights_map).type


## Returns a random nonquirky chef from this region's list of chefs.
##
## Returns null if this region does not define any nonquirky chefs.
func random_chef() -> CreatureAppearance:
	return _random_creature(chefs)


## Returns a random nonquirky customer from this region's list of customers.
##
## Returns null if this region does not define any nonquirky customers.
func random_customer() -> CreatureAppearance:
	var result := _random_creature(customers)
	
	if result:
		# Omit creatures if their 'customer_if' flag hasn't been met yet.
		#
		# Cannot statically type as 'CreatureDef' because of cyclic reference.
		var creature_def = PlayerData.creature_library.get_creature_def(result.id)
		
		if not creature_def.is_customer():
			result = null
	
	return result


## Returns a random nonquirky observer from this region's list of observers.
##
## Returns null if this region does not define any nonquirky observers.
func random_observer() -> CreatureAppearance:
	return _random_creature(observers)


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
	# Populate a weights map from the appearance values.
	var weights_map := {}
	var total_chance := 0.0
	for appearance in appearances:
		weights_map[appearance] = appearance.chance
		total_chance += appearance.chance
	
	# If the sum of the appearances' "chance" values is less than 1.0 we add a 'null' chance
	if total_chance < 1.0:
		weights_map[null] = 1.0 - total_chance
	
	return Utils.weighted_rand_value(weights_map)



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
