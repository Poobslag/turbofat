extends Node
## Manages data for all levels in career mode. This includes their rules, unlock criteria, which area they're in, and
## how far the player has to travel to get to each area.
##
## Levels are stored as json resources. This class parses those json resources into LevelSettings so they can be used
## by the puzzle code.

## Path to the json file with the list of levels. Can be changed for tests.
const DEFAULT_WORLDS_PATH := "res://assets/main/puzzle/career-worlds.json"

## Path to the json file with the list of levels. Can be changed for tests.
var worlds_path := DEFAULT_WORLDS_PATH setget set_worlds_path

## List of CareerRegions containing region and level data.
var regions: Array = []

## Returns a list of CareerRegions available after the player travels a certain distance.
func career_levels_for_distance(distance: int) -> Array:
	return region_for_distance(distance).levels


## Returns the CareerRegion the player is in after they travel a certain distance.
func region_for_distance(distance: int) -> CareerRegion:
	var result: CareerRegion
	for region in regions:
		result = region
		if distance >= region.distance and distance < region.distance + region.length:
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
## 	'r': (Optional) A parameter which controls the randomness of the speed formula for unit tests.
func piece_speed_for_distance(distance: int, r: float = randf()) -> String:
	var region: CareerRegion = region_for_distance(distance)
	var weight: float = region_weight_for_distance(region, distance)
	return piece_speed_between(region.min_piece_speed, region.max_piece_speed, weight, r)


## Returns a number between 0.0 and 1.0 corresponding to the player's distance within a region.
func region_weight_for_distance(region: CareerRegion, distance: int) -> float:
	return clamp(inverse_lerp(region.distance, region.distance + region.length - 1, distance), 0.0, 1.0)


## Returns a piece speed between the specified minimum and maximum.
##
## Parameters:
## 	'min_speed': The piece speed id corresponding to a slower speed.
##
## 	'max_speed': The piece speed id corresponding to a faster speed.
##
## 	'weight': A number ranged [0.0, 1.0] indicating whether the formula should prefer slower or faster speeds.
##
## 	'r': (Optional) A number ranged [0.0, 1.0] which controls the randomness of the speed formula for unit tests.
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


## Loads the list of levels from JSON
func _ready() -> void:
	_load_raw_json_data()


func set_worlds_path(new_worlds_path: String) -> void:
	worlds_path = new_worlds_path
	_load_raw_json_data()


## Loads the list of levels from JSON.
func _load_raw_json_data() -> void:
	regions.clear()
	
	var worlds_text := FileUtils.get_file_as_text(worlds_path)
	var worlds_json: Dictionary = parse_json(worlds_text)
	for region_json in worlds_json.get("regions", []):
		var region := CareerRegion.new()
		region.from_json_dict(region_json)
		regions.append(region)
	
	# populate CareerRegion.length field
	for i in range(regions.size()):
		if i < regions.size() - 1:
			regions[i].length = regions[i + 1].distance - regions[i].distance
		else:
			regions[i].length = CareerData.MAX_DISTANCE_TRAVELLED
