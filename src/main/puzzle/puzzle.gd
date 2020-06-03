class_name Puzzle
extends Control
"""
Represents a minimal puzzle game with a piece, playfield of pieces, and next pieces. Other classes can extend this
class to add goals, win conditions, challenges or time limits.
"""

signal topped_out

func _ready() -> void:
	PuzzleScore.reset() # erase any lines/score from previous games
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	$Playfield/TileMapClip/TileMap/Viewport/ShadowMap.piece_tile_map = $PieceManager/TileMap
	
	for i in range(3):
		$CreatureView.summon_creature(i)
	
	if Scenario.settings.other.tutorial:
		Global.creature_queue.push_front({
			"line_rgb": "6c4331", "body_rgb": "a854cb", "eye_rgb": "4fa94e dbe28e", "horn_rgb": "f1e398",
			"ear": "3", "horn": "0", "mouth": "2", "eye": "2"
		})
	$CreatureView.summon_creature()


func get_playfield() -> Playfield:
	return $Playfield as Playfield


func get_piece_manager() -> PieceManager:
	return $PieceManager as PieceManager


func hide_start_button() -> void:
	$HudHolder/Hud.hide_start_button()


func show_start_button() -> void:
	$HudHolder/Hud.show_start_button()


func scroll_to_new_creature() -> void:
	$CreatureView.scroll_to_new_creature()


"""
Triggers the eating animation and makes the creature fatter. Accepts a 'fatness_pct' parameter which defines how
much fatter the creature should get. We can calculate how fat they should be, and a value of 0.4 means the creature
should increase by 40% of the amount needed to reach that target.

This 'fatness_pct' parameter is needed for the scenario where the player eliminates three lines at once. We don't
want the creature to suddenly grow full size. We want it to take 3 bites.

Parameters:
	'fatness_pct' A percent from [0.0-1.0] of how much fatter the creature should get from this bite of food.
"""
func _feed_creature(fatness_pct: float) -> void:
	$CreatureView.get_creature().feed()
	
	if PuzzleScore.game_active:
		var old_fatness: float = $CreatureView.get_creature().get_fatness()
		var target_fatness := sqrt(1 + PuzzleScore.get_creature_score() / 50.0)
		if Scenario.settings.other.tutorial:
			# make them a tiny amount fatter, so that they'll change when a new level is started
			target_fatness = min(target_fatness, 1.001)
		$CreatureView.get_creature().set_fatness(lerp(old_fatness, target_fatness, fatness_pct))


func _on_Hud_start_button_pressed() -> void:
	PuzzleScore.prepare_and_start_game()


"""
Triggers the 'creature feeding' animation.
"""
func _on_Playfield_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	if not $Playfield.awarding_line_clear_points:
		# lines were cleared from top out or another unusual case. don't feed the creature
		return
	
	# Calculate whether or not the creature should say something positive about the combo. The creature talks after
	var creature_talks: bool = remaining_lines == 0 and $Playfield/ComboTracker.combo >= 5 \
			and total_lines > ($Playfield/ComboTracker.combo + 1) % 3
	
	_feed_creature(1.0 / (remaining_lines + 1))
	
	if creature_talks:
		yield(get_tree().create_timer(0.5), "timeout")
		$CreatureView.get_creature().play_combo_voice()


"""
Method invoked when the game ends. Stores the rank result for later.
"""
func _on_PuzzleScore_game_ended() -> void:
	# ensure score is up to date before calculating rank
	PuzzleScore.end_combo()
	var rank_result := RankCalculator.new().calculate_rank()
	PlayerData.scenario_history.add(Scenario.launched_scenario_name, rank_result)
	PlayerData.scenario_history.prune(Scenario.launched_scenario_name)
	PlayerData.money += rank_result.score
	PlayerSave.save_player_data()
	
	match Scenario.settings.finish_condition.type:
		Milestone.SCORE:
			if not PuzzleScore.scenario_performance.lost and rank_result.seconds_rank < 24: $ApplauseSound.play()
		_:
			if not PuzzleScore.scenario_performance.lost and rank_result.score_rank < 24: $ApplauseSound.play()
