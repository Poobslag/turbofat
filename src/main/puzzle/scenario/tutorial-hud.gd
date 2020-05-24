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
	
	if Global.scenario_settings.other.tutorial:
		# only visible for tutorial scenarios
		visible = true
	
	if Global.scenario_settings.name.begins_with("tutorial-beginner"):
		# prepare for the 'tutorial-beginner' tutorial
		_playfield.connect("box_made", self, "_on_Playfield_box_made")
		_playfield.connect("after_piece_written", self, "_on_Playfield_after_piece_written")
		_piece_manager.connect("squish_moved", self, "_on_PieceManager_squish_moved")
		_piece_manager.connect("piece_spawned", self, "_on_PieceManager_piece_spawned")
		$SkillTallyItems/GridContainer/MoveLeft.visible = true
		$SkillTallyItems/GridContainer/MoveRight.visible = true
		$SkillTallyItems/GridContainer/RotateLeft.visible = true
		$SkillTallyItems/GridContainer/RotateRight.visible = true
		$SkillTallyItems/GridContainer/SoftDrop.visible = true
		$SkillTallyItems/GridContainer/HardDrop.visible = true
		$SkillTallyItems/GridContainer/LineClear.visible = true


func _on_PieceManager_squish_moved() -> void:
	if Global.scenario_settings.name in ["tutorial-beginner-0", "tutorial-beginner-1"]:
		# player skipped the 'squisk move' section of the tutorial
		$SkillTallyItems/GridContainer/SquishMove.visible = true
	if Global.scenario_settings.name == "tutorial-beginner-2":
		# for tutorial-beginner-2, they must perform a squish move or the piece is erased
		_playfield.read_only = false
	_squish_moves += 1


func _on_PieceManager_piece_spawned() -> void:
	if Global.scenario_settings.name == "tutorial-beginner-2":
		# for tutorial-beginner-2, they must perform a squish move or the piece is erased
		_playfield.read_only = true


func _on_Playfield_box_made(x: int, y: int, width: int, height: int, color: int) -> void:
	_boxes_made += 1
	if Global.scenario_settings.name == "tutorial-beginner-0":
		# player skipped the 'snack box' section of the tutorial
		$SkillTallyItems/GridContainer/SnackBox.visible = true


"""
After a piece is written to the playfield, we check if the player should advance further in the tutorial.
"""
func _on_Playfield_after_piece_written() -> void:
	var scenario_name := Global.scenario_settings.name
	if PuzzleScore.scenario_performance.score >= Global.scenario_settings.finish_condition.value \
			and scenario_name in ["tutorial-beginner-0", "tutorial-beginner-1", "tutorial-beginner-2"]:
		# 100 points is a remarkable feat; skip the tutorial entirely
		_change_scenario("oh-my")
		_scenario.init_milestone_hud()
	elif Global.scenario_settings.name == "tutorial-beginner-0":
		if PuzzleScore.scenario_performance.lines >= 2:
			# player has completed the first part of the tutorial
			if $SkillTallyItems/GridContainer/SnackBox.visible and $SkillTallyItems/GridContainer/SquishMove.visible:
				_change_scenario("tutorial-beginner-3")
				_playfield.break_combo()
			elif $SkillTallyItems/GridContainer/SnackBox.visible:
				_change_scenario("tutorial-beginner-2")
			else:
				_change_scenario("tutorial-beginner-1")
				$SkillTallyItems/GridContainer/SnackBox.visible = true
	elif Global.scenario_settings.name == "tutorial-beginner-1":
		if _boxes_made >= 2:
			# player has completed the second part of the tutorial
			if $SkillTallyItems/GridContainer/SquishMove.visible:
				_change_scenario("tutorial-beginner-3")
				_playfield.break_combo()
			else:
				_change_scenario("tutorial-beginner-2")
				$SkillTallyItems/GridContainer/SquishMove.visible = true
	elif Global.scenario_settings.name == "tutorial-beginner-2":
		if _squish_moves >= 2:
			# player has completed the third part of the tutorial
			_change_scenario("tutorial-beginner-3")
			_playfield.break_combo()


"""
Advance the player further in the tutorial.
"""
func _change_scenario(name: String) -> void:
	Global.scenario_settings = ScenarioLibrary.load_scenario_from_name(name)
	_scenario.prepare_scenario()
	$SkillTallyItems.visible = Global.scenario_settings.other.tutorial
	_flash()


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
