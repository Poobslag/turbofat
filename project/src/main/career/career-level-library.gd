extends Node
## Manages data for all levels in career mode. This includes their rules, unlock criteria, which area they're in, and
## how far the player has to travel to get to each area.
##
## Levels are stored as json resources. This class parses those json resources into LevelSettings so they can be used
## by the puzzle code.

## Path to the json file with the list of levels. Can be changed for tests.
const DEFAULT_REGIONS_PATH := "res://assets/main/puzzle/career-regions.json"

## Path to the json file with the list of levels. Can be changed for tests.
var regions_path := DEFAULT_REGIONS_PATH setget set_regions_path

## List of CareerRegion instances containing region and level data, sorted by distance
var regions: Array = []

## Loads the list of levels from JSON
func _ready() -> void:
	_load_raw_json_data()


func all_level_ids() -> Array:
	var result := {}
	for region in regions:
		for career_level in region.levels:
			result[career_level.level_id] = true
		if region.boss_level:
			result[region.boss_level.level_id] = true
		if region.intro_level:
			result[region.intro_level.level_id] = true
	return result.keys()


## Returns a list of CareerLevels available after the player travels a certain distance.
func career_levels_for_distance(distance: int) -> Array:
	return region_for_distance(distance).levels


## Returns the CareerRegion the player is in after they travel a certain distance.
func region_for_distance(distance: int) -> CareerRegion:
	distance = clamp(distance, 0, Careers.MAX_DISTANCE_TRAVELLED)
	var result: CareerRegion
	for region in regions:
		result = region
		if distance >= region.start and distance <= region.end:
			break
	return result


## Returns the region with the specified region id.
func region_for_id(region_id: String) -> CareerRegion:
	var result: CareerRegion
	for next_region in regions:
		if next_region.id == region_id:
			result = next_region
			break
	return result


## Returns an appropriate piece speed ID after the player travels a certain distance.
##
## Each region defines a minimum and maximum piece speed. When the player first enters a region, piece speeds will be
## closer to the minimum. As the player nears the end of a region, piece speeds will be closer to the maximum.
##
## The speed formula includes some randomness. The specified parameter 'r' controls the randomness of the speed
## formula for unit tests.
##
## Parameters:
## 	'distance': The distance the player has travelled.
##
## 	'r': (Optional) Parameter which controls the randomness of the speed formula for unit tests.
func piece_speed_for_distance(distance: int, r: float = randf()) -> String:
	var region: CareerRegion = region_for_distance(distance)
	var weight: float = region_weight_for_distance(region, distance)
	return piece_speed_between(region.min_piece_speed, region.max_piece_speed, weight, r)


## Returns a number between 0.0 and 1.0 corresponding to the player's distance within a region.
func region_weight_for_distance(region: CareerRegion, distance: int) -> float:
	return clamp(inverse_lerp(region.start, region.end, distance), 0.0, 1.0)


## Returns a piece speed between the specified minimum and maximum.
##
## Parameters:
## 	'min_speed': The piece speed id corresponding to a slower speed.
##
## 	'max_speed': The piece speed id corresponding to a faster speed.
##
## 	'weight': A number ranged [0.0, 1.0] indicating whether the formula should prefer slower or faster speeds.
##
## 	'r': (Optional) Number ranged [0.0, 1.0] which controls the randomness of the speed formula for unit tests.
## 		When deciding between two similar piece speeds, a low value exhibits a preference for the slower of the
## 		two.
func piece_speed_between(min_speed: String, max_speed: String, weight: float, r: float = randf()) -> String:
	# first, calculate the exact speed between the min/max based on the 'weight' parameter
	var min_speed_index: float = float(PieceSpeeds.speed_ids.find(min_speed))
	var max_speed_index: float = PieceSpeeds.speed_ids.find(max_speed)
	var speed_index_result: float = lerp(min_speed_index + 0.5, max_speed_index + 0.499, weight)
	
	# adjust it slightly based on the random 'r' parameter
	speed_index_result += r - 0.5
	speed_index_result = clamp(speed_index_result, min_speed_index, max_speed_index)
	
	# return the resulting piece speed string
	return PieceSpeeds.speed_ids[int(speed_index_result)]


func set_regions_path(new_regions_path: String) -> void:
	regions_path = new_regions_path
	_load_raw_json_data()


