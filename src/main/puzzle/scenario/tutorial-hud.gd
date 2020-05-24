class_name TutorialHud
extends Control
"""
UI items specific for puzzle tutorials.
"""

onready var _scenario: Scenario = get_parent()
onready var _puzzle: Puzzle = $"../Puzzle"
onready var _playfield: Playfield = _puzzle.get_playfield()
onready var _piece_manager: PieceManager = _puzzle.get_piece_manager()

var _boxes_made := 0
var _squish_moves := 0

func _ready() -> void:
	visible = false
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	refresh()


"""
Shows or hides the tutorial hud based on the current scenario.
"""
func refresh() -> void:
	# only visible for tutorial scenarios
	visible = Global.scenario_settings.other.tutorial or Global.scenario_settings.other.after_tutorial
	
	if Global.scenario_settings.name.begins_with("tutorial-beginner"):
		# prepare for the 'tutorial-beginner' tutorial
		if not _playfield.is_connected("box_made", self, "_on_Playfield_box_made"):
			_playfield.connect("box_made", self, "_on_Playfield_box_made")
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
		if _playfield.is_connected("box_made", self, "_on_Playfield_box_made"):
			_playfield.disconnect("box_made", self, "_on_Playfield_box_made")
			_playfield.disconnect("after_piece_written", self, "_on_Playfield_after_piece_written")
			_playfield.disconnect("line_cleared", self, "_on_Playfield_line_cleared")
			_piece_manager.disconnect("squish_moved", self, "_on_PieceManager_squish_moved")
			_piece_manager.disconnect("piece_spawned", self, "_on_PieceManager_piece_spawned")


func append_message(message: String) -> void:
	$Message.append_message(message)


func append_big_message(message: String) -> void:
	$Message.append_big_message(message)


func _on_PieceManager_squish_moved() -> void:
	_squish_moves += 1
	if Global.scenario_settings.name == "tutorial-beginner-2":
		# for tutorial-beginner-2, they must perform a squish move or the piece is erased
		_playfield.read_only = false
	if _squish_moves == 1:
		if Global.scenario_settings.name == "tutorial-beginner-2":
			append_message("Well done!\n\nSquish moves can help you out of a jam./"
					+ " They're also good for certain boxes.")
		elif Global.scenario_settings.name in ["tutorial-beginner-0", "tutorial-beginner-1"]:
			append_message("Oh my,/ you're not supposed to know how to do that!\n\n..."
					+ "But yes,/ squish moves can help you out of a jam.")
			$SkillTallyItems/GridContainer/SquishMove.visible = true


func _on_PieceManager_piece_spawned() -> void:
	if Global.scenario_settings.name == "tutorial-beginner-2":
		# for tutorial-beginner-2, they must perform a squish move or the piece is erased
		_playfield.read_only = true


func _on_Playfield_box_made(x: int, y: int, width: int, height: int, color: int) -> void:
	_boxes_made += 1
	if _boxes_made == 1:
		if Global.scenario_settings.name == "tutorial-beginner-1":
			append_message("Well done!\n\nThose boxes earn ¥15 when you clear them./"
					+ " Maybe more if you're clever.")
		elif Global.scenario_settings.name == "tutorial-beginner-0":
			append_message("Oh my,/ you're not supposed to know how to do that!\n\n"
					+ "...But yes,/ those boxes earn $15 when you clear them./"
					+ " Maybe more if you're clever.")
			$SkillTallyItems/GridContainer/SnackBox.visible = true


func _on_Playfield_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	if PuzzleScore.scenario_performance.lines == 1:
		append_message("Well done!\n\nLine clears earn ¥1./ Maybe more if you can build a combo.")


"""
After a piece is written to the playfield, we check if the player should advance further in the tutorial.
"""
func _on_Playfield_after_piece_written() -> void:
	var scenario_name := Global.scenario_settings.name
	if Global.scenario_settings.name == "tutorial-beginner-0":
		if PuzzleScore.scenario_performance.lines >= 2: _advance_scenario()
	elif Global.scenario_settings.name == "tutorial-beginner-1":
		if _boxes_made >= 2: _advance_scenario()
	elif Global.scenario_settings.name == "tutorial-beginner-2":
		if _squish_moves >= 2: _advance_scenario()


func _advance_scenario() -> void:
	if PuzzleScore.scenario_performance.score >= Global.scenario_settings.finish_condition.value \
			and Global.scenario_settings.name in ["tutorial-beginner-0", "tutorial-beginner-1",
				"tutorial-beginner-2"]:
		# 100 points is a remarkable feat; skip the tutorial entirely
		_change_scenario("oh-my")
		append_big_message("O/H/,/// M/Y/!/!/!")
		$Message.set_pop_out_timer(1.0)
		_scenario.init_milestone_hud()
	elif PuzzleScore.scenario_performance.lines == 0:
		_change_scenario("tutorial-beginner-0")
	elif _boxes_made == 0:
		_change_scenario("tutorial-beginner-1")
	elif _squish_moves == 0:
		_change_scenario("tutorial-beginner-2")
	else:
		_change_scenario("tutorial-beginner-3")


"""
Change to a new tutorial scenario.
"""
func _change_scenario(name: String) -> void:
	Global.scenario_settings = ScenarioLibrary.load_scenario_from_name(name)
	_scenario.prepare_scenario()
	$SkillTallyItems.visible = Global.scenario_settings.other.tutorial
	_flash()
	match(name):
		"tutorial-beginner-1":
			$SkillTallyItems/GridContainer/SnackBox.visible = true
			append_message("Good job!\n\nTry making a snack box by arranging two pieces into a square.")
		"tutorial-beginner-2":
			$SkillTallyItems/GridContainer/SquishMove.visible = true
			append_message("Nicely done!\n\nNext, try holding soft drop to squish these pieces through these gaps.")
		"tutorial-beginner-3":
			_playfield.break_combo()
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
	_boxes_made = 0
	_squish_moves = 0
	$Message.hide_text()
	append_message("Welcome to Turbo Fat!//"
			+ " You seem to already be familiar with this sort of game,/ so let's dive right in.")


func _on_PuzzleScore_game_started() -> void:
	append_message("Clear a row by filling it with blocks.")
