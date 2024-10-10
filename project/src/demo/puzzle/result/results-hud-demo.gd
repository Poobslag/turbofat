extends Node
## Demonstrates the end of level results message.
##
## Keys:
## 	[0]: Show message for a marathon level where the player did nothing.
## 	[1,2,3]: Show message for a marathon level where the player did bad/ok/good.
## 	[Q,W,E]: Show message for a long ultra level where the player did bad/ok/good.
## 	[R]: Show message for a long ultra level which the player skipped with a cheat code.
## 	[A,S,D]: Show message for a short ultra level where the player did bad/ok/good.
## 	[F]: Show message for a short ultra level which the player skipped with a cheat code.
## 	[H]: Toggle hardcore/normal.
## 	[J]: Toggle passed/failed.
## 	[K]: Toggle success condition, and boss level.
## 	[L]: Toggle whether or not the player has beaten the level already.
## 	[Space]: Show/hide message

onready var _label := $Label
onready var _results_hud := $ResultsHud

var _success_condition := false
var _player_success := false

func _ready() -> void:
	PlayerData.money = 25000
	CurrentLevel.level_id = "divergent_sniff_humor"
	_prepare_marathon_scenario(0.5)
	
	# prepare everything necessary for the 'hardcore reward'
	Breadcrumb.trail = [Global.SCENE_CAREER_MAP]
	CurrentLevel.attempt_count = 0
	CurrentLevel.hardcore = true
	CurrentLevel.best_result = Levels.Result.FINISHED


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0:
			_prepare_marathon_scenario(0.0)
			_show_results_message()
		KEY_1:
			_prepare_marathon_scenario(0.1)
			_show_results_message()
		KEY_2:
			_prepare_marathon_scenario(0.3)
			_show_results_message()
		KEY_3:
			_prepare_marathon_scenario(1.0)
			_show_results_message()
		KEY_Q:
			_prepare_long_ultra_scenario(0.1)
			_show_results_message()
		KEY_W:
			_prepare_long_ultra_scenario(0.3)
			_show_results_message()
		KEY_E:
			_prepare_long_ultra_scenario(1.0)
			_show_results_message()
		KEY_R:
			_prepare_long_ultra_scenario(0.1)
			PuzzleState.level_performance.seconds += 9999
			_show_results_message()
		KEY_A:
			_prepare_short_ultra_scenario(0.1)
			_show_results_message()
		KEY_S:
			_prepare_short_ultra_scenario(0.3)
			_show_results_message()
		KEY_D:
			_prepare_short_ultra_scenario(1.0)
			_show_results_message()
		KEY_F:
			_prepare_short_ultra_scenario(0.1)
			PuzzleState.level_performance.seconds += 9999
			_show_results_message()
		KEY_H:
			CurrentLevel.hardcore = not CurrentLevel.hardcore
			_show_results_message()
		KEY_J:
			PuzzleState.level_performance.lost = not PuzzleState.level_performance.lost
			CurrentLevel.best_result = \
					Levels.Result.LOST if PuzzleState.level_performance.lost else Levels.Result.FINISHED
			_show_results_message()
		KEY_K:
			if not _success_condition:
				_success_condition = true
			elif _success_condition and not CurrentLevel.boss_level:
				CurrentLevel.boss_level = true
			else:
				_success_condition = false
				CurrentLevel.boss_level = false
			_refresh_success_condition()
			_show_results_message()
		KEY_L:
			_player_success = not _player_success
			_refresh_success_condition()
			_show_results_message()
		KEY_SPACE:
			if _results_hud.is_results_message_shown():
				_results_hud.hide_results_message()
			else:
				_show_results_message()


func _show_results_message() -> void:
	_label.text = ""
	_label.text += "finish_condition: %s\n" % [CurrentLevel.settings.finish_condition.to_json_dict()]
	_label.text += "success_condition: %s\n" % [CurrentLevel.settings.success_condition.to_json_dict()]
	_label.text += "\n"
	_label.text += "boss_level: %s\n" % [CurrentLevel.boss_level]
	_label.text += "player_success: %s\n" % [_player_success]
	_label.text += "hardcore: %s\n" % [CurrentLevel.hardcore]
	_label.text += "lost: %s\n" % [PuzzleState.level_performance.lost]
	_label.text = _label.text.strip_edges()
	
	_results_hud.reset()
	_results_hud.show_results_message()


func _refresh_success_condition() -> void:
	# assign the current level's success condition based on the '_success_condition' field
	CurrentLevel.settings.set_success_condition(Milestone.NONE, 0)
	if _success_condition:
		if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
			CurrentLevel.settings.success_condition.type = Milestone.TIME_UNDER
		else:
			CurrentLevel.settings.success_condition.type = Milestone.SCORE
		
		var rank_criteria := RankCriteria.new()
		rank_criteria.copy_from(CurrentLevel.settings.rank.rank_criteria)
		rank_criteria.duration_criteria = CurrentLevel.settings.finish_condition.type == Milestone.SCORE
		rank_criteria.fill_missing_thresholds()
		CurrentLevel.settings.success_condition.value = rank_criteria.thresholds_by_grade["AA+"]
	
	# update the player's level history based on the '_player_success' field
	PlayerData.level_history.delete_results(CurrentLevel.level_id)
	if _player_success:
		if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
			_add_time_result(int(floor(CurrentLevel.settings.success_condition.value * 0.8)))
		else:
			_add_score_result(int(ceil(CurrentLevel.settings.success_condition.value * 1.2)))


func _prepare_marathon_scenario(skill_factor: float) -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("M", 10000)
	PuzzleState.level_performance.seconds = 600.0
	PuzzleState.level_performance.lines = 300 * skill_factor
	PuzzleState.level_performance.box_score = 2790 * skill_factor
	PuzzleState.level_performance.combo_score = 4800 * skill_factor
	PuzzleState.level_performance.score = 7890 * skill_factor
	_refresh_success_condition()


func _prepare_long_ultra_scenario(skill_factor: float) -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("M", 55)
	PuzzleState.level_performance.seconds = 69.5 / skill_factor
	PuzzleState.level_performance.lines = 47
	PuzzleState.level_performance.box_score = 460
	PuzzleState.level_performance.combo_score = 620
	PuzzleState.level_performance.score = 1127
	_refresh_success_condition()


func _prepare_short_ultra_scenario(skill_factor: float) -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("M", 17)
	PuzzleState.level_performance.seconds = 7.5 / skill_factor
	PuzzleState.level_performance.lines = 9
	PuzzleState.level_performance.box_score = 90
	PuzzleState.level_performance.combo_score = 120
	PuzzleState.level_performance.score = 219
	_refresh_success_condition()


func _add_score_result(score: int) -> void:
	var rank_result := RankResult.new()
	rank_result.score = score
	PlayerData.level_history.add_result(CurrentLevel.level_id, rank_result)


func _add_time_result(time: int) -> void:
	var rank_result := RankResult.new()
	rank_result.seconds = time
	PlayerData.level_history.add_result(CurrentLevel.level_id, rank_result)
