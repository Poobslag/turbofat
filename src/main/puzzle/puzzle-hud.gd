extends Control
"""
Contains labels and buttons which overlay the puzzle screen.

This includes the countdown timer, the ending message, the controls, and the 'start' and 'exit' buttons.
"""

signal start_button_pressed

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	$MessageLabel.hide()
	# grab focus so the player can start a new game or navigate with the keyboard
	$StartGameButton.grab_focus()
	
	if Global.overworld_puzzle:
		$BackButton.text = "Quit"


"""
Shows a detailed multi-line message, like how the game is controlled
"""
func show_detail_message(text: String) -> void:
	$DetailMessageLabel.show()
	$DetailMessageLabel.text = text


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


func _on_PuzzleScore_game_started() -> void:
	_hide_buttons_and_messages()


"""
Restores the HUD elements after the player wins or loses.
"""
func _on_Puzzle_after_game_ended() -> void:
	$BackButton.show()
	$MessageLabel.hide()
	
	if Global.overworld_puzzle:
		# player can't restart a level if a customer asked them to do it, for thematic reasons
		$BackButton.grab_focus()
	else:
		# grab focus so the player can start a new game or navigate with the keyboard
		$StartGameButton.show()
		$StartGameButton.grab_focus()
