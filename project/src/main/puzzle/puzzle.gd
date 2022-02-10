class_name Puzzle
extends Control
## A puzzle scene where a player drops pieces into a playfield of blocks.

onready var _restaurant_view: RestaurantView = $RestaurantView

onready var _settings_menu: SettingsMenu = $SettingsMenu

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()
	
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	PuzzleState.connect("after_game_ended", self, "_on_PuzzleState_after_game_ended")
	$Playfield/TileMapClip/TileMap/Viewport/ShadowMap.piece_tile_map = $PieceManager/TileMap
	$PieceManager.connect("piece_disturbed", $Playfield.pickups, "_on_PieceManager_piece_disturbed")
	CurrentLevel.puzzle = self
	
	# reset the current puzzle, so transient data doesn't carry over from scene to scene
	PuzzleState.reset()
	
	# set a baseline fatness state
	PlayerData.creature_library.save_fatness_state()
	PlayerData.creature_queue.primary_index = 0
	PlayerData.creature_queue.reset_secondary_creature_queue()
	for i in range(3):
		_restaurant_view.summon_creature(i)
	
	get_customer().play_hello_voice(true)
	
	if CurrentLevel.settings.other.skip_intro:
		$PuzzleMusicManager.start_puzzle_music()
		yield(get_tree().create_timer(0.8), "timeout")
		_start_puzzle()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_menu") and not $Hud/HudUi/PuzzleMessages.is_settings_button_visible():
		# if the player presses the 'menu' button during a puzzle, we pop open the settings panel
		_settings_menu.show()
		get_tree().set_input_as_handled()


func get_playfield() -> Playfield:
	return $Playfield as Playfield


func get_piece_manager() -> PieceManager:
	return $PieceManager as PieceManager


func get_piece_queue() -> PieceQueue:
	return $PieceQueue as PieceQueue


func hide_buttons() -> void:
	$Hud/HudUi/PuzzleMessages.hide_buttons()


func show_buttons() -> void:
	$Hud/HudUi/PuzzleMessages.show_buttons()


func scroll_to_new_creature() -> void:
	_restaurant_view.scroll_to_new_creature()


## Start a countdown when transitioning between levels. Used during tutorials.
func start_level_countdown() -> void:
	$PieceManager.set_physics_process(false)
	$Hud/HudUi/PuzzleMessages.show_message(tr("Ready?"))
	$StartEndSfx.play_ready_sound()
	yield(get_tree().create_timer(PuzzleState.READY_DURATION), "timeout")
	$Hud/HudUi/PuzzleMessages.hide_message()
	$PieceManager.set_physics_process(true)
	$PieceManager.skip_prespawn()
	$StartEndSfx.play_go_sound()


func get_customer() -> Creature:
	return _restaurant_view.get_customer()


## Triggers the eating animation and makes the creature fatter. Accepts a 'fatness_pct' parameter which defines how
## much fatter the creature should get. We can calculate how fat they should be, and a value of 0.4 means the creature
## should increase by 40% of the amount needed to reach that target.
##
## This 'fatness_pct' parameter is needed for the level where the player eliminates three lines at once. We don't
## want the creature to suddenly grow full size. We want it to take 3 bites.
##
## Parameters:
## 	'customer': The creature to feed
##
## 	'food_type': An enum from FoodType corresponding to the food to show
func feed_creature(customer: Creature, food_type: int) -> void:
	var new_comfort := customer.score_to_comfort(PuzzleState.combo, PuzzleState.get_customer_score())
	customer.set_comfort(new_comfort)
	customer.feed(food_type)


