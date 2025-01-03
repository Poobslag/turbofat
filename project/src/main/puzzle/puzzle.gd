class_name Puzzle
extends Control
## Puzzle scene where a player drops pieces into a playfield of blocks.

## Number of time the player has started the puzzle.
var _start_puzzle_count := 0

onready var _restaurant_view: RestaurantView = $Fg/RestaurantView
onready var _settings_menu: SettingsMenu = $SettingsMenu
onready var _night_mode_toggler: NightModeToggler = $NightModeToggler

func _ready() -> void:
	if PlayerData.career.is_career_mode() and MusicPlayer.is_playing_boss_track():
		# don't interrupt boss music during career mode; it keeps playing from the level select to the puzzle
		pass
	else:
		MusicPlayer.play_menu_track()
	
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	
	$Fg/Playfield/TileMapClip/TileMap/ShadowViewport/ShadowMap.piece_tile_map = $Fg/PieceManager/TileMap
	$Fg/Playfield/TileMapClip/TileMap/GhostPieceViewport/ShadowMap.piece_tile_map = $Fg/PieceManager/TileMap
	$Fg/Playfield.pickups.piece_manager_path = $Fg/Playfield.pickups.get_path_to($Fg/PieceManager)
	$Fg/NightPlayfield/TileMapClip/TileMap/ShadowViewport/ShadowMap.piece_tile_map = $Fg/PieceManager/TileMap
	$Fg/NightPlayfield/TileMapClip/TileMap/GhostPieceViewport/ShadowMap.piece_tile_map = $Fg/PieceManager/TileMap
	CurrentLevel.puzzle = self
	_initialize_night_mode() # initialize night mode early for levels which require it, to avoid a bright flash
	
	# reset the current puzzle, so transient data doesn't carry over from scene to scene
	PuzzleState.reset()
	
	# set a baseline fatness state
	PlayerData.creature_library.save_fatness_state()
	PlayerData.customer_queue.priority_index = 0
	PlayerData.customer_queue.reset_standard_customer_queue()
	for i in range(_restaurant_view.get_customers().size()):
		_restaurant_view.summon_customer(i)
	
	get_customer().play_hello_voice()
	
	if CurrentLevel.settings.other.skip_intro:
		$PuzzleMusicManager.start_puzzle_music()
		if is_inside_tree():
			yield(get_tree().create_timer(0.8), "timeout")
		_start_puzzle()
	else:
		CurrentLevel.settings.triggers.run_triggers(LevelTrigger.BEFORE_START)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		return
	
	if event.is_action_pressed("ui_menu") and not $Hud/Center/PuzzleMessages.is_settings_button_visible():
		# if the player presses the 'menu' button during a puzzle, we pop open the settings panel
		_settings_menu.show()
		if is_inside_tree():
			get_tree().set_input_as_handled()
	
	if event.is_action_pressed("retry"):
		if not PuzzleState.game_active and not PuzzleState.game_ended:
			# still at the start of a puzzle; don't retry
			pass
		elif PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0 \
				and SystemData.misc_settings.show_give_up_confirmation:
			# user hasn't been prompted yet; prompt the user to retry
			_settings_menu.show_give_up_confirmation()
		elif (CurrentLevel.is_tutorial() or CurrentLevel.settings.other.after_tutorial):
			# each tutorial module handles restarting in their own way
			pass
		else:
			_restart()


func get_playfield() -> Playfield:
	return $Fg/Playfield as Playfield


func get_piece_manager() -> PieceManager:
	return $Fg/PieceManager as PieceManager


func get_piece_queue() -> PieceQueue:
	return $PieceQueue as PieceQueue


## Returns the node which handles carrots, puzzle critters which block the player's vision.
func get_carrots() -> Carrots:
	return $Fg/Critters/Carrots as Carrots


## Returns the node which handles moles, puzzle critters which dig up star seeds for the player.
func get_moles() -> Moles:
	return $Fg/Critters/Moles as Moles


## Returns the node which handles onions, puzzle critters which darken things making it hard to see.
func get_onions() -> Onions:
	return $Fg/Critters/Onions as Onions


## Returns the node which handles sharks, puzzle critters which eat pieces.
func get_sharks() -> Sharks:
	return $Fg/Critters/Sharks as Sharks


## Returns the node which handles spears, puzzle critters which add veggie blocks from the sides.
func get_spears() -> Spears:
	return $Fg/Critters/Spears as Spears


## Returns the node which handles tomatoes, puzzle critters which indicate lines which can't be cleared.
func get_tomatoes() -> Tomatoes:
	return $Fg/Critters/Tomatoes as Tomatoes


