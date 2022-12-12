extends GutTest

var career_rewinder: CareerRewinder

func before_all() -> void:
	career_rewinder = CareerRewinder.new()
	CareerLevelLibrary.regions_path = "res://assets/test/career/career-regions-simple.json"


func before_each() -> void:
	PlayerData.chat_history.reset()


func after_all() -> void:
	career_rewinder.free()
	
	PlayerData.chat_history.reset()
	CareerLevelLibrary.regions_path = CareerLevelLibrary.DEFAULT_REGIONS_PATH


func test_skip_to_region_resets_career_variables() -> void:
	PlayerData.career.hours_passed = 3
	PlayerData.career.distance_travelled = 22
	PlayerData.career.best_distance_travelled = 22
	
	career_rewinder.skip_to_region(1)
	
	assert_eq(PlayerData.career.hours_passed, 0)
	assert_eq(PlayerData.career.distance_travelled, 10)
	assert_eq(PlayerData.career.best_distance_travelled, 10)


func test_skip_to_region_erases_chat_history() -> void:
	var region: CareerRegion = CareerLevelLibrary.regions[1]
	region.cutscene_path = "chat/career/diege"
	
	PlayerData.chat_history.add_history_item("chat/career/diege/a")
	PlayerData.chat_history.add_history_item("chat/career/diege/b")
	PlayerData.chat_history.add_history_item("chat/career/diege_2/a")
	PlayerData.chat_history.add_history_item("chat/career/remis/a")
	
	career_rewinder.skip_to_region(1)
	
	var chat_history_keys := PlayerData.chat_history.chat_history.keys()
	chat_history_keys.sort()
	assert_eq(chat_history_keys, ["chat/career/diege_2/a", "chat/career/remis/a"])
