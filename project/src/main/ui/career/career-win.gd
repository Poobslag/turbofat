extends Node
## Shows a summary when the player finishes career mode.
##
## This summary screen includes things like how much money the player earned and how many customers they served, as
## well as a visual map showing their progress through the world.

# Daily step thresholds to trigger positive feedback.
const DAILY_STEPS_GOOD := 25
const DAILY_STEPS_OK := 8

export (NodePath) var overworld_environment_path: NodePath

onready var _button := $Bg/Chalkboard/VBoxContainer/ButtonRow/Button
onready var _map := $Bg/Chalkboard/VBoxContainer/MapRow
onready var _applause_sound := $Bg/ApplauseSound
onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()
	
	_refresh_mood()
	
	PlayerData.career.advance_calendar()
	PlayerSave.save_player_data()
	
	_button.grab_focus()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


## Updates the creature moods, and plays an applause sound if the player did well.
func _refresh_mood() -> void:
	var player := _overworld_environment.find_creature(CreatureLibrary.PLAYER_ID)
	var sensei := _overworld_environment.find_creature(CreatureLibrary.SENSEI_ID)
	if PlayerData.career.daily_steps >= DAILY_STEPS_GOOD:
		player.play_mood(Creatures.Mood.LAUGH0)
		sensei.play_mood(Creatures.Mood.LAUGH0)
	elif PlayerData.career.daily_steps >= DAILY_STEPS_OK:
		player.play_mood(Creatures.Mood.SMILE0)
		sensei.play_mood(Creatures.Mood.SMILE0)
	else:
		player.play_mood(Creatures.Mood.RAGE0)
		sensei.play_mood(Creatures.Mood.RAGE0)
	
	if PlayerData.career.daily_steps >= DAILY_STEPS_GOOD:
		_applause_sound.play()


func _on_Button_pressed() -> void:
	SceneTransition.pop_trail()
