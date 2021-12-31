extends Node
## Shows a summary when the player finishes career mode.
##
## This summary screen includes things like how much money the player earned and how many customers they served, as
## well as a visual map showing their progress through the world.

export (NodePath) var obstacle_manager_path: NodePath

## Negative titles shown when the player fails, travelling zero steps during a career session.
var _bad_titles := [
	tr("OH DEAR WHAT HAPPENED"),
	tr("OH! NO! GO ON TRYING"),
	tr("GOSH THAT'S NOT GOOD"),
]

## Neutral titles shown when the player does poorly, travelling only a few steps during a career session.
var _good_titles := [
	tr("OH! WHAT A DAY"),
	tr("THAT'S FINE"),
	tr("LET'S GO HOME"),
]

## Affirming titles shown when the player does well, travelling many steps during a career session.
##
## These messages are shown very frequently, so they should have a sense of understatement to them.
var _great_titles := [
	tr("CONGRATULATIONS"),
	tr("WE DID IT"),
	tr("HOORAY"),
	tr("FANTASTIC"),
	tr("YAHOO FOR US"),
	tr("LOOK WHAT WE DID"),
	tr("GOSH! WE'RE SO COOL"),
	tr("WELL HOORAY"),
	tr("AMAZING"),
]

## Icons shown alongside the title at the top. One of these is selected randomly each time.
##
## Each item in this array is a subarray containing two nested items: a left icon and a right icon.
var _title_icon_resources := [
	[
		preload("res://assets/main/ui/career/chalkboard-title-0a.png"),
		preload("res://assets/main/ui/career/chalkboard-title-0b.png")
	],
	[
		preload("res://assets/main/ui/career/chalkboard-title-1a.png"),
		preload("res://assets/main/ui/career/chalkboard-title-1b.png")
	],
	[
		preload("res://assets/main/ui/career/chalkboard-title-2a.png"),
		preload("res://assets/main/ui/career/chalkboard-title-2b.png")
	],
	[
		preload("res://assets/main/ui/career/chalkboard-title-3a.png"),
		preload("res://assets/main/ui/career/chalkboard-title-3b.png")
	],
]

## Icons shown alongside the 'Served' value. One of these is selected randomly each time.
var _customer_icon_resources := [
	preload("res://assets/main/ui/career/chalkboard-customer-0.png"),
	preload("res://assets/main/ui/career/chalkboard-customer-1.png"),
	preload("res://assets/main/ui/career/chalkboard-customer-2.png"),
	preload("res://assets/main/ui/career/chalkboard-customer-3.png"),
]

onready var _button := $Chalkboard/VBoxContainer/ButtonRow/Button

## Labels which show the current day's information
onready var _title := $Chalkboard/VBoxContainer/TitleRow/HBoxContainer/Label
onready var _earned := $Chalkboard/VBoxContainer/EarnedTimeRow/HBoxContainer/Earned/HBoxContainer/Label3
onready var _served := $Chalkboard/VBoxContainer/ServedStepsRow/HBoxContainer/Served/HBoxContainer/Label3
onready var _steps := $Chalkboard/VBoxContainer/ServedStepsRow/HBoxContainer/Steps/HBoxContainer/Label3
onready var _time := $Chalkboard/VBoxContainer/EarnedTimeRow/HBoxContainer/Time/HBoxContainer/Label3

## Icons which change randomly each time
onready var _left_title_icon := $Chalkboard/VBoxContainer/TitleRow/HBoxContainer/Control1/TextureRect
onready var _right_title_icon := $Chalkboard/VBoxContainer/TitleRow/HBoxContainer/Control2/TextureRect
onready var _customer_icon := $Chalkboard/VBoxContainer/ServedStepsRow/HBoxContainer/ \
		Served/HBoxContainer/Control/TextureRect

onready var _map := $Chalkboard/VBoxContainer/MapRow
onready var _applause_sound := $ApplauseSound
onready var _obstacle_manager: ObstacleManager = get_node(obstacle_manager_path)

func _ready() -> void:
	_refresh_title_text()
	_refresh_icons()
	_refresh_labels()
	_refresh_map()
	
	PlayerData.career.advance_calendar()
	PlayerSave.save_player_data()
	
	_button.grab_focus()


## Updates the title text with a random value.
##
## Different titles are shown based on the player's performance. A typical player will always see the same affirming
## titles, although special titles are selected if they do especially poorly.
func _refresh_title_text() -> void:
	var player := _obstacle_manager.find_creature(CreatureLibrary.PLAYER_ID)
	var sensei := _obstacle_manager.find_creature(CreatureLibrary.SENSEI_ID)
	
	if PlayerData.career.daily_steps >= 25:
		# if you travelled 25 steps, you did great
		_title.text = Utils.rand_value(_great_titles)
		_applause_sound.play()
		player.play_mood(ChatEvent.Mood.LAUGH0)
		sensei.play_mood(ChatEvent.Mood.LAUGH0)
	elif PlayerData.career.daily_steps >= 8:
		# if you travelled 8, you at least did ok
		_title.text = Utils.rand_value(_good_titles)
		player.play_mood(ChatEvent.Mood.SMILE0)
		sensei.play_mood(ChatEvent.Mood.SMILE0)
	else:
		# you did not do well
		_title.text = Utils.rand_value(_bad_titles)
		player.play_mood(ChatEvent.Mood.RAGE0)
		sensei.play_mood(ChatEvent.Mood.RAGE0)


## Updates the icons in the report.
##
## This includes the icons shown alongside the title at the top, and the customer icon shown alongside the 'Served'
## value. These icons are randomized each time.
func _refresh_icons() -> void:
	# Select a random set of icons to show alongside the title at the top
	var title_icon_resources: Array = Utils.rand_value(_title_icon_resources)
	_left_title_icon.texture = title_icon_resources[0]
	_right_title_icon.texture = title_icon_resources[1]
	
	# Select a random customer icon to show alongside the 'Served' value
	var customer_icon_resource: Texture = Utils.rand_value(_customer_icon_resources)
	_customer_icon.texture = customer_icon_resource


## Updates the numeric values in the report.
##
## This populates the labels showing things like how much money the player earned and how many customers they served.
func _refresh_labels() -> void:
	_earned.text = StringUtils.format_money(min(PlayerData.career.daily_earnings, 999999))
	_served.text = StringUtils.comma_sep(min(PlayerData.career.daily_customers, 99999))
	_steps.text = StringUtils.comma_sep(min(PlayerData.career.daily_steps, 99999))
	_time.text = StringUtils.format_duration(min(PlayerData.career.daily_seconds_played, 5999)) # 99:59


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
