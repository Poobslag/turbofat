"""
Represents a minimal 'game' with a block, grid of blocks, and next blocks. Other classes can extend this class to add
goals, win conditions, challenges or time limits.
"""
extends Node2D

# signal emitted when the 'new game' countdown begins for block randomization, clearing the grid
signal before_start_game

# signal emitted when the 'new game' countdown finishes, giving the player control
signal start_game

# signal emitted when a line is cleared
signal line_clear

# signal emitted when the player's blocks reach the top of the grid
signal game_over

# signal emitted a few seconds after the game ends, for displaying messages
signal after_game_over

func _ready():
	$NextBlocks.hide_blocks()
	$Block.clear_block()
	$HUD/MessageLabel.hide()

func _on_start_game():
	emit_signal("before_start_game")
	$HUD/StartGameButton.hide()
	$HUD/DetailMessageLabel.hide()
	
	$NextBlocks.start_game()
	$Grid.start_game()
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
	
	$Block.start_game()
	emit_signal("start_game")

"""
Shows a detailed multi-line message, like how the game is controlled
"""
func show_detail_message(text):
	$HUD/DetailMessageLabel.show()
	$HUD/DetailMessageLabel.text = text

"""
Shows a succinct single-line message, like 'Game Over'
"""
func show_message(text):
	$HUD/MessageLabel.show()
	$HUD/MessageLabel.text = text

func _on_game_over():
	emit_signal("game_over")
	show_message("Game Over")
	yield(get_tree().create_timer(2.4), "timeout")
	$HUD/MessageLabel.hide()
	$HUD/StartGameButton.show()
	emit_signal("after_game_over")

func _on_line_clear():
	emit_signal("line_clear")
