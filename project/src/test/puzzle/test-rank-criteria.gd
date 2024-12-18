extends GutTest

var criteria: RankCriteria

func before_each() -> void:
	criteria = RankCriteria.new()


func test_soften_marathon() -> void:
	criteria.duration_criteria = false
	criteria.add_threshold("TOP", 10000)
	
	assert_eq(2050, threshold_for_grade("S-"))
	
	criteria.soften("S-", 0.8)
	assert_eq(1600, criteria.thresholds_by_grade.get("S-"))


func test_soften_ultra() -> void:
	criteria.duration_criteria = true
	criteria.add_threshold("TOP", 17)
	
	assert_eq(90, threshold_for_grade("S-"))
	
	criteria.soften("S-", 0.8)
	assert_eq(110, criteria.thresholds_by_grade.get("S-"))


func test_nerf_m_rank() -> void:
	criteria.add_threshold("TOP", 10000)
	assert_eq(9500, threshold_for_grade("M"))
	assert_eq(8100, threshold_for_grade("SSS"))


func test_nerf_m_rank_ultra() -> void:
	criteria.duration_criteria = true
	criteria.add_threshold("TOP", 60)
	assert_eq(65, threshold_for_grade("M"))
	assert_eq(80, threshold_for_grade("SSS"))


func threshold_for_grade(grade: String) -> int:
	var other_criteria := RankCriteria.new()
	other_criteria.copy_from(criteria)
	other_criteria.fill_missing_thresholds()
	return other_criteria.thresholds_by_grade.get(grade)
