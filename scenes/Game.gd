"""
Represents a minimal 'game' with a piece, playfield of pieces, and next pieces. Other classes can extend this class to add
goals, win conditions, challenges or time limits.
"""
extends Node2D

# signal emitted when the 'new game' countdown begins for piece randomization, clearing the playfield
signal before_game_started

# signal emitted when the 'new game' countdown finishes, giving the player control
signal game_started

# signal emitted when a line is cleared
signal line_cleared

# signal emitted when the player's pieces reach the top of the playfield
signal game_ended

# signal emitted a few seconds after the game ends, for displaying messages
signal after_game_ended

func _ready() -> void:
	$NextPieces.hide_pieces()
	$Piece.clear_piece()
	$HUD/MessageLabel.hide()

func _on_StartGameButton_pressed() -> void:
	emit_signal("before_game_started")
	$HUD/StartGameButton.hide()
	$HUD/DetailMessageLabel.hide()
	
	$NextPieces.start_game()
	$Playfield.start_game()
	$Score.start_game()
	
	show_message("3")
	$HUD/ReadySound.play()
	yield(get_tree().create_timer(0.8), "timeout")
	show_message("2")
	$HUD/ReadySound.play()
	yield(get_tree().create_timer(0.8), "timeout")
	show_message("1")
	$HUD/ReadySound.play()
	yield(get_tree().create_timer(0.8), "timeout")
	$HUD/MessageLabel.hide()
	$HUD/GoSound.play()
	
	$Piece.start_game()
	
	emit_signal("game_started")

"""
Shows a detailed multi-line message, like how the game is controlled
"""
func show_detail_message(text: String) -> void:
	$HUD/DetailMessageLabel.show()
	$HUD/DetailMessageLabel.text = text

"""
Shows a succinct single-line message, like 'Game Over'
"""
func show_message(text: String) -> void:
	$HUD/MessageLabel.show()
	$HUD/MessageLabel.text = text

func _on_game_ended() -> void:
	emit_signal("game_ended")
	show_message("Game Over")
	yield(get_tree().create_timer(2.4), "timeout")
	$HUD/MessageLabel.hide()
	$HUD/StartGameButton.show()
	emit_signal("after_game_ended")

func _on_line_cleared() -> void:
	emit_signal("line_cleared")
