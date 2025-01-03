class_name TutorialModule
extends Node
## Generic tutorial module for all tutorials.
##
## Subclasses can show messages and advances the player through the tutorial as they complete tasks.

## generic nodes used by tutorial module subclasses
var hud: TutorialHud
var puzzle: Puzzle
var playfield: Playfield
var piece_manager: PieceManager

## if 'true', the next level change will be accompanied by a 'Ready? Go!' countdown
var _start_customer_countdown := false

## if 'true', the player cannot currently restart the current tutorial section
var _suppress_restart := false

func _ready() -> void:
	puzzle = hud.puzzle
	playfield = puzzle.get_playfield()
	piece_manager = puzzle.get_piece_manager()
	
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	
	for skill_tally_item in $SkillTallyItems.get_children():
		if skill_tally_item is SkillTallyItem:
			var new_item: SkillTallyItem = skill_tally_item.duplicate()
			new_item.puzzle = hud.puzzle
			hud.add_skill_tally_item(new_item)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		return
	
	if event.is_action_pressed("retry"):
		if not PuzzleState.game_active and not PuzzleState.game_ended:
			# still at the start of a puzzle; don't retry
			pass
		elif PuzzleState.game_ended:
			# puzzle has ended; 'retrying a section' doesn't make sense
			pass
		elif (CurrentLevel.is_tutorial() or CurrentLevel.settings.other.after_tutorial) \
				and not CurrentLevel.settings.other.non_interactive \
				and not _suppress_restart:
			_restart_tutorial_section()


## Cleans up any temporary timers and listeners.
##
## This prevents the tutorial from behaving unexpectedly if the player restarts at an unusual time.
func cleanup_listeners() -> void:
	if hud.messages.is_connected("all_messages_shown", self, "_on_TutorialMessages_all_messages_shown_start_timer"):
		hud.messages.disconnect("all_messages_shown", self, "_on_TutorialMessages_all_messages_shown_start_timer")


## Starts a countdown and switches from tutorial music to regular music.
##
## This is used at the end of each tutorial when customers come in.
func start_customer_countdown() -> void:
	_start_customer_countdown = true


## Resets the timer and scores and dismisses the sensei, so the player can serve some real customers.
##
## Parameters:
## 	'messages': Array of string messages to be shown when the sensei is dismissed.
func dismiss_sensei(messages: Array) -> void:
	PuzzleState.reset()
	puzzle.scroll_to_new_customer()
	hud.set_messages(messages)
	hud.enqueue_pop_out()


## Prepares the next section of the tutorial.
##
## This includes resetting the combo and hiding all completed skill tally items. Subclasses can override this method to
## prepare other aspects of the level as well.
func prepare_tutorial_level() -> void:
	# Reset the player's combo between puzzle sections. Each tutorial section should have a fresh start; We don't want
	# them to receive a discouraging 'you broke your combo' fanfare at the start of a section.
	PuzzleState.set_combo(0)
	PuzzleState.tutorial_section_finished = false
	PuzzleState.level_performance.lost = false
	PuzzleState.topping_out = false
	
	# Hide all completed skill tally items.
	for skill_tally_item_obj in hud.skill_tally_items():
		var skill_tally_item: SkillTallyItem = skill_tally_item_obj
		if skill_tally_item.is_complete():
			skill_tally_item.visible = false


## Changes a level after all tutorial messages are shown.
##
## Copy/pasted from PuzzleState.change_level with an extra yield statement added.
func change_level(level_id: String, delay_between_levels: float = Tutorials.DELAY_SHORT) -> void:
	_suppress_restart = true
	PuzzleState.prepare_level_change(level_id)
	start_timer_after_all_messages_shown(delay_between_levels) \
			.connect("timeout", self, "_on_Timer_timeout_change_level", [level_id])


## Creates and starts a timer after all tutorial messages are shown.
##
## Parameters:
## 	'wait_time': The amount of time to wait after all messages are shown. A value of '0.0' will result in an error.
##
## Returns:
## 	Timer which has been added to the scene tree. The timer may be active or inactive depending on whether the
## 	tutorial messages are still being written to the user.
func start_timer_after_all_messages_shown(wait_time: float) -> Timer:
	var timer := PuzzleState.add_timer(wait_time)
	
	if not hud.messages.is_all_messages_visible():
		hud.messages.connect("all_messages_shown", self, "_on_TutorialMessages_all_messages_shown_start_timer",
				[timer])
	else:
		timer.start()
	
	return timer


func _restart_tutorial_section() -> void:
	if _suppress_restart:
		return
	
	_suppress_restart = true
	PuzzleState.prepare_level_change(CurrentLevel.settings.id)
	
	# clear timers to avoid side effects when replaying scheduled events from a previous attempt
	PuzzleState.clear_timers()
	PuzzleState.change_level(CurrentLevel.settings.id)
	PuzzleState.game_active = true


func _on_TutorialMessages_all_messages_shown_start_timer(timer: Timer) -> void:
	hud.messages.disconnect("all_messages_shown", self, "_on_TutorialMessages_all_messages_shown_start_timer")
	if timer:
		timer.start()


func _on_Timer_timeout_queue_free(timer: Timer) -> void:
	if timer:
		timer.queue_free()


func _on_Timer_timeout_change_level(level_id: String) -> void:
	PuzzleState.change_level(level_id)


func _on_PuzzleState_after_level_changed() -> void:
	prepare_tutorial_level()
	
	if _start_customer_countdown:
		_start_customer_countdown = false
		MusicPlayer.play_puzzle_track(false)
		PuzzleState.game_active = true
		puzzle.start_level_countdown()
	_suppress_restart = false


func _on_PuzzleState_game_ended() -> void:
	_start_customer_countdown = false
	cleanup_listeners()


func _on_PuzzleState_game_prepared() -> void:
	_start_customer_countdown = false
	cleanup_listeners()
