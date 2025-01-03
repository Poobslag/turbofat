extends Control
## Contains labels and buttons which overlay the puzzle screen.
##
## This includes the countdown timer, the ending message, the controls, and the 'start' and 'exit' buttons.

signal start_button_pressed
signal settings_button_pressed
signal back_button_pressed

var all_clear_message_text := tr("All\nClear!")

onready var _back_button := $Buttons/Back
onready var _hide_message_timer := $HideMessageTimer
onready var _puzzle_message: PuzzleMessage = $PuzzleMessage
onready var _start_button := $Buttons/Start
onready var _settings_button := $Buttons/Settings

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("before_level_changed", self, "_on_PuzzleState_before_level_changed")
	PuzzleState.connect("before_piece_written", self, "_on_PuzzleState_before_piece_written")
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	PuzzleState.connect("after_game_ended", self, "_on_PuzzleState_after_game_ended")
	CurrentLevel.connect("best_result_changed", self, "_on_Level_best_result_changed")
	
	if PlayerData.career.is_career_mode():
		# they can't go back in career mode
		if CurrentLevel.hardcore:
			_back_button.text = tr("Give Up")
			_back_button.color = CandyButtons.ButtonColor.RED
		else:
			_back_button.text = tr("Skip")
			_back_button.color = CandyButtons.ButtonColor.RED
	
	_refresh_start_button(0)
	
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


## Updates the start button's text after the player finishes the level.
func _refresh_start_button(new_attempt_count: int) -> void:
	if PlayerData.career.is_career_mode():
		match new_attempt_count:
			0:
				_start_button.text = tr("Start")
				_start_button.color = CandyButtons.ButtonColor.BLUE
			1:
				# Practicing a level shouldn't be the default behavior, so we use a less welcoming indigo color.
				_start_button.text = tr("Practice")
				_start_button.color = CandyButtons.ButtonColor.INDIGO
			_:
				_start_button.text = tr("Retry")
				_start_button.color = CandyButtons.ButtonColor.BLUE
	else:
		match new_attempt_count:
			0:
				_start_button.text = tr("Start")
				_start_button.color = CandyButtons.ButtonColor.BLUE
			_:
				_start_button.text = tr("Retry")
				_start_button.color = CandyButtons.ButtonColor.BLUE


func _hide_all_clear_message() -> void:
	if _puzzle_message.shown_message_text == all_clear_message_text:
		hide_message()
		_hide_message_timer.stop()


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
	
	if not CurrentLevel.settings.other.skip_intro:
		show_message(PuzzleMessage.NEUTRAL, tr("Ready?"))


func _on_PuzzleState_game_started() -> void:
	hide_message()


func _on_PuzzleState_before_level_changed(new_level_id: String) -> void:
	if CurrentLevel.settings.other.non_interactive or not CurrentLevel.settings.input_replay.empty():
		# non interactive levels don't show a success/failure message
		return
	
	if PuzzleState.level_performance.lost:
		show_message(PuzzleMessage.BAD, tr("Regret..."))
	elif new_level_id == CurrentLevel.settings.id:
		# retrying a level; don't show any message
		pass
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
	if CurrentLevel.is_tutorial() or CurrentLevel.settings.other.after_tutorial:
		if not PuzzleState.level_performance.lost:
			# if they won, make them exit; hide the start button
			_start_button.hide()
			
			# don't redirect them back to the splash screen, send them to the main menu
			if Breadcrumb.trail.size() >= 2 and Breadcrumb.trail[1] == Global.SCENE_SPLASH:
				Breadcrumb.trail.insert(1, Global.SCENE_MAIN_MENU)
			if SystemData.misc_settings.show_difficulty_menu:
				# show the player the difficulty menu if they haven't seen it
				Breadcrumb.trail.insert(1, Global.SCENE_DIFFICULTY_MENU)
	
	if PlayerData.career.is_career_mode():
		_back_button.text = tr("Continue")
		_back_button.color = CandyButtons.ButtonColor.BLUE
	
	# determine the default button to focus
	var buttons_to_focus := [_back_button, _start_button]
	if PlayerData.career.is_career_mode():
		# in career mode, the back (continue) button is the default. but after retrying in career mode, the default
		# is to retry
		if CurrentLevel.attempt_count >= 1:
			buttons_to_focus.push_front(_start_button)
	elif CurrentLevel.keep_retrying:
		buttons_to_focus.push_front(_start_button)
	elif not CurrentLevel.best_result in [Levels.Result.FINISHED, Levels.Result.WON]:
		buttons_to_focus.push_front(_start_button)
	
	# update the start button's text after the player finishes the level
	_refresh_start_button(CurrentLevel.attempt_count + 1)
	
	# grab focus so the player can retry or navigate with the keyboard
	for button_to_focus_obj in buttons_to_focus:
		var button_to_focus: BaseButton = button_to_focus_obj
		if button_to_focus.is_visible_in_tree():
			button_to_focus.grab_focus()
			break


## The back buttons changes its label if the level is cleared.
func _on_Level_best_result_changed() -> void:
	match CurrentLevel.best_result:
		Levels.Result.FINISHED, Levels.Result.WON:
			if CurrentLevel.keep_retrying:
				_back_button.text = tr("Back")
				_back_button.color = CandyButtons.ButtonColor.RED
			else:
				_back_button.text = tr("Continue")
				_back_button.color = CandyButtons.ButtonColor.BLUE
		_:
			_back_button.text = tr("Back")
			_back_button.color = CandyButtons.ButtonColor.RED


func _on_Playfield_all_lines_cleared() -> void:
	if MilestoneManager.is_met(CurrentLevel.settings.finish_condition):
		# avoid showing conflicting messages
		return
	
	if PuzzleState.tutorial_section_finished:
		# avoid showing conflicting messages
		return
	
	# show an an all clear message
	show_message(PuzzleMessage.GOOD, all_clear_message_text)
	_hide_message_timer.start()


## We hide the all clear message after a few seconds.
##
## The all clear message can also be manually hidden by placing a piece.
func _on_HideMessageTimer_timeout() -> void:
	_hide_all_clear_message()


## We hide the all clear message when the player places a piece.
##
## The all clear message is also automatically hidden after a few seconds.
func _on_PuzzleState_before_piece_written() -> void:
	if not _hide_message_timer.is_stopped():
		_hide_all_clear_message()
