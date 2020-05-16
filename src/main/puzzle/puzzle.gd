class_name Puzzle
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
signal line_cleared(y, total_lines, remaining_lines)

# signal emitted when the player's pieces reach the top of the playfield
signal game_ended

# signal emitted a few seconds after the game ends, for displaying messages
signal after_game_ended

onready var _go_voices := [$GoVoice0, $GoVoice1, $GoVoice2]

# 'true' if the player has started a game which is still running.
var game_active: bool = true

func _ready() -> void:
	$NextPieceDisplays.hide_pieces()
	$PieceManager.clear_piece()
	$Playfield/TileMapClip/TileMap/Viewport/ShadowMap.piece_tile_map = $PieceManager/TileMap
	
	for i in range(3):
		_summon_customer(i)


"""
Shows a detailed multi-line message, like how the game is controlled
"""
func show_detail_message(text: String) -> void:
	$HudHolder/Hud.show_detail_message(text)


"""
Shows a succinct single-line message, like 'Game Over'
"""
func show_message(text: String) -> void:
	$HudHolder/Hud.show_message(text)


"""
Ends the game. This occurs when the player loses, wins, or runs out of time.
"""
func end_game(delay: float, message: String) -> void:
	game_active = false
	emit_signal("game_ended")
	$Playfield.end_game()
	$PieceManager.end_game()
	show_message(message)
	yield(get_tree().create_timer(delay), "timeout")
	$HudHolder/Hud.after_game_ended()
	emit_signal("after_game_ended")


func start_game() -> void:
	emit_signal("before_game_started")
	$HudHolder/Hud.hide_buttons_and_messages()
	
	$NextPieceDisplays.start_game()
	$Playfield.start_game()
	PuzzleScore.reset()
	$PieceManager.clear_piece()
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
	$HudHolder/Hud.hide_buttons_and_messages()
	$GoSound.play()
	_go_voices[randi() % _go_voices.size()].play()
	
	$PieceManager.start_game()
	
	game_active = true
	emit_signal("game_started")


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
		var target_fatness := sqrt(1 + PuzzleScore.get_customer_score() / 50.0)
		$CustomerView.set_fatness(lerp(old_fatness, target_fatness, fatness_pct))


"""
Scroll to a new customer and replace the old customer.
"""
func _scroll_to_new_customer() -> void:
	var customer_index: int = $CustomerView.get_current_customer_index()
	var new_customer_index: int = (customer_index + randi() % 2 + 1) % 3
	$CustomerView.set_current_customer_index(new_customer_index)
	yield(get_tree().create_timer(0.5), "timeout")
	$CustomerView.set_fatness(1, customer_index)
	
	_summon_customer(customer_index)


func _summon_customer(customer_index: int) -> void:
	var customer_def: Dictionary
	if Global.customer_queue.empty():
		customer_def = CustomerLoader.DEFINITIONS[randi() % CustomerLoader.DEFINITIONS.size()]
	else:
		customer_def = Global.customer_queue.pop_front()
	$CustomerView.summon_customer(customer_def, customer_index)


func _on_Hud_back_button_pressed() -> void:
	if Global.overworld_puzzle:
		get_tree().change_scene("res://src/main/world/Overworld.tscn")
	else:
		get_tree().change_scene("res://src/main/ui/ScenarioMenu.tscn")


func _on_Hud_start_button_pressed() -> void:
	start_game()


"""
When the current piece can't be placed, we end the game and emit the appropriate signals.
"""
func _on_Piece_game_ended() -> void:
	end_game(2.4, "Game over")


"""
Relays the 'line_cleared' signal to any listeners, and triggers the 'customer feeding' animation
"""
func _on_Playfield_line_cleared(y: int, total_lines: int, remaining_lines: int) -> void:
	# Calculate whether or not the customer should say something positive about the combo. The customer talks after
	var customer_talks: bool = remaining_lines == 0 and $Playfield.combo >= 5 \
			and total_lines > ($Playfield.combo + 1) % 3
	
	emit_signal("line_cleared", y, total_lines, remaining_lines)
	_feed_customer(1.0 / (remaining_lines + 1))
	
	if customer_talks:
		yield(get_tree().create_timer(0.5), "timeout")
		$CustomerView/SceneClip/CustomerSwitcher/Scene.play_combo_voice()


func _on_Playfield_customer_left() -> void:
	if $Playfield.clock_running:
		$CustomerView.play_goodbye_voice()
		_scroll_to_new_customer()
