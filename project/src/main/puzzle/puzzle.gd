class_name Puzzle
extends Control
"""
A puzzle scene where a player drops pieces into a playfield of blocks.
"""

# the previously launched food color. stored to avoid showing the same color twice consecutively
var _food_color: Color

# The number of times the start button has been pressed. Certain cleanup steps
# are only necessary when starting a puzzle for the second time.
var _start_button_click_count := 0

func _ready() -> void:
	if not ResourceCache.is_done():
		# when launched standalone, we don't load creature resources (they're slow)
		ResourceCache.minimal_resources = true
	ResourceCache.substitute_singletons()
	
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("after_game_ended", self, "_on_PuzzleScore_after_game_ended")
	$Playfield/TileMapClip/TileMap/Viewport/ShadowMap.piece_tile_map = $PieceManager/TileMap
	
	PlayerData.creature_queue.primary_index = 0
	PlayerData.creature_queue.reset_secondary_creature_queue()
	for i in range(3):
		$RestaurantView.summon_creature(i)
	
	$RestaurantView.get_customer().play_hello_voice(true)
	
	if Level.settings.other.skip_intro:
		$PuzzleMusicManager.start_puzzle_music()
		yield(get_tree().create_timer(0.8), "timeout")
		_start_puzzle()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_menu") and not $Hud/HudUi/PuzzleMessages.is_settings_button_visible():
		# if the player presses the 'menu' button during a puzzle, we pop open the settings panel
		$SettingsMenu.show()
		get_tree().set_input_as_handled()


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
Start a countdown when transitioning between levels. Used during tutorials.
"""
func start_level_countdown() -> void:
	$PieceManager.set_physics_process(false)
	$Hud/HudUi/PuzzleMessages.show_message(tr("Ready?"))
	$StartEndSfx.play_ready_sound()
	yield(get_tree().create_timer(PuzzleScore.READY_DURATION), "timeout")
	$Hud/HudUi/PuzzleMessages.hide_message()
	$PieceManager.set_physics_process(true)
	$PieceManager.skip_prespawn()
	$StartEndSfx.play_go_sound()


"""
Starts or restarts the puzzle, loading new customers and preparing the level.
"""
func _start_puzzle() -> void:
	_start_button_click_count += 1
	
	if _start_button_click_count > 1:
		# restart puzzle; reset customers
		PlayerData.creature_queue.reset_secondary_creature_queue()
		if PlayerData.creature_queue.primary_queue:
			# Reset fatness. Playing the same puzzle over and over shouldn't
			# make a creature super fat. Thematically, we're turning back time.
			PlayerData.creature_library.restore_fatness_state()
		PlayerData.creature_queue.primary_index = 0
		$RestaurantView.start_suppress_sfx_timer()
		for i in range(3):
			$RestaurantView.summon_creature(i)
		$RestaurantView.set_current_creature_index(0)
	
	PlayerData.creature_library.save_fatness_state()
	PuzzleScore.prepare_and_start_game()


"""
Triggers the eating animation and makes the creature fatter. Accepts a 'fatness_pct' parameter which defines how
much fatter the creature should get. We can calculate how fat they should be, and a value of 0.4 means the creature
should increase by 40% of the amount needed to reach that target.

This 'fatness_pct' parameter is needed for the level where the player eliminates three lines at once. We don't
want the creature to suddenly grow full size. We want it to take 3 bites.

Parameters:
	'fatness_pct' A percent from [0.0-1.0] of how much fatter the creature should get from this bite of food.
