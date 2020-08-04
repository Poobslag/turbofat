class_name TutorialHud
extends Control
"""
UI items specific for puzzle tutorials.
"""

export (NodePath) var puzzle_path: NodePath

onready var _puzzle:Puzzle = get_node(puzzle_path)
onready var _playfield: Playfield = _puzzle.get_playfield()
onready var _piece_manager: PieceManager = _puzzle.get_piece_manager()

# tracks what the player has done so far during this tutorial
var _lines_cleared := 0
var _boxes_built := 0
var _squish_moves := 0
var _snack_stacks := 0

# tracks what the player did with the most recent piece
var _did_line_clear := false
var _did_build_box := false
var _did_build_cake := false
var _did_squish_move := false

func _ready() -> void:
	visible = false
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	Scenario.connect("settings_changed", self, "_on_Scenario_settings_changed")
	for skill_tally_item_obj in $SkillTallyItems/GridContainer.get_children():
		var skill_tally_item: SkillTallyItem = skill_tally_item_obj
		skill_tally_item.set_puzzle(_puzzle)
	refresh()
	
	if Scenario.settings.name.begins_with("tutorial-beginner"):
		_puzzle.hide_start_button()
		_puzzle.hide_back_button()
		yield(get_tree().create_timer(0.40), "timeout")
		append_message("Welcome to Turbo Fat!//"
				+ " You seem to already be familiar with this sort of game,/ so let's dive right in.")
		yield(get_tree().create_timer(0.80), "timeout")
		_puzzle.show_start_button()
		if PlayerData.scenario_history.finished_scenarios.has(Scenario.BEGINNER_TUTORIAL):
			_puzzle.show_back_button()


"""
Shows or hides the tutorial hud based on the current scenario.
"""
func refresh() -> void:
	# only visible for tutorial scenarios
	visible = Scenario.settings.other.tutorial or Scenario.settings.other.after_tutorial
	
	for item in $SkillTallyItems/GridContainer.get_children():
		item.visible = false
	
	if Scenario.settings.name.begins_with("tutorial-beginner"):
		# prepare for the 'tutorial-beginner' tutorial
		if not _playfield.is_connected("box_built", self, "_on_Playfield_box_built"):
			_playfield.connect("box_built", self, "_on_Playfield_box_built")
			_playfield.connect("after_piece_written", self, "_on_Playfield_after_piece_written")
			_playfield.connect("line_cleared", self, "_on_Playfield_line_cleared")
			_piece_manager.connect("squish_moved", self, "_on_PieceManager_squish_moved")
			_piece_manager.connect("piece_spawned", self, "_on_PieceManager_piece_spawned")
		$SkillTallyItems/GridContainer/MoveLeft.visible = true
		$SkillTallyItems/GridContainer/MoveRight.visible = true
		$SkillTallyItems/GridContainer/RotateLeft.visible = true
		$SkillTallyItems/GridContainer/RotateRight.visible = true
		$SkillTallyItems/GridContainer/SoftDrop.visible = true
		$SkillTallyItems/GridContainer/HardDrop.visible = true
		$SkillTallyItems/GridContainer/LineClear.visible = true
	else:
		if _playfield.is_connected("box_built", self, "_on_Playfield_box_built"):
			_playfield.disconnect("box_built", self, "_on_Playfield_box_built")
			_playfield.disconnect("after_piece_written", self, "_on_Playfield_after_piece_written")
			_playfield.disconnect("line_cleared", self, "_on_Playfield_line_cleared")
			_piece_manager.disconnect("squish_moved", self, "_on_PieceManager_squish_moved")
			_piece_manager.disconnect("piece_spawned", self, "_on_PieceManager_piece_spawned")


func append_message(message: String) -> void:
	$Message.append_message(message)


func append_big_message(message: String) -> void:
	$Message.append_big_message(message)


func _on_PieceManager_piece_spawned() -> void:
	_did_line_clear = false
	_did_squish_move = false
	_did_build_box = false
	_did_build_cake = false


func _on_PieceManager_squish_moved(_piece: ActivePiece, _old_pos: Vector2) -> void:
	_did_squish_move = true
	_squish_moves += 1


func _on_Playfield_box_built(_rect: Rect2, color: int) -> void:
	_did_build_box = true
	_boxes_built += 1
	
	if color == PuzzleTileMap.BoxColorInt.CAKE:
		_did_build_cake = true


