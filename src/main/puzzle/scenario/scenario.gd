class_name Scenario
extends Control
"""
Contains the logic for running a puzzle scenario. A puzzle scenario might include specific rules or win conditions
such as 'Marathon mode', a game style which gets harder and harder but theoretically goes on forever if the player is
good enough.
"""

var _rank_calculator := RankCalculator.new()

func _ready() -> void:
	PuzzleScore.reset() # erase any lines/score from previous games
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("after_game_prepared", self, "_on_PuzzleScore_after_game_prepared")
	
	# Intuitively MilestoneHud could initialize its own milebar on _ready, but there is no guarantee it will happen
	# after PuzzleScore.reset(). As a workaround, this class initializes the MilestoneHud's milebar after resetting
	# PuzzleScore.
	$Puzzle.get_milestone_hud().init_milebar()
	
	if Global.scenario_settings.other.tutorial:
		Global.customer_queue.push_front({
			"line_rgb": "6c4331", "body_rgb": "a854cb", "eye_rgb": "4fa94e dbe28e", "horn_rgb": "f1e398",
			"ear": "2", "horn": "0", "mouth": "1", "eye": "1"
		})
		$Puzzle/CustomerView.summon_customer()
	prepare_scenario()


func _physics_process(_delta: float) -> void:
	if not PuzzleScore.game_active:
		return
	
	if PuzzleScore.milestone_met(Global.scenario_settings.finish_condition):
		$Puzzle.end_game()


func _on_PuzzleScore_after_game_prepared() -> void:
	prepare_scenario()


func prepare_scenario() -> void:
	prepare_blocks()
	prepare_piece_types()
	prepare_tutorial()


func prepare_tutorial() -> void:
	var tutorial_scenario: bool = Global.scenario_settings.other.tutorial
	$Puzzle.set_chalkboard_visible(!tutorial_scenario)
	$TutorialHud.refresh()


func prepare_blocks() -> void:
	$Puzzle.clear_playfield()
	var blocks_start := Global.scenario_settings.blocks_start
	for cell in blocks_start.used_cells:
		$Puzzle.set_block(cell, blocks_start.tiles[cell], blocks_start.autotile_coords[cell])


func prepare_piece_types() -> void:
	$Puzzle.set_piece_types(Global.scenario_settings.piece_types.types)
	$Puzzle.set_piece_start_types(Global.scenario_settings.piece_types.start_types)


"""
Method invoked when the game ends. Stores the rank result for later.
"""
func _on_PuzzleScore_game_ended() -> void:
	# ensure score is up to date before calculating rank
	PuzzleScore.end_combo()
	var rank_result := _rank_calculator.calculate_rank()
	PlayerData.scenario_history.add(Global.launched_scenario_name, rank_result)
	PlayerData.scenario_history.prune(Global.launched_scenario_name)
	PlayerData.money += rank_result.score
	PlayerSave.save_player_data()
	
	match Global.scenario_settings.finish_condition.type:
		Milestone.SCORE:
			if not PuzzleScore.scenario_performance.lost and rank_result.seconds_rank < 24: $ApplauseSound.play()
		_:
			if not PuzzleScore.scenario_performance.lost and rank_result.score_rank < 24: $ApplauseSound.play()
