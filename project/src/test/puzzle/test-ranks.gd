extends GutTest

func test_next_grade() -> void:
	assert_eq(Ranks.next_grade(Ranks.WORST_GRADE), "B-")
	assert_eq(Ranks.next_grade("B-"), "B")
	assert_eq(Ranks.next_grade("AA+"), "S-")
	assert_eq(Ranks.next_grade("SSS"), "M")
	assert_eq(Ranks.next_grade("M"), "M")
	assert_eq(Ranks.next_grade("crazy-giants"), Ranks.WORST_GRADE)


func test_min_frames_per_line() -> void:
	assert_almost_eq(Ranks.min_frames_per_line(PieceSpeeds.speed("0")), 117.0, 0.001)
	assert_almost_eq(Ranks.min_frames_per_line(PieceSpeeds.speed("9")), 117.0, 0.001)
	assert_almost_eq(Ranks.min_frames_per_line(PieceSpeeds.speed("AA")), 101.0, 0.001)
	assert_almost_eq(Ranks.min_frames_per_line(PieceSpeeds.speed("FF")), 37.25, 0.001)


func test_round_score_down() -> void:
	# negative numbers are nonsensical, we don't worry about rounding them
	assert_eq(Ranks.round_score_down(-397), -397)
	
	# numbers 0-20 are not rounded
	assert_eq(Ranks.round_score_down(0), 0)
	assert_eq(Ranks.round_score_down(2), 2)
	assert_eq(Ranks.round_score_down(19), 19)
	assert_eq(Ranks.round_score_down(20), 20)
	
	# numbers 21-99 are rounded down to the nearest 5
	assert_eq(Ranks.round_score_down(21), 20)
	assert_eq(Ranks.round_score_down(44), 40)
	assert_eq(Ranks.round_score_down(87), 85)
	assert_eq(Ranks.round_score_down(99), 95)
	
	# numbers over 100 are rounded down to the nearest two significant digits, plus a 5
	assert_eq(Ranks.round_score_down(100), 100)
	assert_eq(Ranks.round_score_down(106), 105)
	assert_eq(Ranks.round_score_down(397), 395)
	assert_eq(Ranks.round_score_down(999), 995)
	assert_eq(Ranks.round_score_down(1006), 1000)
	assert_eq(Ranks.round_score_down(4427), 4400)
	assert_eq(Ranks.round_score_down(63021), 63000)
	assert_eq(Ranks.round_score_down(25133386), 25000000)


func test_round_time_up() -> void:
	# negative numbers are nonsensical, we don't worry about rounding them
	assert_eq(Ranks.round_time_up(-397), -397)
	
	# numbers 0-60 are not rounded
	assert_eq(Ranks.round_time_up(0), 0)
	assert_eq(Ranks.round_time_up(2), 2)
	assert_eq(Ranks.round_time_up(14), 14)
	assert_eq(Ranks.round_time_up(44), 44)
	assert_eq(Ranks.round_time_up(60), 60)
	
	# numbers 61-300 are rounded up to the nearest 5
	assert_eq(Ranks.round_time_up(61), 65)
	assert_eq(Ranks.round_time_up(239), 240)
	assert_eq(Ranks.round_time_up(294), 295)
	assert_eq(Ranks.round_time_up(300), 300)
	
	# numbers 300-1199 are rounded up to the nearest 10
	assert_eq(Ranks.round_time_up(301), 310)
	assert_eq(Ranks.round_time_up(895), 900)
	assert_eq(Ranks.round_time_up(1191), 1200)
	assert_eq(Ranks.round_time_up(1200), 1200)
	
	# numbers over 1200 are rounded up to the nearest 60
	assert_eq(Ranks.round_time_up(1201), 1260)
	assert_eq(Ranks.round_time_up(93546), 93600)
	assert_eq(Ranks.round_time_up(25133386), 25133400)


func test_grade() -> void:
	assert_eq("M", Ranks.grade(0.0))
	assert_eq("SS", Ranks.grade(9.9))
	assert_eq("SS", Ranks.grade(10.0))
	assert_eq("S+", Ranks.grade(10.1))
	assert_eq("-", Ranks.grade(999999.0))


func test_rank_meets_grade() -> void:
	assert_eq(Ranks.rank_meets_grade(0.0, "S"), true)
	assert_eq(Ranks.rank_meets_grade(15.0, "S"), true)
	assert_eq(Ranks.rank_meets_grade(20.0, "S"), true)
	assert_eq(Ranks.rank_meets_grade(25.0, "S"), false)
	assert_eq(Ranks.rank_meets_grade(999.0, "S"), false)
	
	assert_eq(Ranks.rank_meets_grade(0.0, "M"), true)
	assert_eq(Ranks.rank_meets_grade(999.0, "M"), false)
	
	assert_eq(Ranks.rank_meets_grade(0.0, "-"), true)
	assert_eq(Ranks.rank_meets_grade(999.0, "-"), true)


func test_required_rank_for_grade() -> void:
	assert_eq(Ranks.required_rank_for_grade(Ranks.WORST_GRADE), Ranks.WORST_RANK)
	assert_eq(Ranks.required_rank_for_grade("B-"), 64.0)
	assert_eq(Ranks.required_rank_for_grade("AA+"), 32.0)
	assert_eq(Ranks.required_rank_for_grade("SSS"), 4.0)
	assert_eq(Ranks.required_rank_for_grade("M"), 0.0)
	assert_eq(Ranks.required_rank_for_grade("crazy-giants"), Ranks.WORST_RANK)
