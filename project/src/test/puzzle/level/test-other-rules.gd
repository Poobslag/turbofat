extends GutTest

var rules: OtherRules

func before_each() -> void:
	rules = OtherRules.new()


func test_is_default() -> void:
	assert_eq(rules.is_default(), true)
	rules.after_tutorial = true
	assert_eq(rules.is_default(), false)


func test_convert_to_json_and_back() -> void:
	rules.after_tutorial = true
	rules.clear_on_finish = false
	rules.enhance_combo_fx = true
	rules.food_speed = 2.0
	rules.non_interactive = true
	rules.suppress_piece_rotation = OtherRules.SuppressPieceRotation.ROTATION
	rules.suppress_piece_initial_rotation = OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS
	rules.skip_intro = true
	rules.start_level = "advanced/level_614"
	rules.tile_set = PuzzleTileMap.TileSetType.VEGGIE
	rules.tutorial = true
	_convert_to_json_and_back()
	
	assert_eq(rules.after_tutorial, true)
	assert_eq(rules.clear_on_finish, false)
	assert_eq(rules.enhance_combo_fx, true)
	assert_eq(rules.food_speed, 2.0)
	assert_eq(rules.non_interactive, true)
	assert_eq(rules.suppress_piece_rotation, OtherRules.SuppressPieceRotation.ROTATION)
	assert_eq(rules.suppress_piece_initial_rotation, OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS)
	assert_eq(rules.skip_intro, true)
	assert_eq(rules.start_level, "advanced/level_614")
	assert_eq(rules.tile_set, PuzzleTileMap.TileSetType.VEGGIE)
	assert_eq(rules.tutorial, true)


func test_from_json_array_suppress_piece_rotation() -> void:
	rules.from_json_array(["suppress_piece_rotation", "suppress_piece_initial_rotation"])
	assert_eq(rules.suppress_piece_rotation, OtherRules.SuppressPieceRotation.ROTATION)
	assert_eq(rules.suppress_piece_initial_rotation, OtherRules.SuppressPieceRotation.ROTATION)


func test_to_json_array_suppress_piece_rotation() -> void:
	rules.suppress_piece_rotation = OtherRules.SuppressPieceRotation.ROTATION
	rules.suppress_piece_initial_rotation = OtherRules.SuppressPieceRotation.ROTATION
	assert_eq(rules.to_json_array(), ["suppress_piece_rotation", "suppress_piece_initial_rotation"])


func test_from_json_array_clear_on_finish() -> void:
	rules.from_json_array(["no_clear_on_finish"])
	assert_eq(rules.clear_on_finish, false)
	
	rules = OtherRules.new()
	rules.from_json_array(["clear_on_finish false"])
	assert_eq(rules.clear_on_finish, false)
	
	rules = OtherRules.new()
	rules.from_json_array(["clear_on_finish true"])
	assert_eq(rules.clear_on_finish, true)
	
	rules = OtherRules.new()
	rules.from_json_array(["no_clear_on_finish false"])
	assert_eq(rules.clear_on_finish, true)


func test_to_json_array_clear_on_finish() -> void:
	rules.clear_on_finish = false
	assert_eq(rules.to_json_array(), ["no_clear_on_finish"])
	
	rules.clear_on_finish = true
	assert_eq(rules.to_json_array(), [])


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = OtherRules.new()
	rules.from_json_array(json)