## Returns a collection of chefs and customers required for potential upcoming cutscenes.
##
## Based on the upcoming cutscenes, we sometimes restrict the player's level choice to one or two levels where those
## cutscenes make sense. This method returns the chefs/customers required for the upcoming cutscenes. As long as one
## of these chefs/customers is selected by the player, there will be at least one appropriate cutscene which features
## them.
##
## Parameters:
## 	'region': The player's current career region.
##
## Returns:
## 	A dictionary with three entries:
## 		'chef_ids' lists ids for quirky creatures who act as the chef for a cutscene.
##
## 		'customer_ids' lists ids for quirky creatures who act as the main customer for a cutscene.
##
## 		'observer_ids' lists ids for quirky creatures who act as the observer for a cutscene.
func required_cutscene_characters(region: CareerRegion) -> Dictionary:
	var chef_ids := []
	var customer_ids := []
	var observer_ids := []
	var potential_chat_key_pairs: Array = CareerCutsceneLibrary.potential_chat_key_pairs([region.cutscene_path])
	for chat_key_pair in potential_chat_key_pairs:
		for chat_key in chat_key_pair.chat_keys():
			var chat_tree: ChatTree = ChatLibrary.chat_tree_for_key(chat_key)
			var has_quirky_chef := false
			var has_quirky_customer := false
			var has_quirky_observer := false
			
			if chat_tree.chef_id:
				# If a cutscene specifies a quirky chef, it must be accompanied by a level with their quirks.
				if region.population.has_quirky_chef(chat_tree.chef_id):
					has_quirky_chef = true
					if not chat_tree.chef_id in chef_ids:
						chef_ids.append(chat_tree.chef_id)
			
			if chat_tree.customer_ids:
				# If a cutscene specifies a quirky customer, it must be accompanied by a level with their quirks.
				for customer_id in chat_tree.customer_ids:
					if region.population.has_quirky_customer(customer_id):
						has_quirky_customer = true
						if not customer_id in customer_ids:
							customer_ids.append(customer_id)
			
			if chat_tree.observer_id:
				# If a cutscene defines a quirky observer, it must be accompanied by a level with their quirks.
				if region.population.has_quirky_observer(chat_tree.observer_id):
					has_quirky_observer = true
					if not chat_tree.observer_id in observer_ids:
						observer_ids.append(chat_tree.observer_id)
			
			if not has_quirky_chef and not has_quirky_customer and not has_quirky_observer:
				# If a cutscene uses generic characters or nonquirky characters, it must be accompanied by a level
				# without quirks.
				if not CareerLevel.NONQUIRKY_CUSTOMER in customer_ids:
					customer_ids.append(CareerLevel.NONQUIRKY_CUSTOMER)
	
	return {
		"chef_ids": chef_ids,
		"customer_ids": customer_ids,
		"observer_ids": observer_ids,
	}


## Removes levels from a list if they do not include specific creatures in them.
##
## If the specified chef/customer lists are populated, this filters the specified level list to only include levels
## featuring a chef or customer from the lists.
##
## If the specified chef/customer lists are empty, this returns an unfiltered list of all levels.
##
## Parameters:
## 	'region': The region whose CareerLevel instances are being evaluated.
##
## 	'levels': A list of CareerLevel instances to evaluate.
##
## 	'chef_ids': A list of creature ids who must as appear as a chef in the returned cutscenes.
##
## 	'customer_ids': A list of creature ids who must as appear as customers in the returned cutscenes. This can
## 		also include NONQUIRKY_CUSTOMER for cutscenes with no named chefs/customers.
##
## Returns:
## 	A filtered list of CareerLevel instances if the input chef/customer lists are populated, or an unfiltered list
## 	if the input chef/customer lists are empty.
func trim_levels_by_characters(region: CareerRegion, levels: Array,
		chef_ids: Array, customer_ids: Array, observer_ids: Array) -> Array:
	var trimmed_levels := []
	if not chef_ids and not customer_ids and not observer_ids:
		trimmed_levels.append_array(levels)
	else:
		for level in levels:
			if level.chef_id and region.population.has_quirky_chef(level.chef_id):
				if level.chef_id in chef_ids:
					trimmed_levels.append(level)
			elif level.customer_ids and region.population.has_quirky_customer(level.customer_ids[0]):
				if level.customer_ids[0] in customer_ids:
					# If a level includes multiple customers, we ignore everything but the first customer. The first
					# customer is the only creature who appears on the map.
					trimmed_levels.append(level)
			elif level.observer_id and region.population.has_quirky_observer(level.observer_id):
				if level.observer_id in observer_ids:
					trimmed_levels.append(level)
			else:
				if CareerLevel.NONQUIRKY_CUSTOMER in customer_ids:
					trimmed_levels.append(level)
	return trimmed_levels


## Removes levels from a list if their 'available_if' condition has not been met.
##
## Parameters:
## 	'levels': A list of CareerLevel instances to evaluate
##
## Returns:
## 	A filtered list of CareerLevel instances, omitting any levels whose 'available_if' conditions have not been
## 	met.
func trim_levels_by_available_if(levels: Array) -> Array:
	var trimmed_levels := []
	for level in levels:
		var include_level := true
		if level.available_if:
			include_level = BoolExpressionEvaluator.evaluate(level.available_if)
		if include_level:
			trimmed_levels.append(level)
	return trimmed_levels


## Returns the CareerRegion with the specified cutscene.
##
## Parameters:
## 	'chat_key': A chat key such as 'chat/career/marsh/epilogue' identifying a cutscene
##
## Returns:
## 	A CareerRegion with the specified cutscene. Returns null if no CareerRegion could be found
func region_for_chat_key(chat_key: String) -> CareerRegion:
	var result: CareerRegion
	for region in regions:
		if region.cutscene_path and chat_key.begins_with(region.cutscene_path + "/"):
			result = region
			break
	return result


## Loads the list of levels from JSON.
func _load_raw_json_data() -> void:
	regions.clear()
	
	var worlds_text := FileUtils.get_file_as_text(regions_path)
	var worlds_json: Dictionary = parse_json(worlds_text)
	for region_json in worlds_json.get("regions", []):
		var region := CareerRegion.new()
		region.from_json_dict(region_json)
		regions.append(region)
	
	# populate CareerRegion.length field
	for i in range(regions.size()):
		if i < regions.size() - 1:
			regions[i].length = regions[i + 1].start - regions[i].start
		else:
			regions[i].length = Careers.MAX_DISTANCE_TRAVELLED