func _on_Playfield_line_cleared(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	_did_line_clear = true
	_lines_cleared += 1


func _handle_line_clear_message() -> void:
	if _did_line_clear and _lines_cleared == 1:
		append_message("Well done!\n\nLine clears earn ¥1./ Maybe more if you can build a combo.")


func _handle_squish_move_message() -> void:
	if _did_squish_move and _squish_moves == 1:
		match Scenario.settings.name:
			"tutorial-beginner-0", "tutorial-beginner-1":
				append_message("Oh my,/ you're not supposed to know how to do that!\n\n..."
						+ "But yes,/ squish moves can help you out of a jam.")
				$SkillTallyItems/GridContainer/SquishMove.visible = true
				$SkillTallyItems/GridContainer/SquishMove.increment()
			"tutorial-beginner-2":
				append_message("Well done!\n\nSquish moves can help you out of a jam./"
						+ " They're also good for certain boxes.")


func _handle_build_box_message() -> void:
	if _did_build_box and _boxes_built == 1:
		match Scenario.settings.name:
			"tutorial-beginner-0":
				append_message("Oh my,/ you're not supposed to know how to do that!\n\n"
						+ "...But yes,/ those boxes earn $15 when you clear them./"
						+ " Maybe more if you're clever.")
				$SkillTallyItems/GridContainer/SnackBox.visible = true
				$SkillTallyItems/GridContainer/SnackBox.increment()
			"tutorial-beginner-1":
				append_message("Well done!\n\nThose boxes earn ¥15 when you clear them./"
				+ " Maybe more if you're clever.")


func _handle_snack_stack_message() -> void:
	if Scenario.settings.name == "tutorial-beginner-3" and _did_build_box and _did_squish_move:
		_snack_stacks += 1
		$SkillTallyItems/GridContainer/SnackStack.increment()
		if _snack_stacks == 1:
			append_message("Impressive!/ Using squish moves,/" \
					+ " you can organize boxes in tall vertical stacks and earn a lot of money.")	


"""
After a piece is written to the playfield, we check if the player should advance further in the tutorial.
"""
func _on_Playfield_after_piece_written() -> void:
	# print tutorial messages if the player did something noteworthy
	_handle_line_clear_message()
	_handle_squish_move_message()
	_handle_build_box_message()
	_handle_snack_stack_message()
	
	match Scenario.settings.name:
		"tutorial-beginner-0":
			if _lines_cleared >= 2: _advance_scenario()
		"tutorial-beginner-1":
			if _boxes_built >= 2: _advance_scenario()
		"tutorial-beginner-2":
			if not _did_squish_move:
				_playfield.tile_map.restore_state()
			if _squish_moves >= 2:
				_advance_scenario()
		"tutorial-beginner-3":
			if not _did_build_box:
				_playfield.tile_map.restore_state()
			if _snack_stacks >= 2:
				_advance_scenario()


func _advance_scenario() -> void:
	# clear out any text to ensure we don't end up pages behind, if the player is fast
	$Message.hide_text()
	
	if Scenario.settings.name == "tutorial-beginner-0" and _did_build_cake and _did_squish_move:
		# the player did something crazy; skip the tutorial entirely
		_change_scenario("oh-my")
		append_big_message("O/H/,/// M/Y/!/!/!")
		$Message.set_pop_out_timer(1.0)
		
		# force match to end
		PuzzleScore.scenario_performance.lines = 100
	elif _lines_cleared == 0:
		_change_scenario("tutorial-beginner-0")
	elif _boxes_built == 0:
		_change_scenario("tutorial-beginner-1")
	elif _squish_moves == 0:
		_change_scenario("tutorial-beginner-2")
	elif _snack_stacks == 0:
		_change_scenario("tutorial-beginner-3")
	else:
		_change_scenario("tutorial-beginner-4")
		MusicPlayer.play_upbeat_bgm()


"""
Change to a new tutorial scenario.
"""
func _change_scenario(name: String) -> void:
	var settings := ScenarioSettings.new()
	settings.load_from_resource(name)
	Scenario.switch_scenario(settings)
	
	$SkillTallyItems.visible = Scenario.settings.other.tutorial
	_flash()
	match(name):
		"tutorial-beginner-1":
			$SkillTallyItems/GridContainer/SnackBox.visible = true
			append_message("Good job!\n\nTry making a snack box by arranging two pieces into a square.")
		"tutorial-beginner-2":
			$SkillTallyItems/GridContainer/SquishMove.visible = true
			append_message("Nicely done!\n\nNext, try holding soft drop to squish these pieces through these gaps.")
		"tutorial-beginner-3":
			$SkillTallyItems/GridContainer/SnackStack.visible = true
			append_message("One last lesson! Try holding soft drop to squish and complete these boxes.")
		"tutorial-beginner-4":
			# reset timer, scores
			PuzzleScore.reset()
			_puzzle.scroll_to_new_creature()
			
			append_message("You're a remarkably quick learner." \
					+ "/ I think I hear some customers!\n\nSee if you can earn ¥100.")
			$Message.set_pop_out_timer(3.0)


"""
Pause and play a camera flash effect for transitions.
"""
func _flash() -> void:
	_playfield.add_misc_delay_frames(30)
	$SectionCompleteSound.play()
	$ZIndex/ColorRect.modulate.a = 0.25
	$Tween.remove_all()
	$Tween.interpolate_property($ZIndex/ColorRect, "modulate:a", $ZIndex/ColorRect.modulate.a, 0.0, 1.0)
	$Tween.start()


func _on_PuzzleScore_game_prepared() -> void:
	if Scenario.settings.other.tutorial:
		# summon the instructor. this is redundant for the first attempt of a tutorial, but necessary when retrying
		_puzzle.summon_instructor()
	
	_lines_cleared = 0
	_boxes_built = 0
	_squish_moves = 0
	_snack_stacks = 0
	refresh()


func _on_Scenario_settings_changed() -> void:
	refresh()


func _on_PuzzleScore_game_started() -> void:
	append_message("Clear a row by filling it with blocks.")
