extends "res://addons/gut/test.gd"

func after_each() -> void:
	CareerLevelLibrary.worlds_path = LevelLibrary.DEFAULT_WORLDS_PATH


func test_regions() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds.json"
	
	assert_eq(7, CareerLevelLibrary.regions.size())
	
	var region_1: CareerRegion = CareerLevelLibrary.regions[1]
	assert_eq(region_1.name, "Poki Desert")
	assert_eq(region_1.distance, 10)
	assert_eq(region_1.min_piece_speed, "0")
	assert_eq(region_1.max_piece_speed, "3")
	assert_eq(region_1.length, 15)
	assert_eq(region_1.levels.size(), 11)


## increasing the weight selects faster speeds
func test_piece_speed_between_weight() -> void:
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.0, 0.5), "0")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.5, 0.5), "2")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 1.0, 0.5), "4")


## adjusting the random parameter selects different speeds
func test_piece_speed_between_r() -> void:
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "3", 0.5, 0.0), "1")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "3", 0.5, 0.4), "1")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "3", 0.5, 0.6), "2")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "3", 0.5, 1.0), "2")


## at the edges, adjusting the random parameter still has an effect, however slight
func test_piece_speed_between_r_edges() -> void:
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.0, 0.0), "0")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.0, 0.9), "0")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.0, 1.0), "1")
	
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 1.0, 0.0), "3")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 1.0, 0.1), "4")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 1.0, 1.0), "4")


## when min==max, weight and r have no effect
func test_piece_speed_between_narrow() -> void:
	assert_eq(CareerLevelLibrary.piece_speed_between("4", "4", 0.0, 0.0), "4")
	assert_eq(CareerLevelLibrary.piece_speed_between("4", "4", 1.0, 1.0), "4")


func test_region_for_distance() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds.json"
	
	assert_eq(CareerLevelLibrary.region_for_distance(0).name, "Lemony Thickets")
	assert_eq(CareerLevelLibrary.region_for_distance(9).name, "Lemony Thickets")
	assert_eq(CareerLevelLibrary.region_for_distance(10).name, "Poki Desert")
	assert_eq(CareerLevelLibrary.region_for_distance(33).name, "Merrymellow Marsh")
	assert_eq(CareerLevelLibrary.region_for_distance(CareerData.MAX_DISTANCE_TRAVELLED).name, "Starberry Mountain")


func test_region_weight_for_distance() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds.json"
	
	assert_eq(CareerLevelLibrary.region_weight_for_distance(
		CareerLevelLibrary.region_for_distance(10), 10), 0.0)
	assert_eq(CareerLevelLibrary.region_weight_for_distance(
		CareerLevelLibrary.region_for_distance(17), 17), 0.5)
	assert_eq(CareerLevelLibrary.region_weight_for_distance(
		CareerLevelLibrary.region_for_distance(24), 24), 1.0)
