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
	$Playfield/TileMapClip/ShadowMap.piece_tile_map = ($Piece/TileMap)

func _on_BackButton_pressed():
	get_tree().change_scene("res://scenes/PracticeMenu.tscn")

func _on_StartGameButton_pressed() -> void:
	emit_signal("before_game_started")
	$HUD/StartGameButton.hide()
	$HUD/BackButton.hide()
	$HUD/DetailMessageLabel.hide()
	
	$NextPieces.start_game()
	$Playfield.start_game()
	$Score.start_game()
	$Piece.clear_piece()
	
	show_message("3")
	$ReadySound.play()
	yield(get_tree().create_timer(0.8), "timeout")
	show_message("2")
	$ReadySound.play()
	yield(get_tree().create_timer(0.8), "timeout")
	show_message("1")
	$ReadySound.play()
	yield(get_tree().create_timer(0.8), "timeout")
	$HUD/MessageLabel.hide()
	$GoSound.play()
	
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

"""
When the current piece can't be placed, we end the game and emit the appropriate signals.
"""
func _on_Piece_game_ended():
	end_game(2.4, "Game over")

"""
End the game and emit the appropriate signals. This can occur when the player loses, wins, or runs out of time.
"""
func end_game(delay: float, message: String) -> void:
	emit_signal("game_ended")
	$Playfield.end_game()
	$Piece.end_game()
	show_message(message)
	yield(get_tree().create_timer(delay), "timeout")
	$HUD/StartGameButton.show()
	$HUD/BackButton.show()
	$HUD/MessageLabel.hide()
	emit_signal("after_game_ended")

"""
Relays the 'line_cleared' signal to any listeners, and triggers the 'customer feeding' animation
"""
func _on_line_cleared(lines_cleared: int) -> void:
	emit_signal("line_cleared", lines_cleared)
	yield(get_tree().create_timer(rand_range(0.3, 0.5)), "timeout")
	$CustomerView/SceneClip/Scene.feed()
	for i in range(1, lines_cleared):
		yield(get_tree().create_timer(rand_range(0.066, 0.4)), "timeout")
		$CustomerView/SceneClip/Scene.feed()
