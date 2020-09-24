class_name ScoreRules
"""
Rules for scoring points.
"""

# box points awarded for clearing a row with no boxes, a vegetable row.
var veg_points := 0

# box points for clearing a row of a snack box.
var snack_points := 5

# box points for clearing a row of a cake box.
var cake_points := 10

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("veg_row"): veg_points = rules.int_value()
	if rules.has("snack_all"): snack_points = rules.int_value()
	if rules.has("cake_all"): cake_points = rules.int_value()