"""
func _feed_creature(fatness_pct: float, food_color: Color) -> void:
	var customer: Creature = $RestaurantView.get_customer()
	
	if customer.creature_id == CreatureLibrary.SENSEI_ID:
		# tutorial sensei doesn't gain weight
		pass
	else:
		var old_fatness: float = customer.get_fatness()
		var base_score := customer.fatness_to_score(customer.base_fatness)
		var target_fatness := customer.score_to_fatness(base_score + PuzzleScore.get_creature_score())
		customer.set_fatness(lerp(old_fatness, target_fatness, fatness_pct))

	if customer.creature_id == CreatureLibrary.SENSEI_ID:
		# tutorial sensei doesn't become comfortable
		pass
	else:
		var comfort := 0.0
		# ate five things; comfortable
		comfort += clamp(inverse_lerp(5, 15, PuzzleScore.combo), 0.0, 1.0)
		# starting to overeat; less comfortable
		comfort -= clamp(inverse_lerp(400, 600, PuzzleScore.get_creature_score()), 0.0, 1.0)
		# overate; uncomfortable
		comfort -= clamp(inverse_lerp(600, 1200, PuzzleScore.get_creature_score()), 0.0, 1.0)
		customer.set_comfort(comfort)
	
	customer.feed(food_color)


"""
Calculates the food color for a row in the playfield.
"""
func _calculate_food_color(box_ints: Array) -> void:
	if box_ints.empty():
		# vegetable
		_food_color = Playfield.VEGETABLE_COLOR
	elif PuzzleTileMap.has_cake_box(box_ints):
		# cake box
		_food_color = Color.magenta
		_food_color.h = randf()
	elif box_ints.size() == 1 or Playfield.FOOD_COLORS[box_ints[0]] != _food_color:
		# snack box
		_food_color = Playfield.FOOD_COLORS[box_ints[0]]
	else:
		# avoid showing the same color twice if we can help it
		_food_color = Playfield.FOOD_COLORS[box_ints[1]]


func _quit_puzzle() -> void:
	if Level.level_state == Level.LevelState.AFTER and ChatLibrary.has_postroll(Level.launched_level_id):
		var chat_tree := ChatLibrary.chat_tree_for_postroll(Level.launched_level_id)
		# insert cutscene into breadcrumb trail so it will show up after we pop the trail
		Breadcrumb.trail.insert(1, chat_tree.cutscene_scene_path())
	else:
		Level.clear_launched_level()

	PlayerData.creature_queue.clear()
	Breadcrumb.pop_trail()


func _on_Hud_start_button_pressed() -> void:
	_start_puzzle()


func _on_Hud_settings_button_pressed() -> void:
	$SettingsMenu.show()


func _on_Hud_back_button_pressed() -> void:
	_quit_puzzle()


"""
Triggers the 'creature feeding' animation.
"""
func _on_Playfield_line_cleared(_y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	_calculate_food_color(box_ints)
	_feed_creature(1.0 / (remaining_lines + 1), _food_color)
	
	# When the player finishes a puzzle, we end the game immediately after the last line clear. We don't wait for the
	# after_piece_written signal because that signal is emitted after lines are deleted, resulting in an awkward pause.
	if remaining_lines == 0 and PuzzleScore.finish_triggered and not PuzzleScore.game_ended:
		PuzzleScore.end_game()
	
	# Calculate whether or not the creature should say something positive about the combo.
	# They say something after clearing [6, 12, 18, 24...] lines.
	if remaining_lines == 0 and PuzzleScore.combo >= 6 and total_lines > PuzzleScore.combo % 6:
		yield(get_tree().create_timer(0.5), "timeout")
		$RestaurantView.get_customer().play_combo_voice()


func _on_PuzzleScore_game_started() -> void:
	$SettingsMenu.quit_text = SettingsMenu.GIVE_UP


"""
Method invoked when the game ends. Stores the rank result for later.
"""
func _on_PuzzleScore_game_ended() -> void:
	if not Level.launched_level_id:
		# null check to avoid errors when launching Puzzle.tscn standalone
		return
	
	$SettingsMenu.quit_text = SettingsMenu.QUIT
	var rank_result := RankCalculator.new().calculate_rank()
	PlayerData.level_history.add(Level.launched_level_id, rank_result)
	PlayerData.level_history.prune(Level.launched_level_id)
	PlayerData.emit_signal("level_history_changed")
	PlayerData.money = int(clamp(PlayerData.money + rank_result.score, 0, 9999999999999999))
	
	match Level.settings.finish_condition.type:
		Milestone.SCORE:
			if not PuzzleScore.level_performance.lost and rank_result.seconds_rank < 24: $ApplauseSound.play()
		_:
			if not PuzzleScore.level_performance.lost and rank_result.score_rank < 24: $ApplauseSound.play()
	
	if PuzzleScore.end_result() in [PuzzleScore.Result.FINISHED, PuzzleScore.Result.WON]:
		Level.level_state = Level.LevelState.AFTER


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
		if not MusicPlayer.is_playing_chill_bgm():
			MusicPlayer.stop()
			MusicPlayer.play_chill_bgm()
			MusicPlayer.fade_in()
		_quit_puzzle()
