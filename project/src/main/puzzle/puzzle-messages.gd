extends Control
## Contains labels and buttons which overlay the puzzle screen.
##
## This includes the countdown timer, the ending message, the controls, and the 'start' and 'exit' buttons.

signal start_button_pressed
signal settings_button_pressed
signal back_button_pressed

onready var _puzzle_message: PuzzleMessage = $PuzzleMessage
onready var _back_button := $Buttons/Back
onready var _start_button := $Buttons/Start
onready var _settings_button := $Buttons/Settings

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("before_level_changed", self, "_on_PuzzleState_before_level_changed")
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	PuzzleState.connect("after_game_ended", self, "_on_PuzzleState_after_game_ended")
	CurrentLevel.connect("best_result_changed", self, "_on_Level_best_result_changed")
	
	if PlayerData.career.is_career_mode():
		# they can't go back in career mode
		_back_button.text = tr("Skip")
	
	# grab focus so the player can start a new game or navigate with the keyboard
	_start_button.grab_focus()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_puzzle_message = $PuzzleMessage
	_back_button = $Buttons/Back
	_start_button = $Buttons/Start
	_settings_button = $Buttons/Settings


func is_settings_button_visible() -> bool:
	return _settings_button.is_visible_in_tree()


## Shows a succinct single-line message, like 'Game Over'
func show_message(message_type: int, text: String) -> void:
	_puzzle_message.show_message(message_type, text)


func hide_message() -> void:
	_puzzle_message.hide_message()


func hide_buttons() -> void:
	_start_button.hide()
	_settings_button.hide()
	_back_button.hide()


func show_buttons() -> void:
	_start_button.show()
	_start_button.grab_focus()
	_settings_button.show()
	_back_button.show()


## Updates the start button's text after the player finishes the level.
func _refresh_start_button() -> void:
	if PlayerData.career.is_career_mode():
		match CurrentLevel.attempt_count:
			0: _start_button.text = tr("Start")
			1: _start_button.text = tr("Practice")
			_: _start_button.text = tr("Retry")
	else:
		match CurrentLevel.attempt_count:
			0: _start_button.text = tr("Start")
			_: _start_button.text = tr("Retry")


func _on_Start_pressed() -> void:
	emit_signal("start_button_pressed")


func _on_Settings_pressed() -> void:
	emit_signal("settings_button_pressed")


func _on_Back_pressed() -> void:
	# disconnect signal to prevent the back button from changing its label
	CurrentLevel.disconnect("best_result_changed", self, "_on_Level_best_result_changed")
	
	emit_signal("back_button_pressed")


func _on_PuzzleState_game_prepared() -> void:
	hide_buttons()
	show_message(PuzzleMessage.NEUTRAL, tr("Ready?"))


func _on_PuzzleState_game_started() -> void:
	hide_message()


func _on_PuzzleState_before_level_changed(_new_level_id: String) -> void:
	if CurrentLevel.settings.other.non_interactive or not CurrentLevel.settings.input_replay.empty():
		# non interactive levels don't show a success/failure message
		return
	
	if PuzzleState.level_performance.lost:
		show_message(PuzzleMessage.BAD, tr("Regret..."))
	else:
		show_message(PuzzleMessage.GOOD, tr("Good!"))


func _on_PuzzleState_after_level_changed() -> void:
	hide_message()


func _on_PuzzleState_game_ended() -> void:
	var message_type := PuzzleMessage.NEUTRAL
	var message_text: String
	match PuzzleState.end_result():
		Levels.Result.NONE:
			hide_message()
		Levels.Result.LOST:
			message_type = PuzzleMessage.BAD
			message_text = tr("Game over")
		Levels.Result.FINISHED:
			message_type = PuzzleMessage.NEUTRAL
			message_text = tr("Finish!")
		Levels.Result.WON:
			message_type = PuzzleMessage.GOOD
			message_text = tr("You win!")
	if message_text:
		show_message(message_type, message_text)


## Restores the HUD elements after the player wins or loses.
func _on_PuzzleState_after_game_ended() -> void:
	_puzzle_message.hide_message()
	_settings_button.show()
	_back_button.show()
	_start_button.show()
	if CurrentLevel.settings.other.tutorial or CurrentLevel.settings.other.after_tutorial:
		if not PuzzleState.level_performance.lost:
			# if they won, make them exit; hide the start button
			_start_button.hide()
			
			# don't redirect them back to the splash screen, send them to the main menu
			if Breadcrumb.trail.size() >= 2 and Breadcrumb.trail[1] == Global.SCENE_SPLASH:
				Breadcrumb.trail.insert(1, Global.SCENE_MAIN_MENU)
	
	if PlayerData.career.is_career_mode():
		_back_button.text = tr("Continue")
	
	# determine the default button to focus
	var buttons_to_focus := [_back_button, _start_button]
	if PlayerData.career.is_career_mode():
		# in career mode, the back (continue) button is the default. but after retrying in career mode, the default
		# is to retry
		if CurrentLevel.attempt_count >= 2:
			buttons_to_focus.push_front(_start_button)
	elif CurrentLevel.keep_retrying:
		buttons_to_focus.push_front(_start_button)
	elif not CurrentLevel.best_result in [Levels.Result.FINISHED, Levels.Result.WON]:
		buttons_to_focus.push_front(_start_button)
	
	# update the start button's text after the player finishes the level
	_refresh_start_button()
	
	# grab focus so the player can retry or navigate with the keyboard
	for button_to_focus_obj in buttons_to_focus:
		var button_to_focus: Button = button_to_focus_obj
		if button_to_focus.is_visible_in_tree():
			button_to_focus.grab_focus()
			break


## The back buttons changes its label if the level is cleared.
func _on_Level_best_result_changed() -> void:
	match CurrentLevel.best_result:
		Levels.Result.FINISHED, Levels.Result.WON:
			_back_button.text = tr("Back") if CurrentLevel.keep_retrying else tr("Continue")
		_:
			_back_button.text = tr("Back")