func hide_buttons() -> void:
	$Hud/Center/PuzzleMessages.hide_buttons()


func scroll_to_new_customer() -> void:
	_restaurant_view.scroll_to_new_customer()


## Start a countdown when transitioning between levels. Used during tutorials.
func start_level_countdown() -> void:
	$Fg/PieceManager.set_physics_process(false)
	$Hud/Center/PuzzleMessages.show_message(PuzzleMessage.NEUTRAL, tr("Ready?"))
	$StartEndSfx.play_ready_sound()
	if is_inside_tree():
		yield(get_tree().create_timer(PuzzleState.READY_DURATION), "timeout")
	$Hud/Center/PuzzleMessages.hide_message()
	$Fg/PieceManager.set_physics_process(true)
	$Fg/PieceManager.skip_prespawn()
	$StartEndSfx.play_go_sound()


func get_customer() -> Creature:
	return _restaurant_view.get_customer()


## Triggers the eating animation and makes the customer fatter.
##
## Parameters:
## 	'customer': The customer to feed
##
## 	'food_type': Enum from FoodType corresponding to the food to show
func feed_customer(customer: Creature, food_type: int) -> void:
	var new_comfort := customer.score_to_comfort(PuzzleState.combo, PuzzleState.get_customer_score())
	customer.set_comfort(new_comfort)
	customer.feed(food_type)


func set_night_mode(night_mode: bool) -> void:
	_night_mode_toggler.set_night_mode(night_mode)


func is_night_mode() -> bool:
	return _night_mode_toggler.is_night_mode()


## Restarts the puzzle, saving the level results and applying any penalties.
func _restart() -> void:
	if not is_inside_tree():
		return
	PuzzleState.retrying = true
	if not CurrentLevel.settings.lose_condition.finish_on_lose:
		# set the game inactive before ending combo/topping out, to avoid triggering gameplay and visual
		# effects
		PuzzleState.level_performance.lost = true
		PuzzleState.game_active = false
		PuzzleState.game_ended = true
		PuzzleState.apply_top_out_score_penalty()
		# use up all of the players lives; especially for career mode, we don't want to reward players who
		# give up
		PuzzleState.level_performance.top_out_count = CurrentLevel.settings.lose_condition.top_out
	
	if PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0:
		# End the game, triggering the chef's reaction and negative sound effects. Also saves the level result.
		PuzzleState.end_game()
	else:
		# Just save the level result, don't trigger the chef's reaction and negative sound effects.
		var rank_result := RankCalculator.new().calculate_rank()
		_save_level_result(rank_result)
	
	_start_puzzle()
	if is_inside_tree():
		get_tree().set_input_as_handled()
	PuzzleState.retrying = false


## Starts or restarts the puzzle, loading new customers and preparing the level.
func _start_puzzle() -> void:
	# increment the attempt count
	_start_puzzle_count += 1
	CurrentLevel.attempt_count = _start_puzzle_count - 1
	
	PlayerData.customer_queue.reset_standard_customer_queue()
	var current_customer_ids := []
	_restaurant_view.reset()
	for customer in _restaurant_view.get_customers():
		current_customer_ids.append(customer.creature_id)
	PlayerData.customer_queue.pop_standard_customers(current_customer_ids)
	
	if not CurrentLevel.keep_retrying:
		# Reset everyone's fatness. Replaying a puzzle in free roam mode shouldn't make a customer super fat.
		# Thematically we're turning back time.
		PlayerData.creature_library.restore_fatness_state()
	
	PlayerData.customer_queue.priority_index = 0
	_restaurant_view.briefly_suppress_sfx()
	
	if PlayerData.customer_queue.priority_queue:
		var starting_customer_creature_id: String = PlayerData.customer_queue.priority_queue[0].creature_id
		var starting_customer_index: int = _restaurant_view.find_customer_index_with_id(starting_customer_creature_id)
		if starting_customer_index == -1:
			# starting customer isn't found; load them to a different index and advance the priority queue
			starting_customer_index = _restaurant_view.next_customer_index()
			_restaurant_view.summon_customer(starting_customer_index)
		else:
			# starting customer is found; advance the priority customer queue so we don't see them twice
			PlayerData.customer_queue.pop_priority_customer()
			
			if PlayerData.creature_library.has_fatness(starting_customer_creature_id):
				# restore their fatness so they start skinny again when replaying a puzzle
				var fatness: float = PlayerData.creature_library.get_fatness(starting_customer_creature_id)
				_restaurant_view.get_customer(starting_customer_index).fatness = fatness
		
		# summon the other customers
		for i in range(_restaurant_view.get_customers().size()):
			if i != starting_customer_index:
				_restaurant_view.summon_customer(i)
		
		# scroll to the starting customer
		_restaurant_view.current_customer_index = starting_customer_index
		_restaurant_view.purge_current_customer_index_from_queue()
	else:
		var current_customer_feed_count: int = _restaurant_view.get_customer().feed_count
		
		# fill the seats if the customers ate
		for i in range(_restaurant_view.get_customers().size()):
			if _restaurant_view.get_customer(i).feed_count:
				_restaurant_view.summon_customer(i)
		
		# calculate the starting customer; stay on the same customer if they didn't eat
		if current_customer_feed_count > 0:
			_restaurant_view.current_customer_index = _restaurant_view.next_customer_index()
	
	PuzzleState.prepare_and_start_game()


