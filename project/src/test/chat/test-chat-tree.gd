extends GutTest

var chat_tree := ChatTree.new()

func test_inside_restaurant() -> void:
	assert_eq(chat_tree.inside_restaurant(), false)
	
	chat_tree.location_id = "marsh"
	assert_eq(chat_tree.inside_restaurant(), false)
	
	chat_tree.location_id = "inside_turbo_fat"
	assert_eq(chat_tree.inside_restaurant(), true)


func test_has_sensei() -> void:
	assert_eq(chat_tree.has_sensei(), false)
	
	chat_tree.spawn_locations[CreatureLibrary.PLAYER_ID] = "kitchen_7"
	assert_eq(chat_tree.has_sensei(), false)
	
	chat_tree.spawn_locations[CreatureLibrary.SENSEI_ID] = "kitchen_5"
	assert_eq(chat_tree.has_sensei(), true)
