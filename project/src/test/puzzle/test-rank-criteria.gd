extends GutTest

var criteria: RankCriteria

func before_each() -> void:
	criteria = RankCriteria.new()


func test_soften_marathon() -> void:
	criteria.duration_criteria = false
	criteria.add_threshold("TOP", 10000)
	
	assert_eq(2150, threshold_for_grade("S-"))
	
	criteria.soften("S-", 0.8)
	assert_eq(1700, criteria.thresholds_by_grade.get("S-"))


func test_soften_ultra() -> void:
	criteria.duration_criteria = true
	criteria.add_threshold("TOP", 17)
	
	assert_eq(80, threshold_for_grade("S-"))
	
	criteria.soften("S-", 0.8)
	assert_eq(100, criteria.thresholds_by_grade.get("S-"))


func threshold_for_grade(grade: String) -> int:
	var other_criteria := RankCriteria.new()
	other_criteria.copy_from(criteria)
	other_criteria.fill_missing_thresholds()
	return other_criteria.thresholds_by_grade.get(grade)
