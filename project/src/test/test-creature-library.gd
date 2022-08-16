extends "res://addons/gut/test.gd"

func before_each() -> void:
	PlayerData.creature_library.reset()


func after_all() -> void:
	PlayerData.creature_library.reset()


func test_substitute_variables_names() -> void:
	PlayerData.creature_library.player_def.creature_name = "Gegad Hi"
	PlayerData.creature_library.player_def.creature_short_name = "Gegad"
	
	PlayerData.creature_library.sensei_def.creature_name = "Eper Tiv"
	PlayerData.creature_library.sensei_def.creature_short_name = "Eper"
	
	var result := PlayerData.creature_library.substitute_variables(
			"Let's meet #player# and their sensei #sensei#.")
	assert_eq(result, "Let's meet Gegad and their sensei Eper.")


func test_substitute_variables_phrases() -> void:
	PlayerData.chat_history.set_phrase("favorite_animal_plural", "classy rabbits")
	
	var result := PlayerData.creature_library.substitute_variables(
			"I sure love #favorite_animal_plural#.")
	assert_eq(result, "I sure love classy rabbits.")
