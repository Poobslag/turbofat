extends Control
## Shows a summary when the player finishes career mode.
##
## This summary screen includes things like how much money the player earned and how many customers they served, as
## well as a visual map showing their progress through the world.

# Daily step thresholds to trigger positive feedback.
const DAILY_STEPS_GOOD := 25
const DAILY_STEPS_OK := 8

# Number of regions to show on the chalkboard map
const REGIONS_BEFORE := 2
const REGIONS_AFTER := 3

export (NodePath) var obstacle_manager_path: NodePath

onready var _button := $Chalkboard/VBoxContainer/ButtonRow/Button
onready var _map := $Chalkboard/VBoxContainer/MapRow
onready var _applause_sound := $ApplauseSound
onready var _obstacle_manager: ObstacleManager = get_node(obstacle_manager_path)

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()
	
	_refresh_mood()
	_refresh_map()
	
	PlayerData.career.advance_calendar()
	PlayerSave.save_player_data()
	
	_button.grab_focus()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


## Updates the creature moods, and plays an applause sound if the player did well.
func _refresh_mood() -> void:
	var player := _obstacle_manager.find_creature(CreatureLibrary.PLAYER_ID)
	var sensei := _obstacle_manager.find_creature(CreatureLibrary.SENSEI_ID)
	if PlayerData.career.daily_steps >= DAILY_STEPS_GOOD:
		player.play_mood(ChatEvent.Mood.LAUGH0)
		sensei.play_mood(ChatEvent.Mood.LAUGH0)
	elif PlayerData.career.daily_steps >= DAILY_STEPS_OK:
		player.play_mood(ChatEvent.Mood.SMILE0)
		sensei.play_mood(ChatEvent.Mood.SMILE0)
	else:
		player.play_mood(ChatEvent.Mood.RAGE0)
		sensei.play_mood(ChatEvent.Mood.RAGE0)
	
	if PlayerData.career.daily_steps >= DAILY_STEPS_GOOD:
		_applause_sound.play()


## Updates the map based on how far the player has travelled.
func _refresh_map() -> void:
	_map.player_distance = PlayerData.career.distance_travelled
	
	# determine map boundaries; show a few landmarks before and after the player
	var player_region: CareerRegion = CareerLevelLibrary.region_for_distance(_map.player_distance)
	var player_region_index := CareerLevelLibrary.regions.find(player_region)
	var start_region_index: int
	var end_region_index: int
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
	
	# assign the map properties based on our calculated boundaries
	_map.landmark_count = end_region_index - start_region_index + 1
	_map.circle_count = start_region_index
	_map.circle_distance = CareerLevelLibrary.regions[start_region_index - 1].distance
	
	# update the distance/landmark type for each landmark
	for region_index in range(start_region_index, end_region_index + 1):
		var distance: int
		var landmark_type: int
		if region_index >= CareerLevelLibrary.regions.size():
			# final unreachable region; update the landmark with an infinite distance and mystery icon
			distance = CareerData.MAX_DISTANCE_TRAVELLED
			landmark_type = Landmark.MYSTERY
		else:
			# update the landmark with the region's distance and icon
			var region: CareerRegion = CareerLevelLibrary.regions[region_index]
			distance = region.distance
			landmark_type = Utils.enum_from_snake_case(Landmark.LandmarkType, region.icon_name, Landmark.MYSTERY)
		
		_map.set_landmark_distance(region_index - start_region_index, distance)
		_map.set_landmark_type(region_index - start_region_index, landmark_type)


func _on_Button_pressed() -> void:
	SceneTransition.pop_trail()
