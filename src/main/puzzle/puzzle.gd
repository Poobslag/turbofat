extends Control
"""
Represents a minimal puzzle game with a piece, playfield of pieces, and next pieces. Other classes can extend this
class to add goals, win conditions, challenges or time limits.
"""

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

onready var _go_voices := [$GoVoice0, $GoVoice1, $GoVoice2]

func _ready() -> void:
	$NextPieces.hide_pieces()
	$Piece.clear_piece()
	$HUD/MessageLabel.hide()
	$Playfield/TileMapClip/ShadowMap.piece_tile_map = $Piece/TileMap
	$CustomerView.summon_customer(CustomerLoader.DEFINITIONS[randi() % CustomerLoader.DEFINITIONS.size()], 0)
	$CustomerView.summon_customer(CustomerLoader.DEFINITIONS[randi() % CustomerLoader.DEFINITIONS.size()], 1)
	$CustomerView.summon_customer(CustomerLoader.DEFINITIONS[randi() % CustomerLoader.DEFINITIONS.size()], 2)


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


func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://src/main/ui/ScenarioMenu.tscn")


func _on_StartGameButton_pressed() -> void:
	emit_signal("before_game_started")
	$HUD/StartGameButton.hide()
	$HUD/BackButton.hide()
	$HUD/DetailMessageLabel.hide()
	
	$NextPieces.start_game()
	$Playfield.start_game()
	$Score.start_game()
	$Piece.clear_piece()
	if $CustomerView.get_fatness() > 1:
		# if they ended a game on a fattened customer, scroll to a new one
		_scroll_to_new_customer()
	
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
	_go_voices[randi() % _go_voices.size()].play()
	
	$Piece.start_game()
	
	emit_signal("game_started")


"""
When the current piece can't be placed, we end the game and emit the appropriate signals.
"""
func _on_Piece_game_ended() -> void:
	end_game(2.4, "Game over")


"""
Relays the 'line_cleared' signal to any listeners, and triggers the 'customer feeding' animation
"""
func _on_line_cleared(lines_cleared: int) -> void:
	# Calculate whether or not the customer should say something positive about the combo. The customer talks after
	# the 5th, 8th, 11th, 14th, 17th, 20th, 23rd, etc... line in a combo
	var customer_talks: bool = $Playfield.combo >= 5 and lines_cleared > ($Playfield.combo + 1) % 3
	
	emit_signal("line_cleared", lines_cleared)
	yield(get_tree().create_timer(rand_range(0.3, 0.5)), "timeout")
	_feed_customer(1.0 / lines_cleared)
	for i in range(lines_cleared - 1):
		yield(get_tree().create_timer(rand_range(0.066, 0.4)), "timeout")
		_feed_customer(1.0 / (lines_cleared - i - 1))
	if customer_talks:
		yield(get_tree().create_timer(0.5), "timeout")
		$CustomerView/SceneClip/CustomerSwitcher/Scene.play_combo_voice()


"""
Triggers the eating animation and makes the customer fatter. Accepts a 'fatness_pct' parameter which defines how
much fatter the customer should get. We can calculate how fat they should be, and a value of 0.4 means the customer
should increase by 40% of the amount needed to reach that target.

This 'fatness_pct' parameter is needed for the scenario where the player eliminates three lines at once. We don't
want the customer to suddenly grow full size. We want it to take 3 bites.

Parameters:
	'fatness_pct' A percent from [0.0-1.0] of how much fatter the customer should get from this bite of food.
"""
func _feed_customer(fatness_pct: float) -> void:
	$CustomerView/SceneClip/CustomerSwitcher/Scene.feed()
	
	if $Playfield.clock_running:
		var old_fatness: float = $CustomerView.get_fatness()
		var target_fatness := sqrt(1 + $Score.customer_score / 50.0)
		var new_fatness := target_fatness * fatness_pct + old_fatness * (1 - fatness_pct)
		$CustomerView.set_fatness(new_fatness)


func _on_customer_left() -> void:
	if $Playfield.clock_running:
		$CustomerView.play_goodbye_voice()
		_scroll_to_new_customer()


"""
Scroll to a new customer and replace the old customer.
"""
func _scroll_to_new_customer() -> void:
	var customer_index: int = $CustomerView.get_current_customer_index()
	var new_customer_index: int = (customer_index + randi() % 2 + 1) % 3
	$CustomerView.set_current_customer_index(new_customer_index)
	yield(get_tree().create_timer(0.5), "timeout")
	$CustomerView.set_fatness(1, customer_index)
	$CustomerView.summon_customer(CustomerLoader.DEFINITIONS[randi() % CustomerLoader.DEFINITIONS.size()], customer_index)
