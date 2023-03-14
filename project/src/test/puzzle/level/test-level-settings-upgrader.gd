extends GutTest

func test_increment_string() -> void:
	assert_eq(LevelSettingsUpgrader.increment_string(""), "")
	assert_eq(LevelSettingsUpgrader.increment_string("3"), "4")
	assert_eq(LevelSettingsUpgrader.increment_string("a3b"), "a4b")
	assert_eq(LevelSettingsUpgrader.increment_string("9,99,999"), "10,100,1000")
