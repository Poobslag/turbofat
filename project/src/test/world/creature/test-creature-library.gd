extends GutTest

func before_each() -> void:
	PlayerData.career.reset()
	PlayerData.creature_library.reset()


func after_all() -> void:
	PlayerData.career.reset()
	PlayerData.creature_library.reset()


func test_substitute_variables_names() -> void:
	# Avoid triggering the 'sensei is hard-coded to Turbo' logic
	PlayerData.career.best_distance_travelled = 100
	
	PlayerData.creature_library.player_def.creature_name = "Gegad Hi"
	PlayerData.creature_library.player_def.creature_short_name = "Gegad"
	
	PlayerData.creature_library.sensei_def.creature_name = "Eper Tiv"
	PlayerData.creature_library.sensei_def.creature_short_name = "Eper"
	
	var result := PlayerData.creature_library.substitute_variables(
			"Let's meet #player# and their sensei #sensei#.")
	assert_eq(result, "Let's meet Gegad and their sensei Eper.")


func test_substitute_variables_phrases() -> void:
	PlayerData.chat_history.set_phrase("silly_name", "Gomot Ocedut")
	
	var result := PlayerData.creature_library.substitute_variables(
			"Please call me #silly_name#.")
	assert_eq(result, "Please call me Gomot Ocedut.")


func test_substitute_possessive() -> void:
	PlayerData.creature_library.player_def.creature_short_name = "Gegad"
	
	var result := PlayerData.creature_library.substitute_variables(
			"This is all #player.possessive# fault.")
	assert_eq(result, "This is all Gegad's fault.")
