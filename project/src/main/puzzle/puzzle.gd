class_name Puzzle
extends Control
"""
Represents a minimal puzzle game with a piece, playfield of pieces, and next pieces. Other classes can extend this
class to add goals, win conditions, challenges or time limits.
"""

# the previously launched food color. stored to avoid showing the same color twice consecutively
var _food_color: Color

func _ready() -> void:
	if not ResourceCache.is_done():
		# when launched standalone, we don't load creature resources (they're slow)
		ResourceCache.minimal_resources = true
	
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("after_game_ended", self, "_on_PuzzleScore_after_game_ended")
	$Playfield/TileMapClip/TileMap/Viewport/ShadowMap.piece_tile_map = $PieceManager/TileMap
	
	for i in range(3):
		$RestaurantView.summon_creature(i)
	
	if Scenario.settings.other.tutorial:
		summon_instructor(true)
	
	$RestaurantView.get_customer().play_hello_voice(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_menu") and not $Hud/HudUi/PuzzleMessages.is_settings_button_visible():
		# if the player presses the 'menu' button during a puzzle, we pop open the settings panel
		$SettingsMenu.show()
		get_tree().set_input_as_handled()


"""
Summon an instructor who leads tutorials.

Parameters:
	'replace_current': 'true' if the instructor should replace the currently visible customer, or false if the camera
		should scroll to the instructor.
"""
func summon_instructor(replace_current: bool = false) -> void:
	PuzzleScore.no_more_customers = true
	if $RestaurantView.get_customer().dna.get("instructor") == "true":
		return
	
	var creature_def := CreatureLoader.load_creature_def_by_id("instructor")
	Global.creature_queue.push_front(creature_def.dna)
	
	if replace_current:
		$RestaurantView.summon_creature()
	else:
		var new_creature_index: int = ($RestaurantView.get_current_creature_index() + 1) % 2
		$RestaurantView.summon_creature(new_creature_index)
		$RestaurantView.scroll_to_new_creature(new_creature_index)


func get_playfield() -> Playfield:
	return $Playfield as Playfield


func get_piece_manager() -> PieceManager:
	return $PieceManager as PieceManager


func hide_buttons() -> void:
	$Hud/HudUi/PuzzleMessages.hide_buttons()


func show_buttons() -> void:
	$Hud/HudUi/PuzzleMessages.show_buttons()


func scroll_to_new_creature() -> void:
	$RestaurantView.scroll_to_new_creature()


"""
Triggers the eating animation and makes the creature fatter. Accepts a 'fatness_pct' parameter which defines how
much fatter the creature should get. We can calculate how fat they should be, and a value of 0.4 means the creature
should increase by 40% of the amount needed to reach that target.

This 'fatness_pct' parameter is needed for the scenario where the player eliminates three lines at once. We don't
want the creature to suddenly grow full size. We want it to take 3 bites.

Parameters:
	'fatness_pct' A percent from [0.0-1.0] of how much fatter the creature should get from this bite of food.
"""
func _feed_creature(fatness_pct: float, food_color: Color) -> void:
	var old_fatness: float = $RestaurantView.get_customer().get_fatness()
	var target_fatness := sqrt(1 + PuzzleScore.get_creature_score() / 50.0)
	if Scenario.settings.other.tutorial:
		# make them a tiny amount fatter, so that they'll change when a new level is started
		target_fatness = min(target_fatness, 1.001)

	var comfort := 0.0
	# ate five things; comfortable
	comfort += clamp(inverse_lerp(5, 15, PuzzleScore.get_creature_line_clears()), 0.0, 1.0)
	# starting to overeat; less comfortable
	comfort -= clamp(inverse_lerp(400, 600, PuzzleScore.get_creature_score()), 0.0, 1.0)
	# overate; uncomfortable
	comfort -= clamp(inverse_lerp(600, 1200, PuzzleScore.get_creature_score()), 0.0, 1.0)

	$RestaurantView.get_customer().set_comfort(comfort)
	$RestaurantView.get_customer().set_fatness(lerp(old_fatness, target_fatness, fatness_pct))
	$RestaurantView.get_customer().feed(food_color)


"""
Calculates the food color for a row in the playfield.
"""
func _calculate_food_color(box_ints: Array) -> void:
	if box_ints.empty():
		# vegetable
		_food_color = Playfield.VEGETABLE_COLOR
	elif box_ints.has(PuzzleTileMap.BoxColorInt.CAKE):
		# cake box
		_food_color = Color.magenta
		_food_color.h = randf()
	elif box_ints.size() == 1 or Playfield.FOOD_COLORS[box_ints[0]] != _food_color:
		# snack box
		_food_color = Playfield.FOOD_COLORS[box_ints[0]]
	else:
		# avoid showing the same color twice if we can help it
		_food_color = Playfield.FOOD_COLORS[box_ints[1]]


func _check_for_game_end() -> void:
	if PuzzleScore.finish_triggered and not PuzzleScore.game_ended:
		PuzzleScore.end_game()


func _on_Hud_start_button_pressed() -> void:
	PuzzleScore.prepare_and_start_game()


func _on_Hud_settings_button_pressed() -> void:
	$SettingsMenu.show()


func _on_Hud_back_button_pressed() -> void:
	Scenario.clear_launched_scenario()
	Breadcrumb.pop_trail()


"""
Triggers the 'creature feeding' animation.
"""
func _on_Playfield_line_cleared(_y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	_calculate_food_color(box_ints)
	_feed_creature(1.0 / (remaining_lines + 1), _food_color)
	
	# When the player finishes a puzzle, we end the game immediately after the last line clear. We don't wait for the
	# after_piece_written signal because that signal is emitted after lines are deleted, resulting in an awkward pause.
	if remaining_lines == 0:
		_check_for_game_end()
	
	# Calculate whether or not the creature should say something positive about the combo.
	# They say something after clearing [6, 12, 18, 24...] lines.
	if remaining_lines == 0 and $Playfield/ComboTracker.combo >= 6 and total_lines > $Playfield/ComboTracker.combo % 6:
		yield(get_tree().create_timer(0.5), "timeout")
		$RestaurantView.get_customer().play_combo_voice()


func _on_Playfield_after_piece_written() -> void:
	_check_for_game_end()


func _on_PuzzleScore_game_started() -> void:
	$SettingsMenu.quit_text = SettingsMenu.GIVE_UP


"""
Method invoked when the game ends. Stores the rank result for later.
"""
func _on_PuzzleScore_game_ended() -> void:
	if not Scenario.launched_scenario_id:
		# null check to avoid errors when launching Puzzle.tscn standalone
		return
	
	$SettingsMenu.quit_text = SettingsMenu.QUIT
	var rank_result := RankCalculator.new().calculate_rank()
	PlayerData.scenario_history.add(Scenario.launched_scenario_id, rank_result)
	PlayerData.scenario_history.prune(Scenario.launched_scenario_id)
	PlayerData.money = int(clamp(PlayerData.money + rank_result.score, 0, 9999999999999999))
	
	match Scenario.settings.finish_condition.type:
		Milestone.SCORE:
			if not PuzzleScore.scenario_performance.lost and rank_result.seconds_rank < 24: $ApplauseSound.play()
		_:
			if not PuzzleScore.scenario_performance.lost and rank_result.score_rank < 24: $ApplauseSound.play()


"""
Wait until after the game ends to save the player's data.

This makes the stutter from writing to disk less noticable.
"""
func _on_PuzzleScore_after_game_ended() -> void:
	PlayerSave.save_player_data()


func _on_SettingsMenu_quit_pressed() -> void:
	if $SettingsMenu.quit_text == SettingsMenu.GIVE_UP:
		PuzzleScore.make_player_lose()
	else:
		Scenario.clear_launched_scenario()
		Breadcrumb.pop_trail()
