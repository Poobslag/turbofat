class_name ScoreRules
"""
Rules for scoring points.
"""

const DEFAULT_CAKE_POINTS := 10
const DEFAULT_SNACK_POINTS := 5

# box points for clearing a row of a cake box.
var cake_points := DEFAULT_CAKE_POINTS

# box points for clearing a row of a snack box.
var snack_points := DEFAULT_SNACK_POINTS

# box points for collecting a cake pickup.
var cake_pickup_points := 20

# box points for collecting a snack pickup.
var snack_pickup_points := 10

# box points awarded for clearing a row with no boxes, a vegetable row.
var veg_points := 0

func from_json_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("cake_all"): cake_points = rules.int_value()
	if rules.has("snack_all"): snack_points = rules.int_value()
	if rules.has("veg_row"): veg_points = rules.int_value()
