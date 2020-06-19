extends Control
"""
Contains labels and buttons which overlay the puzzle screen.

This includes the countdown timer, the ending message, the controls, and the 'start' and 'exit' buttons.
"""

signal start_button_pressed

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("after_game_ended", self, "_on_PuzzleScore_after_game_ended")
	$MessageLabel.hide()
	# grab focus so the player can start a new game or navigate with the keyboard
	$StartGameButton.grab_focus()
	
	if Scenario.overworld_puzzle:
		$BackButton.text = "Quit"
	if Scenario.settings.other.tutorial:
		$BackButton.hide()


func hide_start_button() -> void:
	$StartGameButton.hide()


func show_start_button() -> void:
	$StartGameButton.show()
	$StartGameButton.grab_focus()


"""
Shows a succinct single-line message, like 'Game Over'
"""
func show_message(text: String) -> void:
	$MessageLabel.show()
	$MessageLabel.text = text


func _hide_buttons_and_messages() -> void:
	$StartGameButton.hide()
	$BackButton.hide()
	$MessageLabel.hide()
	$DetailMessageLabel.hide()


func _on_BackButton_pressed() -> void:
	Breadcrumb.pop_trail()


func _on_StartGameButton_pressed() -> void:
	emit_signal("start_button_pressed")


func _on_PuzzleScore_game_prepared() -> void:
	_hide_buttons_and_messages()
	show_message("Ready?")


func _on_PuzzleScore_game_started() -> void:
	_hide_buttons_and_messages()


func _on_PuzzleScore_game_ended() -> void:
	var message: String
	match PuzzleScore.end_result():
		PuzzleScore.LOST:
			message = "Game over"
		PuzzleScore.FINISHED:
			message = "Finish!"
		PuzzleScore.WON:
			message = "You win!"
	show_message(message)


"""
Restores the HUD elements after the player wins or loses.
"""
func _on_PuzzleScore_after_game_ended() -> void:
	$MessageLabel.hide()
	if Scenario.settings.other.tutorial or Scenario.settings.other.after_tutorial:
		if PuzzleScore.scenario_performance.lost:
			# if they lost/gave up, make them retry
			$StartGameButton.show()
			$StartGameButton.grab_focus()
		else:
			# if they won, make them exit
			$BackButton.show()
			$BackButton.grab_focus()
	else:
		$BackButton.show()
		if Scenario.overworld_puzzle:
			# player can't restart a level if a creature asked them to do it, for thematic reasons
			$BackButton.grab_focus()
		else:
			# grab focus so the player can start a new game or navigate with the keyboard
			$StartGameButton.show()
			$StartGameButton.grab_focus()
