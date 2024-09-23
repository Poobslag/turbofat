extends GutTest

var rules: RankRules

func before_each() -> void:
	rules = RankRules.new()


func test_is_default() -> void:
	assert_eq(rules.is_default(), true)
	rules.success_bonus = 9.0
	assert_eq(rules.is_default(), false)


func test_to_json_empty() -> void:
	assert_eq(rules.to_json_array(), [])


func test_convert_to_json_and_back() -> void:
	rules.rank_criteria.add_threshold("M", 1000)
	rules.rank_criteria.add_threshold("S-", 500)
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
	
	assert_eq(2, rules.rank_criteria.thresholds_by_grade.size())
	assert_eq(1000, rules.rank_criteria.thresholds_by_grade.get("M"))
	assert_eq(500, rules.rank_criteria.thresholds_by_grade.get("S-"))
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
