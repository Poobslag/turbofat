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
	
	chat_tree.creature_ids.append(CreatureLibrary.PLAYER_ID)
	assert_eq(chat_tree.has_sensei(), false)
	
	chat_tree.creature_ids.append(CreatureLibrary.SENSEI_ID)
	assert_eq(chat_tree.has_sensei(), true)
