extends GutTest

var rules: RankRules

func before_each() -> void:
	rules = RankRules.new()


func test_is_default() -> void:
	assert_eq(rules.is_default(), true)
	rules.box_factor = 2.0
	assert_eq(rules.is_default(), false)


func test_to_json_empty() -> void:
	assert_eq(rules.to_json_array(), [])


func test_convert_to_json_and_back() -> void:
	rules.box_factor = 2.3
	rules.combo_factor = 3.4
	rules.customer_combo = 4
	rules.extra_seconds_per_piece = 5.6
	rules.leftover_lines = 6
	rules.master_pickup_score = 7.8
	rules.master_pickup_score_per_line = 8.9
	rules.show_boxes_rank = RankRules.ShowRank.SHOW
	rules.show_combos_rank = RankRules.ShowRank.HIDE
	rules.show_lines_rank = RankRules.ShowRank.SHOW
	rules.show_pickups_rank = RankRules.ShowRank.HIDE
	rules.show_pieces_rank = RankRules.ShowRank.SHOW
	rules.show_speed_rank = RankRules.ShowRank.HIDE
	rules.skip_results = true
	rules.success_bonus = 9.0
	rules.unranked = true
	_convert_to_json_and_back()
	
	assert_eq(rules.box_factor, 2.3)
	assert_eq(rules.combo_factor, 3.4)
	assert_eq(rules.customer_combo, 4)
	assert_eq(rules.extra_seconds_per_piece, 5.6)
	assert_eq(rules.leftover_lines, 6)
	assert_eq(rules.master_pickup_score, 7.8)
	assert_eq(rules.master_pickup_score_per_line, 8.9)
	assert_eq(rules.show_boxes_rank, RankRules.ShowRank.SHOW)
	assert_eq(rules.show_combos_rank, RankRules.ShowRank.HIDE)
	assert_eq(rules.show_lines_rank, RankRules.ShowRank.SHOW)
	assert_eq(rules.show_pickups_rank, RankRules.ShowRank.HIDE)
	assert_eq(rules.show_pieces_rank, RankRules.ShowRank.SHOW)
	assert_eq(rules.show_speed_rank, RankRules.ShowRank.HIDE)
	assert_eq(rules.skip_results, true)
	assert_eq(rules.success_bonus, 9.0)
	assert_eq(rules.unranked, true)


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = RankRules.new()
	rules.from_json_array(json)
