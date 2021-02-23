extends Control
"""
Contains labels and buttons which overlay the puzzle screen.

This includes the countdown timer, the ending message, the controls, and the 'start' and 'exit' buttons.
"""

signal start_button_pressed
signal settings_button_pressed
signal back_button_pressed

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	PuzzleScore.connect("before_level_changed", self, "_on_PuzzleScore_before_level_changed")
	PuzzleScore.connect("after_level_changed", self, "_on_PuzzleScore_after_level_changed")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("after_game_ended", self, "_on_PuzzleScore_after_game_ended")
	Level.connect("level_state_changed", self, "_on_Level_level_state_changed")
	$MessageLabel.hide()
	# grab focus so the player can start a new game or navigate with the keyboard
	$Buttons/Start.grab_focus()


func is_settings_button_visible() -> bool:
	return $Buttons/Settings.is_visible_in_tree()


"""
Shows a succinct single-line message, like 'Game Over'
"""
func show_message(text: String) -> void:
	$MessageLabel.show()
	$MessageLabel.text = text


func hide_message() -> void:
	$MessageLabel.hide()


func hide_buttons() -> void:
	$Buttons/Start.hide()
	$Buttons/Settings.hide()
	$Buttons/Back.hide()


func show_buttons() -> void:
	$Buttons/Start.show()
	$Buttons/Start.grab_focus()
	$Buttons/Settings.show()
	$Buttons/Back.show()


func _on_Start_pressed() -> void:
	emit_signal("start_button_pressed")


func _on_Settings_pressed() -> void:
	emit_signal("settings_button_pressed")


func _on_Back_pressed() -> void:
	emit_signal("back_button_pressed")


func _on_PuzzleScore_game_prepared() -> void:
	hide_buttons()
	show_message(tr("Ready?"))


func _on_PuzzleScore_game_started() -> void:
	hide_message()


func _on_PuzzleScore_before_level_changed(new_level_id: String) -> void:
	if new_level_id == Level.settings.id:
		show_message(tr("Regret..."))
	else:
		show_message(tr("Good!"))


func _on_PuzzleScore_after_level_changed() -> void:
	hide_message()


func _on_PuzzleScore_game_ended() -> void:
	var message: String
	match PuzzleScore.end_result():
		PuzzleScore.Result.NONE:
			hide_message()
		PuzzleScore.Result.LOST:
			message = tr("Game over")
		PuzzleScore.Result.FINISHED:
			message = tr("Finish!")
		PuzzleScore.Result.WON:
			message = tr("You win!")
	show_message(message)


"""
Restores the HUD elements after the player wins or loses.
"""
func _on_PuzzleScore_after_game_ended() -> void:
	$MessageLabel.hide()
	$Buttons/Settings.show()
	$Buttons/Back.show()
	$Buttons/Start.show()
	if Level.settings.other.tutorial or Level.settings.other.after_tutorial:
		if not PuzzleScore.level_performance.lost:
			# if they won, make them exit; hide the start button
			$Buttons/Start.hide()
			
			# don't redirect them back to the splash screen, send them to the main menu
			if Breadcrumb.trail.size() >= 2 and Breadcrumb.trail[1] == Global.SCENE_SPLASH:
				Breadcrumb.trail.insert(1, Global.SCENE_MAIN_MENU)
	
	# determine the default button to focus
	var buttons_to_focus := [$Buttons/Back, $Buttons/Start]
	if Level.keep_retrying:
		buttons_to_focus.push_front($Buttons/Start)
	elif Level.level_state != Level.LevelState.AFTER:
		buttons_to_focus.push_front($Buttons/Start)
	
	# the start button changes its label after the player finishes the level
	match PuzzleScore.end_result():
		PuzzleScore.Result.NONE:
			# if they abort the level without playing it, the button doesn't change
			pass
		_:
			$Buttons/Start.text = tr("Retry")
	
	# grab focus so the player can retry or navigate with the keyboard
	for button_to_focus_obj in buttons_to_focus:
		var button_to_focus: Button = button_to_focus_obj
		if button_to_focus.is_visible_in_tree():
			button_to_focus.grab_focus()
			break


"""
The back buttons changes its label if the level is cleared.
"""
func _on_Level_level_state_changed() -> void:
	match Level.level_state:
		Level.LevelState.AFTER:
			$Buttons/Back.text = tr("Back") if Level.keep_retrying else tr("Continue")
		_:
			$Buttons/Back.text = tr("Back")
