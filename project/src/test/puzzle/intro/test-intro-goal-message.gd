extends GutTest

var original_locale: String
var message: IntroGoalMessage

func before_all() -> void:
	original_locale = TranslationServer.get_locale()
	TranslationServer.set_locale("en")


func before_each() -> void:
	message = IntroGoalMessage.new()
	add_child_autofree(message)
	
	PlayerData.level_history.reset()
	CurrentLevel.reset()
	CurrentLevel.level_id = "tricky_yellow_oval"


func after_all() -> void:
	TranslationServer.set_locale(original_locale)


func add_score_result(score: int) -> void:
	var rank_result := RankResult.new()
	rank_result.score = score
	PlayerData.level_history.add_result(CurrentLevel.level_id, rank_result)


func add_time_result(time: int) -> void:
	var rank_result := RankResult.new()
	rank_result.seconds = time
	PlayerData.level_history.add_result(CurrentLevel.level_id, rank_result)


func test_ultra_unplayed() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 60)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,000 in 12:00 for rank A!")


func test_ultra_unsuccessful() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	CurrentLevel.settings.set_success_condition(Milestone.TIME_UNDER, 180)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 60)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,000 in 3:00 for a passing grade!")


func test_ultra_rank_a() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 60)
	add_time_result(640)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,000 in 5:10 for rank S!")


func test_ultra_rank_s() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 60)
	add_time_result(310)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,000 in 1:40 for rank SS!")


func test_ultra_rank_Ss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 60)
	add_time_result(100)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,000 in 1:20 for rank SSS!")


func test_ultra_rank_Sss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 60)
	add_time_result(80)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,000 in 1:19 to beat your record!")


func test_sprint_unplayed() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥175 in 2:00 for rank A!")


func test_sprint_unsuccessful() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	CurrentLevel.settings.set_success_condition(Milestone.SCORE, 600)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥600 in 2:00 for a passing grade!")


func test_sprint_rank_a() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(175)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥410 in 2:00 for rank S!")


func test_sprint_rank_s() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(500)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,300 in 2:00 for rank SS!")


func test_sprint_rank_ss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(1400)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,600 in 2:00 for rank SSS!")


func test_sprint_rank_sss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(1850)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,851 in 2:00 to beat your record!")


func test_line_marathon_unplayed() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 50)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥175 with 50 lines for rank A!")


func test_line_marathon_unsuccessful() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 50)
	CurrentLevel.settings.set_success_condition(Milestone.SCORE, 100)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥100 with 50 lines for a passing grade!")


func test_line_marathon_rank_a() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 50)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(175)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥410 with 50 lines for rank S!")


func test_line_marathon_rank_s() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 50)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(500)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,300 with 50 lines for rank SS!")


func test_line_marathon_rank_ss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 50)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(1500)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,600 with 50 lines for rank SSS!")


func test_line_marathon_rank_sss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 50)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(2000)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥2,001 with 50 lines to beat your record!")


func test_piece_marathon_unplayed() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 100)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥175 with 100 pieces for rank A!")


func test_piece_marathon_unsuccessful() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 100)
	CurrentLevel.settings.set_success_condition(Milestone.SCORE, 100)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥100 with 100 pieces for a passing grade!")


func test_piece_marathon_rank_a() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 100)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(175)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥410 with 100 pieces for rank S!")


func test_piece_marathon_rank_s() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 100)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(500)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,300 with 100 pieces for rank SS!")


func test_piece_marathon_rank_ss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 100)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(1500)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,600 with 100 pieces for rank SSS!")


func test_piece_marathon_rank_sss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 100)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 2000)
	add_score_result(2000)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥2,001 with 100 pieces to beat your record!")


func test_vip_1_unplayed() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 1)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 600)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥50 from one customer for rank A!")


func test_vip_1_unsuccessful() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 1)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 600)
	CurrentLevel.settings.set_success_condition(Milestone.SCORE, 50)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥50 from one customer for a passing grade!")


func test_vip_1_rank_a() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 1)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 600)
	add_score_result(50)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥120 from one customer for rank S!")


func test_vip_1_rank_s() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 1)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 600)
	add_score_result(150)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥390 from one customer for rank SS!")


func test_vip_1_rank_ss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 1)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 600)
	add_score_result(450)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥485 from one customer for rank SSS!")


func test_vip_1_rank_sss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 1)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 600)
	add_score_result(550)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥551 from one customer to beat your record!")


func test_vip_3_unplayed() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 3)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1800)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥155 from three customers for rank A!")


func test_vip_3_unsuccessful() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 3)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1800)
	CurrentLevel.settings.set_success_condition(Milestone.SCORE, 100)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥100 from three customers for a passing grade!")


func test_vip_3_rank_a() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 3)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1800)
	add_score_result(155)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥370 from three customers for rank S!")


func test_vip_3_rank_s() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 3)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1800)
	add_score_result(400)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,150 from three customers for rank SS!")


func test_vip_3_rank_ss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 3)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1800)
	add_score_result(1300)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,450 from three customers for rank SSS!")


func test_vip_3_rank_sss() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 3)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1800)
	add_score_result(1650)
	
	message.refresh()
	assert_eq(message.text, "Earn ¥1,651 from three customers to beat your record!")


func test_sandbox() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.NONE, 0)
	add_score_result(1500)
	
	message.refresh()
	assert_eq(message.text, "There is no goal in this mode. Just have fun!")
