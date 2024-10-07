extends GutTest

func test_achievements_dont_crash() -> void:
	# There should be a bunch of achievements. If there's fewer than five, something is wrong
	assert_true(SteamAchievements.get_achievements().size() >= 5)
	
	for achievement in SteamAchievements.get_achievements():
		achievement.refresh_achievement()