## Starts or restarts the puzzle, loading new customers and preparing the level.
func _start_puzzle() -> void:
	PlayerData.creature_queue.reset_secondary_creature_queue()
	
	if not CurrentLevel.keep_retrying:
		# Reset everyone's fatness. Replaying a puzzle in story mode shouldn't
		# make a creature super fat. Thematically we're turning back time.
		PlayerData.creature_library.restore_fatness_state()
	
	PlayerData.creature_queue.primary_index = 0
	_restaurant_view.briefly_suppress_sfx()
	
	if PlayerData.creature_queue.primary_queue:
		var starting_creature_id: String = PlayerData.creature_queue.primary_queue[0].creature_id
		var starting_creature_index: int = _restaurant_view.find_creature_index_with_id(starting_creature_id)
		if starting_creature_index == -1:
			# starting creature isn't found; load them to a different index and advance the primary queue
			starting_creature_index = _restaurant_view.next_creature_index()
			_restaurant_view.summon_creature(starting_creature_index)
		else:
			# starting creature is found; advance the primary creature queue so we don't see them twice
			PlayerData.creature_queue.pop_primary_creature()
			
			if PlayerData.creature_library.has_fatness(starting_creature_id):
				# restore their fatness so they start skinny again when replaying a puzzle
				var fatness: float = PlayerData.creature_library.get_fatness(starting_creature_id)
				_restaurant_view.get_customer(starting_creature_index).set_fatness(fatness)
		
		# summon the other creatures
		for i in range(3):
			if i != starting_creature_index:
				_restaurant_view.summon_creature(i)
		
		# scroll to the starting creature
		_restaurant_view.current_creature_index = starting_creature_index
	else:
		var current_creature_feed_count: int = _restaurant_view.get_customer().feed_count
		
		# fill the seats if the creatures ate
		for i in range(3):
			if _restaurant_view.get_customer(i).feed_count:
				_restaurant_view.summon_creature(i)
		
		# calculate the starting creature; stay on the same creature if they didn't eat
		if current_creature_feed_count > 0:
			_restaurant_view.current_creature_index = _restaurant_view.next_creature_index()
	
	PuzzleState.prepare_and_start_game()


func _quit_puzzle() -> void:
	if _should_play_postroll():
		# enqueue the postroll cutscene
		var chat_tree := ChatLibrary.chat_tree_for_postroll(CurrentLevel.level_id)
		CutsceneManager.enqueue_cutscene(chat_tree)
	
	if _should_play_epilogue():
		# enqueue the epilogue cutscene (after any postroll cutscene)
		var world_lock: WorldLock = LevelLibrary.world_lock_for_level(CurrentLevel.level_id)
		var chat_tree := ChatLibrary.chat_tree_for_key(world_lock.epilogue_chat_key)
		CutsceneManager.enqueue_cutscene(chat_tree)
	
	if PlayerData.career.is_career_mode() and not PuzzleState.game_ended:
		# apply penalties for skipping in career mode
		PlayerData.career.advance_clock(0, false)
		PlayerData.career.skipped_previous_level = true
	
	CurrentLevel.clear_launched_level()
	PlayerData.creature_queue.clear()
	
	if PlayerData.career.is_career_mode():
		# career mode; defer to CareerData to decide the next scene.
		PlayerData.career.push_career_trail()
	else:
		# not career mode; play a cutscene or return to the previous scene
		if CutsceneManager.is_front_cutscene():
			CutsceneManager.replace_trail()
		else:
			SceneTransition.pop_trail()


## Returns 'true' if we should play a postroll cutscene after this level.
##
## We play a postroll cutscene if the player clears the level, although we forcibly skip the cutscene in other
## circumstances as well.
func _should_play_postroll() -> bool:
	var result := true
	var chat_tree := ChatLibrary.chat_tree_for_postroll(CurrentLevel.level_id)
	if not CurrentLevel.best_result in [Levels.Result.FINISHED, Levels.Result.WON]:
		# player didn't clear the level; don't play the cutscene
		result = false
	elif not ChatLibrary.should_play_cutscene(chat_tree, CurrentLevel.cutscene_force):
		# the player's seen it already, or its 'skip_if' condition is met; don't play the cutscene
		result = false
	else:
		# play the postroll cutscene
		result = true
	return result


## Returns 'true' if we should play an epilogue after this level and its postroll cutscenes.
##
## We play an epilogue if the player's beaten the last level in the current world, and if the player hasn't seen this
## world's epilogue scene yet.
func _should_play_epilogue() -> bool:
	var result := false
	var world_lock: WorldLock = LevelLibrary.world_lock_for_level(CurrentLevel.level_id)
	if not world_lock:
		result = false
	elif not LevelLibrary.is_world_finished(world_lock.world_id):
		# player hasn't beaten the world yet; don't play the epilogue
		result = false
	elif not world_lock.epilogue_chat_key:
		# the world has no epilogue assigned; don't play the epilogue
		result = false
	elif PlayerData.chat_history.is_chat_finished(world_lock.epilogue_chat_key):
		# the player's already seen the epilogue; don't play the epilogue
		result = false
	else:
		# play the epilogue
		result = true
	return result


