## Maintains the flow of scenes in career mode. Redirects the player to cutscenes, victory screens and interludes.

var career_data: CareerData

func _init(init_career_data: CareerData) -> void:
	career_data = init_career_data


## Launches the next scene in career mode. Either a new level, or a cutscene/ending scene.
func push_career_trail() -> void:
	# Purge any puzzle or cutscene scenes from trail before changing the scene.
	while Breadcrumb.trail.front() != Global.SCENE_CAREER_MAP:
		Breadcrumb.trail.pop_front()
	
	var redirected := false
	if not redirected and not PlayerData.cutscene_queue.is_queue_empty():
		# If there are pending puzzles/cutscenes, show them.
		PlayerData.cutscene_queue.push_trail()
		redirected = true
	
	if not redirected and should_play_prologue():
		# If they haven't seen the region's prologue cutscene, we show it.
		var region: CareerRegion = career_data.current_region()
		var prologue_chat_key: String = region.get_prologue_chat_key()
		CurrentCutscene.set_launched_cutscene(prologue_chat_key)
		CurrentCutscene.push_cutscene_trail()
		redirected = true
	
	if not redirected and not career_data.can_play_more_levels() \
			and career_data.show_progress == Careers.ShowProgress.NONE:
		# If the day is over, they're redirected to the career map to view the progress board. But if they don't need
		# to view the progress board, we can redirect them directly to the career win screen.
		SceneTransition.replace_trail(Global.SCENE_CAREER_WIN)
		redirected = true
	
	if not redirected:
		# After a puzzle (or any other scene), we go back to the career map.
		SceneTransition.change_scene()


## Updates the state of career mode based on the player's puzzle performance.
##
## If the player skips or fails a level, this has consequences including skipping cutscenes and advancing the clock.
func process_puzzle_result() -> void:
	var skip_remaining_cutscenes := false
	if not PuzzleState.game_ended:
		# player skipped a level
		skip_remaining_cutscenes = true
		career_data.advance_clock(0, false)
		career_data.skipped_previous_level = true
	
	if PlayerData.cutscene_queue.has_cutscene_flag("intro_level") and PlayerData.career.lost:
		# player lost an intro level
		skip_remaining_cutscenes = true
	
	if PlayerData.cutscene_queue.has_cutscene_flag("boss_level") \
			and not CurrentLevel.first_result == Levels.Result.WON:
		# player didn't meet the win criteria for a boss level
		skip_remaining_cutscenes = true
	
	if skip_remaining_cutscenes:
		# skip career cutscenes if they skip a level, or if they fail a boss level
		PlayerData.cutscene_queue.reset()
	
	if PuzzleState.game_ended and CurrentLevel.hardcore and not PlayerData.career.lost:
		# completing a hardcore level gives the player an extra life
		career_data.extra_life_count += 1
	
	if not PuzzleState.game_ended and CurrentLevel.hardcore:
		# skipping a hardcore level ends the career day
		career_data.hours_passed = Careers.HOURS_PER_CAREER_DAY


## Returns 'true' if the current career region has a prologue the player hasn't seen.
func should_play_prologue() -> bool:
	var region: CareerRegion = career_data.current_region()
	var prologue_chat_key: String = region.get_prologue_chat_key()
	return ChatLibrary.chat_exists(prologue_chat_key) \
			and not PlayerData.chat_history.is_chat_finished(prologue_chat_key)
