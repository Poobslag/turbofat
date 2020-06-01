extends Control
"""
Demonstrates the end of level results message.

Keys:
	[S]: Show message
	[H]: Hide message
"""

var _rank_result: RankResult = RankResult.new()
var _creature_scores := [
	40, 82, 226, 49, 10, 50, 36, 490, 651, 43, 942, 305, 231, 172, 223, 44, 34, 184, 37, 653, 283, 376, 1, 8, 687, 19,
	89, 853, 986, 713, 294, 468, 207, 63, 59, 570, 98, 341, 461, 39, 56, 51, 6, 3, 16, 94, 72, 739, 459, 552, 968,
	648, 688, 594, 9, 23, 669, 784, 496, 2, 258, 79, 679, 377, 41, 53, 522, 636, 77, 706, 981, 86, 438, 151, 74, 665,
	754, 378, 937, 419, 840, 62, 289, 584, 640, 20, 28, 652, 25, 708, 12, 11, 727, 52, 466, 60, 306, 48, 45, 339]
var _finish_condition_type := Milestone.SCORE

func _ready() -> void:
	_rank_result.seconds = 600.0
	_rank_result.lines = 300
	_rank_result.box_score_per_line = 9.3
	_rank_result.combo_score_per_line = 17.0
	_rank_result.score = 7890


func _input(event: InputEvent) -> void:
	match(Global.key_scancode(event)):
		KEY_S: $ResultsHud.show_results_message(_rank_result, _creature_scores, _finish_condition_type)
		KEY_H: $ResultsHud.hide_results_message()
