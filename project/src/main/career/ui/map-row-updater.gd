extends Node
## Updates the career mode's chalkboard map based on how far the player has travelled.

# Number of regions to show on the chalkboard map
const REGIONS_BEFORE := 2
const REGIONS_AFTER := 3

export (NodePath) var map_path: NodePath

onready var _map: ChalkboardMapRow = get_node(map_path)

func _ready() -> void:
	# calculate the values needed to update the chalkboard map
	var player_distance := PlayerData.career.distance_travelled
	var regions := _calculate_start_and_end_region(player_distance)
	var start_region_index: int = regions["start_region_index"]
	var end_region_index: int = regions["end_region_index"]

	# update the chalkboard map with the calculated values
	_update_player_distance(player_distance)
	_update_landmark_count(start_region_index, end_region_index)
	_update_circle_landmark(start_region_index, end_region_index)
	_update_icon_landmarks(start_region_index, end_region_index)


## Determines the map boundaries.
##
## Based on the player's current region, the map boundaries are shifted to show a few landmarks before and after the
## player.
func _calculate_start_and_end_region(player_distance: int) -> Dictionary:
	var start_region_index: int
	var end_region_index: int

	var player_region: CareerRegion = CareerLevelLibrary.region_for_distance(player_distance)
	var player_region_index := CareerLevelLibrary.regions.find(player_region)
	if player_region_index == CareerLevelLibrary.regions.size() - 1:
		# player is past the end of the map
		end_region_index = CareerLevelLibrary.regions.size()
		start_region_index = end_region_index - REGIONS_BEFORE - REGIONS_AFTER + 1
	elif player_region_index > CareerLevelLibrary.regions.size() - REGIONS_AFTER - 1:
		# player is near the end of the map
		end_region_index = CareerLevelLibrary.regions.size() - 1
		start_region_index = end_region_index - REGIONS_BEFORE - REGIONS_AFTER + 1
	else:
		start_region_index = int(max(player_region_index - 1, 0))
		end_region_index = player_region_index + REGIONS_AFTER
	start_region_index = clamp(start_region_index, 1, CareerLevelLibrary.regions.size())
	end_region_index = clamp(end_region_index, 1, CareerLevelLibrary.regions.size())
	return {"start_region_index": start_region_index, "end_region_index": end_region_index}


## Updates the map's player distance.
func _update_player_distance(player_distance: int) -> void:
	_map.player_distance = player_distance


## Updates the map's landmark count.
func _update_landmark_count(start_region_index: int, end_region_index: int) -> void:
	_map.landmark_count = end_region_index - start_region_index + 2


## Updates the distance/landmark types for the circle landmark on the left.
func _update_circle_landmark(start_region_index: int, _end_region_index: int) -> void:
	var landmark_type: int
	var landmark_distance: int
	
	match start_region_index:
		0: landmark_type = Landmark.NONE
		1: landmark_type = Landmark.CIRCLES_1
		2: landmark_type = Landmark.CIRCLES_2
		3: landmark_type = Landmark.CIRCLES_3
		4: landmark_type = Landmark.CIRCLES_4
		5: landmark_type = Landmark.CIRCLES_5
		_: landmark_type = Landmark.CIRCLES_6
	landmark_distance = CareerLevelLibrary.regions[start_region_index - 1].start
	
	_map.set_landmark_type(0, landmark_type)
	_map.set_landmark_distance(0, landmark_distance)


## Updates the distance/landmark types for non-circle landmarks.
func _update_icon_landmarks(start_region_index: int, end_region_index: int) -> void:
	for region_index in range(start_region_index, end_region_index + 1):
		var landmark_type: int
		var landmark_distance: int
		
		if region_index >= CareerLevelLibrary.regions.size():
			# final unreachable region; update the landmark with an infinite distance and mystery icon
			landmark_type = Landmark.MYSTERY
			landmark_distance = CareerData.MAX_DISTANCE_TRAVELLED
		else:
			# update the landmark with the region's distance and icon
			var region: CareerRegion = CareerLevelLibrary.regions[region_index]
			landmark_type = Utils.enum_from_snake_case(Landmark.LandmarkType, region.icon_name, Landmark.MYSTERY)
			landmark_distance = region.start
		
		_map.set_landmark_distance(region_index - start_region_index + 1, landmark_distance)
		_map.set_landmark_type(region_index - start_region_index + 1, landmark_type)
