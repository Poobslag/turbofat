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
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("after_game_ended", self, "_on_PuzzleScore_after_game_ended")
	$MessageLabel.hide()
	# grab focus so the player can start a new game or navigate with the keyboard
	$Buttons/Start.grab_focus()
	
	if Scenario.overworld_puzzle:
		$Buttons/Back.text = "Quit"


func is_settings_button_visible() -> bool:
	return $Buttons/Settings.is_visible_in_tree()


"""
Shows a succinct single-line message, like 'Game Over'
"""
func show_message(text: String) -> void:
	$MessageLabel.show()
	$MessageLabel.text = text


func hide_buttons() -> void:
	$Buttons/Start.hide()
	$Buttons/Settings.hide()
	$Buttons/Back.hide()


func show_buttons() -> void:
	$Buttons/Start.show()
	$Buttons/Start.grab_focus()
	$Buttons/Settings.show()
	$Buttons/Back.show()


func _hide_buttons_and_messages() -> void:
	hide_buttons()
	$MessageLabel.hide()
	$DetailMessageLabel.hide()


func _on_Start_pressed() -> void:
	emit_signal("start_button_pressed")


func _on_Settings_pressed() -> void:
	emit_signal("settings_button_pressed")


func _on_Back_pressed() -> void:
	emit_signal("back_button_pressed")


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
	$Buttons/Settings.show()
	$Buttons/Back.show()
	$Buttons/Start.show()
	if Scenario.overworld_puzzle:
		# player can't restart a level if a creature asked them to do it, for thematic reasons
		$Buttons/Start.hide()
	if Scenario.settings.other.tutorial or Scenario.settings.other.after_tutorial:
		if not PuzzleScore.scenario_performance.lost:
			# if they won, make them exit; hide the start button
			$Buttons/Start.hide()
			
			# don't redirect them back to the splash screen, send them to the main menu
			if Breadcrumb.trail[1] == "res://src/main/ui/menu/SplashScreen.tscn":
				Breadcrumb.trail.insert(1, "res://src/main/ui/menu/MainMenu.tscn")
	
	if $Buttons/Start.is_visible_in_tree():
		# grab focus so the player can retry or navigate with the keyboard
		$Buttons/Start.grab_focus()
	elif $Buttons/Back.is_visible_in_tree():
		$Buttons/Back.grab_focus()
