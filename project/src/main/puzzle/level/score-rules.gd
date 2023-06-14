class_name ScoreRules
## Rules for scoring points.

## Parses a json string like 'cake_all 15' into an int.
##
## This is distinct from IntPropertyParser because json values like 'cake_all' are not directly stored into a
## 'cake_all' property, there is some translation logic.
class PointsPropertyParser extends RuleParser.PropertyParser:
	var _all_string: String
	
	func _init(init_target: Object, init_name: String) -> void:
		super(init_target, init_name)
		default = 0
		_all_string = "%sall" % [init_name.trim_suffix("points")]
		keys = [_all_string]
	
	
	func to_json_strings() -> Array:
		return ["%s %s" % [_all_string, target().get(name)]]
	
	
	func from_json_string(json: String) -> void:
		target().set(name, int(json.split(" ")[1]))


const DEFAULT_CAKE_POINTS := 10
const DEFAULT_SNACK_POINTS := 5

## box points for clearing a row of a cake box.
var cake_points := DEFAULT_CAKE_POINTS

## box points for clearing a row of a snack box.
var snack_points := DEFAULT_SNACK_POINTS

## box points for collecting a cake pickup.
var cake_pickup_points := 20

## box points for collecting a snack pickup.
var snack_pickup_points := 10

## box points awarded for clearing a row with no boxes, a vegetable row.
var veg_points := 0

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add(PointsPropertyParser.new(self, "cake_points")).default(DEFAULT_CAKE_POINTS)
	_rule_parser.add(PointsPropertyParser.new(self, "snack_points")).default(DEFAULT_SNACK_POINTS)
	_rule_parser.add(PointsPropertyParser.new(self, "cake_pickup_points")).default(cake_pickup_points)
	_rule_parser.add(PointsPropertyParser.new(self, "snack_pickup_points")).default(snack_pickup_points)
	_rule_parser.add_int("veg_points")


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
