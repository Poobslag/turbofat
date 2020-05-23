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

"""
Populates this object with json data.
"""
func from_string_array(strings: Array) -> void:
	var rules := RuleParser.new(strings)
	if rules.has("veg-row"): veg_points = rules.int_value()
	if rules.has("snack-all"): snack_points = rules.int_value()
	if rules.has("cake-all"): cake_points = rules.int_value()
