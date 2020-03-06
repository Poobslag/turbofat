extends Node

class Scenario:
	var _level_up_conditions := []
	var _win_condition: Dictionary
	
	func _init():
		set_start_level(PieceSpeeds.beginner_level_0)
		set_win_condition("none", 0)
	
	func set_start_level(pieceSpeed):
		_level_up_conditions.clear()
		_level_up_conditions.append({"type": "lines", "value": 0, "piece_speed": pieceSpeed})
	
	func add_level_up(type: String, value: int, pieceSpeed):
		_level_up_conditions.append({"type": type, "value": value, "piece_speed": pieceSpeed})
	
	func set_win_condition(type: String, value: int):
		_win_condition = {"type": type, "value": value}

var scenario := Scenario.new()
