extends GutTest

func before_each() -> void:
	CurrentLevel.reset()


func test_has_customer_empty() -> void:
	assert_eq(CurrentLevel.has_customer("destroy_stupid"), false)
	assert_eq(CurrentLevel.has_customer(_creature_def("destroy_stupid", "Destroy Stupid")), false)


func test_has_customer_string() -> void:
	CurrentLevel.customers.push_back("jump_escape")
	
	assert_eq(CurrentLevel.has_customer("jump_escape"), true)
	assert_eq(CurrentLevel.has_customer("destroy_stupid"), false)
	assert_eq(CurrentLevel.has_customer(_creature_def("jump_escape", "Jump Escape")), true)
	assert_eq(CurrentLevel.has_customer(_creature_def("destroy_stupid", "Destroy Stupid")), false)


func test_has_customer_creature_def_with_id() -> void:
	CurrentLevel.customers.push_back(_creature_def("jump_escape", "Jump Escape"))
	
	assert_eq(CurrentLevel.has_customer("jump_escape"), true)
	assert_eq(CurrentLevel.has_customer("destroy_stupid"), false)
	assert_eq(CurrentLevel.has_customer(_creature_def("jump_escape", "Serve Confuse")), true)
	assert_eq(CurrentLevel.has_customer(_creature_def("serve_confuse", "Jump Escape")), false)
	assert_eq(CurrentLevel.has_customer(_creature_def("destroy_stupid", "Destroy Stupid")), false)


func test_has_customer_creature_def_without_id() -> void:
	CurrentLevel.customers.push_back(_creature_def("", "Jump Escape"))
	
	assert_eq(CurrentLevel.has_customer("destroy_stupid"), false)
	assert_eq(CurrentLevel.has_customer(_creature_def("", "Jump Escape")), true)
	assert_eq(CurrentLevel.has_customer(_creature_def("", "Destroy Stupid")), false)
	assert_eq(CurrentLevel.has_customer(_creature_def("destroy_stupid", "Destroy Stupid")), false)


func _creature_def(creature_id: String = "", creature_name: String = "") -> CreatureDef:
	var result := CreatureDef.new()
	result.creature_id = creature_id
	result.creature_name = creature_name
	return result