## Quits/skips the current puzzle and changes scenes, navigating back one level in the breadcrumb trail.
##
## Parameters:
## 	'force_quit': In Career mode, this is 'true' if the player should be redirecting out of career mode entirely,
## 		or 'false' if the player should be redirected back to career mode.
func _quit_puzzle(force_quit: bool = false) -> void:
	if PlayerData.career.is_career_mode() and force_quit and CurrentLevel.attempt_count == 0:
		# The player can quit a puzzle in career mode if they haven't attempted it
		pass
	elif PlayerData.career.is_career_mode():
		PlayerData.career.process_puzzle_result()
	
	CurrentLevel.reset()
	PlayerData.customer_queue.reset()
	
	if PlayerData.career.is_career_mode() and force_quit:
		# quitting career mode; dump them back to the main menu
		PlayerData.cutscene_queue.reset()
		Breadcrumb.initialize_trail()
		SceneTransition.push_trail(Global.SCENE_MAIN_MENU)
	elif PlayerData.career.is_career_mode() and not force_quit:
		# continuing career mode; defer to CareerData to decide the next scene.
		PlayerData.career.push_career_trail()
	else:
		# not career mode; play a cutscene or return to the previous scene
		if PlayerData.cutscene_queue.is_front_cutscene():
			PlayerData.cutscene_queue.replace_trail()
		else:
			SceneTransition.pop_trail()


## Records the player's performance for career mode.
func _update_career_data(rank_result: RankResult) -> void:
	PlayerData.career.money = min(PlayerData.career.money + rank_result.score,
			PlayerData.MAX_MONEY)
	
	for customer_score in PuzzleState.customer_scores:
		if customer_score == 0:
			# If the player tops out without serving a customer, the customer is not included
			pass
		else:
			PlayerData.career.customers += 1
	
	# Calculate the player's distance to travel based on their overall rank
	var overall_rank := rank_result.rank
	
	var milestone_index := CareerData.rank_milestone_index(overall_rank)
	var distance_to_advance: int = Careers.RANK_MILESTONES[milestone_index].distance
	
	PlayerData.career.steps += distance_to_advance
	PlayerData.career.top_out_count += PuzzleState.level_performance.top_out_count
	if rank_result.lost:
		PlayerData.career.lost = true
		PlayerData.cutscene_queue.reset()
	PlayerData.career.advance_clock(distance_to_advance, rank_result.success)


## Stores the rank result for later.
func _save_level_result(rank_result: RankResult) -> void:
	_settings_menu.quit_type = SettingsMenu.QUIT
	PlayerData.level_history.add_result(CurrentLevel.level_id, rank_result)
	PlayerData.level_history.prune(CurrentLevel.level_id)
	PlayerData.emit_signal("level_history_changed")
	PlayerData.money = int(clamp(PlayerData.money + rank_result.score, 0, PlayerData.MAX_MONEY))
	
	if CurrentLevel.attempt_count == 0:
		CurrentLevel.first_result = PuzzleState.end_result()
	CurrentLevel.best_result = max(CurrentLevel.best_result, PuzzleState.end_result())
	
	if PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0:
		_update_career_data(rank_result)
	
	PlayerSave.schedule_save()


## For nighttime levels, this initializes night mode immediately to avoid an unpleasant blink effect.
func _initialize_night_mode() -> void:
	if get_onions().starts_in_night_mode():
		_night_mode_toggler.set_night_mode(true, 0.0)
		get_onions().skip_to_night_mode()


