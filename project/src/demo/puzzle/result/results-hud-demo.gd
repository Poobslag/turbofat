extends Node
## Demonstrates the end of level results message.
##
## Keys:
## 	[1,2,3]: Show message for a marathon level where the player did bad/ok/good.
## 	[Q,W,E]: Show message for a long ultra level where the player did bad/ok/good.
## 	[R]: Show message for a long ultra level which the player skipped with a cheat code.
## 	[A,S,D]: Show message for a short ultra level where the player did bad/ok/good.
## 	[F]: Show message for a short ultra level which the player skipped with a cheat code.
## 	[H]: Toggle hardcore/normal.
## 	[J]: Toggle passed/failed.
## 	[Space]: Hide message

var _rank_calculator := RankCalculator.new()

onready var _results_hud := $ResultsHud

func _ready() -> void:
	PlayerData.money = 25000
	
	_prepare_marathon_scenario(0.5)
	
	# prepare everything necessary for the 'hardcore reward'
	Breadcrumb.trail = [Global.SCENE_CAREER_MAP]
	CurrentLevel.attempt_count = 0
	CurrentLevel.hardcore = true
	CurrentLevel.best_result = Levels.Result.FINISHED


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
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
		KEY_SPACE:
			_results_hud.hide_results_message()


func _show_results_message() -> void:
	_results_hud.reset()
	_results_hud.show_results_message()


func _prepare_marathon_scenario(skill_factor: float) -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300)
	PuzzleState.level_performance.seconds = 600.0
	PuzzleState.level_performance.lines = 300 * skill_factor
	PuzzleState.level_performance.box_score = 2790 * skill_factor
	PuzzleState.level_performance.combo_score = 4800 * skill_factor
	PuzzleState.level_performance.score = 7890 * skill_factor


func _prepare_long_ultra_scenario(skill_factor: float) -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	PuzzleState.level_performance.seconds = 69.5 / skill_factor
	PuzzleState.level_performance.lines = 47
	PuzzleState.level_performance.box_score = 460
	PuzzleState.level_performance.combo_score = 620
	PuzzleState.level_performance.score = 1127


func _prepare_short_ultra_scenario(skill_factor: float) -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	PuzzleState.level_performance.seconds = 7.5 / skill_factor
	PuzzleState.level_performance.lines = 9
	PuzzleState.level_performance.box_score = 90
	PuzzleState.level_performance.combo_score = 120
	PuzzleState.level_performance.score = 219
