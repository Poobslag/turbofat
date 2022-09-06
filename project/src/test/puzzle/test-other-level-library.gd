extends "res://addons/gut/test.gd"

func after_each() -> void:
	OtherLevelLibrary.other_regions_path = OtherLevelLibrary.DEFAULT_OTHER_REGIONS_PATH


func test_regions() -> void:
	OtherLevelLibrary.other_regions_path = "res://assets/test/puzzle/other-regions-simple.json"
	assert_eq(OtherLevelLibrary.regions.size(), 2)
	
	var region_0: OtherRegion = OtherLevelLibrary.regions[0]
	assert_eq(region_0.id, "toot")
	assert_eq(region_0.name, "Toot Tow")
	assert_eq(region_0.description, "Toot tow description")
	assert_eq(region_0.level_ids, ["tutorial/basics_0", "tutorial/squish_0"])


func test_all_level_ids() -> void:
	OtherLevelLibrary.other_regions_path = "res://assets/test/puzzle/other-regions-simple.json"
	
	assert_eq(OtherLevelLibrary.all_level_ids(),
			["tutorial/basics_0", "tutorial/squish_0", "practice/marathon-normal", "practice/marathon-hard"])