## Add the necessary lines/pieces/score to complete the necessary milestone
func _complete_milestone(milestone: Milestone) -> void:
	match milestone.type:
		Milestone.CUSTOMERS:
			while PuzzleState.customer_scores.size() <= milestone.adjusted_value():
				PuzzleState.customer_scores.insert(0, 100)
		Milestone.LINES:
			PuzzleState.level_performance.lines = milestone.adjusted_value()
		Milestone.PIECES:
			PuzzleState.level_performance.pieces = milestone.adjusted_value()
		Milestone.SCORE:
			var score := milestone.adjusted_value()
			
			# update all score fields; otherwise the results hud might be have strangely
			PuzzleState.level_performance.score = score
			PuzzleState.level_performance.box_score = int(score * 0.4)
			PuzzleState.level_performance.combo_score = int(score * 0.4)
			PuzzleState.level_performance.leftover_score = int(score * 0.1)
			PuzzleState.level_performance.pickup_score = PuzzleState.level_performance.score \
				- PuzzleState.level_performance.box_score \
				- PuzzleState.level_performance.combo_score \
				- PuzzleState.level_performance.leftover_score \
				- PuzzleState.level_performance.lines
			
			PuzzleState.level_performance.seconds += 9999
		Milestone.TIME_OVER:
			PuzzleState.level_performance.seconds = milestone.adjusted_value()
		Milestone.TIME_UNDER:
			# set the time slightly under the required time, so the player has a moment to place the piece
			PuzzleState.level_performance.seconds = max(milestone.adjusted_value() - 10.0, 1.0)


func _on_Hud_start_button_pressed() -> void:
	_start_puzzle()


func _on_Hud_settings_button_pressed() -> void:
	_settings_menu.show()


func _on_Hud_back_button_pressed() -> void:
	_quit_puzzle()


## Triggers the 'customer feeding' animation.
func _on_Playfield_line_cleared(_y: int, total_lines: int, remaining_lines: int, _box_ints: Array) -> void:
	var customer: Creature = get_customer()
	
	# Save the appropriate fatness in the CreatureLibrary
	var base_score := customer.fatness_to_score(customer.base_fatness)
	var new_fatness := customer.score_to_fatness(base_score + PuzzleState.fatness_score)
	customer.save_fatness(new_fatness)
	
	# When the player finishes a puzzle, we end the game immediately after the last line clear. We don't wait for the
	# after_piece_written signal because that signal is emitted after lines are deleted, resulting in an awkward pause.
	if remaining_lines == 0 and PuzzleState.finish_triggered and not PuzzleState.game_ended:
		PuzzleState.end_game()
	
	# Calculate whether or not the customer should say something positive about the combo.
	# They say something after clearing [6, 12, 18, 24...] lines.
	if remaining_lines == 0 and PuzzleState.combo >= 6 and total_lines > PuzzleState.combo % 6:
		if is_inside_tree():
			yield(get_tree().create_timer(0.5), "timeout")
		customer.play_combo_voice()


func _on_PuzzleState_game_started() -> void:
	_settings_menu.quit_type = SettingsMenu.RESTART_OR_GIVE_UP


## Method invoked when the game ends. Stores the rank result for later.
func _on_PuzzleState_game_ended() -> void:
	if not CurrentLevel.level_id:
		# null check to avoid errors when launching Puzzle.tscn standalone
		return
	
	var rank_result := RankCalculator.new().calculate_rank()
	_save_level_result(rank_result)

	if not PuzzleState.level_performance.lost and rank_result.rank < 24: $ApplauseSound.play()


func _on_SettingsMenu_quit_pressed() -> void:
	if _settings_menu.quit_type == SettingsMenu.RESTART_OR_GIVE_UP:
		_restart()
	else:
		_quit_puzzle(true)


func _on_SettingsMenu_other_quit_pressed() -> void:
	if _settings_menu.quit_type == SettingsMenu.RESTART_OR_GIVE_UP:
		PuzzleState.make_player_lose()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "finish" and PuzzleState.game_active:
		# finish the current level
		_complete_milestone(CurrentLevel.settings.finish_condition)
		detector.play_cheat_sound(true)
	
	if cheat == "winish" and PuzzleState.game_active:
		# finish the current level, and complete any success criteria
		_complete_milestone(CurrentLevel.settings.finish_condition)
		_complete_milestone(CurrentLevel.settings.success_condition)
		detector.play_cheat_sound(true)


func _on_Level_settings_changed() -> void:
	CurrentLevel.settings.triggers.run_triggers(LevelTrigger.BEFORE_START)
	if PuzzleState.game_active:
		CurrentLevel.settings.triggers.run_triggers(LevelTrigger.START)


func _on_SettingsMenu_give_up_confirmed() -> void:
	PuzzleState.make_player_lose()
