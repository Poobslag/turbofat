extends Control
"""
Contains labels and buttons which overlay the puzzle screen.

This includes the countdown timer, the ending message, the controls, and the 'start' and 'exit' buttons.
"""

signal start_button_pressed

signal back_button_pressed

func _ready() -> void:
	$MessageLabel.hide()
	# grab focus so the player can start a new game or navigate with the keyboard
	$StartGameButton.grab_focus()
	
	if Global.overworld_puzzle:
		$BackButton.text = "Exit"


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


func hide_buttons_and_messages() -> void:
	$StartGameButton.hide()
	$BackButton.hide()
	$MessageLabel.hide()
	$DetailMessageLabel.hide()


"""
Restores the HUD elements after the player wins or loses.
"""
func after_game_ended() -> void:
	$BackButton.show()
	$MessageLabel.hide()
	
	if Global.overworld_puzzle:
		# player can't restart a level if a customer asked them to do it, for thematic reasons
		$BackButton.grab_focus()
	else:
		# grab focus so the player can start a new game or navigate with the keyboard
		$StartGameButton.show()
		$StartGameButton.grab_focus()


func _on_StartGameButton_pressed() -> void:
	emit_signal("start_button_pressed")


func _on_BackButton_pressed() -> void:
	emit_signal("back_button_pressed")