func _on_Hud_start_button_pressed() -> void:
	_start_puzzle()


func _on_Hud_settings_button_pressed() -> void:
	_settings_menu.show()


func _on_Hud_back_button_pressed() -> void:
	_quit_puzzle()


## Triggers the 'creature feeding' animation.
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
	
	# Calculate whether or not the creature should say something positive about the combo.
	# They say something after clearing [6, 12, 18, 24...] lines.
	if remaining_lines == 0 and PuzzleState.combo >= 6 and total_lines > PuzzleState.combo % 6:
		yield(get_tree().create_timer(0.5), "timeout")
		customer.play_combo_voice()


func _on_PuzzleState_game_started() -> void:
	_settings_menu.quit_type = SettingsMenu.GIVE_UP


## Method invoked when the game ends. Stores the rank result for later.
func _on_PuzzleState_game_ended() -> void:
	if not CurrentLevel.level_id:
		# null check to avoid errors when launching Puzzle.tscn standalone
		return
	
	_settings_menu.quit_type = SettingsMenu.QUIT
	var rank_result := RankCalculator.new().calculate_rank()
	PlayerData.level_history.add(CurrentLevel.level_id, rank_result)
	PlayerData.level_history.prune(CurrentLevel.level_id)
	PlayerData.emit_signal("level_history_changed")
	PlayerData.money = int(clamp(PlayerData.money + rank_result.score, 0, PlayerData.MAX_MONEY))
	
	if PlayerData.career.is_career_mode():
		_update_career_data(rank_result)
	
	if not PuzzleState.level_performance.lost and _overall_rank(rank_result) < 24: $ApplauseSound.play()
	
	CurrentLevel.best_result = max(CurrentLevel.best_result, PuzzleState.end_result())


func _overall_rank(rank_result: RankResult) -> float:
	var result: float
	match CurrentLevel.settings.finish_condition.type:
		Milestone.SCORE:
			result = rank_result.seconds_rank
		_:
			result = rank_result.score_rank
	return result


## Records the player's performance for career mode.
func _update_career_data(rank_result: RankResult) -> void:
	PlayerData.career.daily_earnings = min(PlayerData.career.daily_earnings + rank_result.score,
			PlayerData.MAX_MONEY)
	
	for customer_score in PuzzleState.customer_scores:
		if customer_score == 0:
			# If the player tops out without serving a customer, the customer is not included
			pass
		else:
			PlayerData.career.daily_customers += 1
	
	# Calculate the player's distance to travel based on their overall rank
	var overall_rank := _overall_rank(rank_result)
	
	var milestone_index := CareerData.rank_milestone_index(overall_rank)
	var distance_to_advance: int = CareerData.RANK_MILESTONES[milestone_index].distance
	
	PlayerData.career.daily_steps += distance_to_advance
	PlayerData.career.advance_clock(distance_to_advance, rank_result.success)


## Wait until after the game ends to save the player's data.
##
## This makes the stutter from writing to disk less noticable.
func _on_PuzzleState_after_game_ended() -> void:
	PlayerSave.save_player_data()


func _on_SettingsMenu_quit_pressed() -> void:
	if _settings_menu.quit_type == SettingsMenu.GIVE_UP:
		PuzzleState.make_player_lose()
	else:
		_quit_puzzle()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "finish" and PuzzleState.game_active:
		# finish the current level
		var finish_condition: Milestone = CurrentLevel.settings.finish_condition
		match finish_condition.type:
			Milestone.CUSTOMERS:
				while PuzzleState.customer_scores.size() <= finish_condition.value:
					PuzzleState.customer_scores.insert(0, 100)
			Milestone.LINES:
				PuzzleState.level_performance.lines = finish_condition.value
			Milestone.PIECES:
				PuzzleState.level_performance.pieces = finish_condition.value
			Milestone.SCORE:
				PuzzleState.level_performance.score = finish_condition.value
				PuzzleState.level_performance.seconds += 9999
			Milestone.TIME_OVER, Milestone.TIME_UNDER:
				PuzzleState.level_performance.seconds = finish_condition.value
		
		detector.play_cheat_sound(true)
