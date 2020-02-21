extends Node2D

signal before_start_game
signal start_game
signal line_clear
signal game_over
signal after_game_over

func _ready():
	$NextPieces.hide_pieces()
	$Block.clear_block()
	$HUD/MessageLabel.hide()

func _on_start_game():
	emit_signal("before_start_game")
	$HUD/StartGameButton.hide()
	$HUD/DetailMessageLabel.hide()
	
	$NextPieces.start_game()
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

func show_detail_message(text):
	$HUD/DetailMessageLabel.show()
	$HUD/DetailMessageLabel.text = text

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
