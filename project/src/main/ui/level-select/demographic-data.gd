class_name DemographicData
## Describes the chance of different creature types appearing in a region.

## Describes the chance of a creature type appearing in a region.
class Demographic:
	
	## An enum from Creatures.Type for a creature type
	var type: int = Creatures.Type.DEFAULT
	
	## The creature type's chance of appearing
	var chance: float = 0.0
	
	func from_json_string(json: String) -> void:
		type = Utils.enum_from_snake_case(Creatures.Type, json.split(" ")[0])
		var percent_string := json.split(" ")[1]
		# convert a string like '35%' to a number like 0.35
		chance = float(percent_string.rstrip("%")) / 100.0

## Array of Demographic instances
var demographics := []

func from_json_array(json: Array) -> void:
	for demographic_json in json:
		var demographic := Demographic.new()
		demographic.from_json_string(demographic_json)
		demographics.append(demographic)


## Returns a random creature type weighted such that certain creature types show up more frequently.
##
## Returns:
## 	An enum from Creatures.Type for a creature type such as 'squirrel'
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
