extends Node
## Shows a summary when the player finishes career mode.
##
## This summary screen includes things like how much money the player earned and how many customers they served, as
## well as a visual map showing their progress through the world.

onready var _button := $Bg/Chalkboard/VBoxContainer/ButtonRow/ZHolder/Button
onready var _applause_sound := $Bg/ApplauseSound

func _ready() -> void:
	MusicPlayer.play_menu_track()
	
	_refresh_mood()
	
	PlayerData.career.advance_calendar()
	PlayerSave.schedule_save()
	
	_button.grab_focus()


## Plays an applause sound if the player did well.
func _refresh_mood() -> void:
	if PlayerData.career.steps >= Careers.DAILY_STEPS_GOOD:
		_applause_sound.play()


func _on_Button_pressed() -> void:
	SceneTransition.pop_trail()
