extends Control
## Shows a summary when the player finishes career mode.
##
## This summary screen includes things like how much money the player earned and how many customers they served, as
## well as a visual map showing their progress through the world.

# Daily step thresholds to trigger positive feedback.
const DAILY_STEPS_GOOD := 25
const DAILY_STEPS_OK := 8

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
	if PlayerData.career.distance_travelled < 50:
		# Player has not travelled very far; the first few landmarks are visible
		_map.landmark_count = 5
		
		_map.circle_count = 1
		_map.circle_distance = 0
		
		_map.set_landmark_distance(0, 10)
		_map.set_landmark_type(0, Landmark.CACTUS)
		
		_map.set_landmark_distance(1, 25)
		_map.set_landmark_type(1, Landmark.ISLAND)
		
		_map.set_landmark_distance(2, 40)
		_map.set_landmark_type(2, Landmark.SKULL)
		
		_map.set_landmark_distance(3, 60)
		_map.set_landmark_type(3, Landmark.GEAR)
		
		_map.set_landmark_distance(4, 80)
		_map.set_landmark_type(4, Landmark.VOLCANO)
	else:
		# Player has travelled a great distance; the last few landmarks are visible
		_map.landmark_count = 5
		
		_map.circle_count = 3
		_map.circle_distance = 25
		
		_map.set_landmark_distance(0, 40)
		_map.set_landmark_type(0, Landmark.SKULL)
		
		_map.set_landmark_distance(1, 60)
		_map.set_landmark_type(1, Landmark.GEAR)
		
		_map.set_landmark_distance(2, 80)
		_map.set_landmark_type(2, Landmark.VOLCANO)
		
		_map.set_landmark_distance(3, 100)
		_map.set_landmark_type(3, Landmark.RAINBOW)
		
		_map.set_landmark_distance(4, CareerData.MAX_DISTANCE_TRAVELLED)
		_map.set_landmark_type(4, Landmark.MYSTERY)
	
	_map.player_distance = PlayerData.career.distance_travelled


func _on_Button_pressed() -> void:
	SceneTransition.pop_trail()
