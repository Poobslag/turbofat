extends GutTest

var clearer: LineClearer

func before_each() -> void:
	CurrentLevel.settings = LevelSettings.new()
	clearer = autofree(LineClearer.new())


func test_filled_line_clear_delay() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_delay = 0
	
	assert_eq(clearer.calculate_lines_to_clear([5]), [5])


func test_filled_line_clear_delay_2() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_delay = 2
	
	assert_eq(clearer.calculate_lines_to_clear([5]), [])
	assert_eq(clearer.calculate_lines_to_clear([1, 5]), [])
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [5])
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [1, 5])
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [1, 2, 5])


func test_filled_line_clear_max_0() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_max = 0
	
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [1, 2, 5])
	assert_eq(clearer.calculate_lines_to_clear([1]), [1])
	assert_eq(clearer.calculate_lines_to_clear([]), [])


func test_filled_line_clear_max_1() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_max = 1
	
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [1])
	assert_eq(clearer.calculate_lines_to_clear([1]), [1])
	assert_eq(clearer.calculate_lines_to_clear([]), [])


func test_filled_line_clear_max_2() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_max = 2
	
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [1, 2])
	assert_eq(clearer.calculate_lines_to_clear([1]), [1])
	assert_eq(clearer.calculate_lines_to_clear([]), [])


func test_filled_line_clear_min_2() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_min = 2
	
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [1, 2, 5])
	assert_eq(clearer.calculate_lines_to_clear([1, 2]), [1, 2])
	assert_eq(clearer.calculate_lines_to_clear([1]), [])
	assert_eq(clearer.calculate_lines_to_clear([]), [])


func test_filled_line_clear_min_0() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_min = 0
	
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [1, 2, 5])
	assert_eq(clearer.calculate_lines_to_clear([1]), [1])
	assert_eq(clearer.calculate_lines_to_clear([]), [])


func test_filled_line_clear_order() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_order = BlocksDuringRules.FilledLineClearOrder.HIGHEST
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [1, 2, 5])
	
	CurrentLevel.settings.blocks_during.filled_line_clear_order = BlocksDuringRules.FilledLineClearOrder.LOWEST
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [5, 2, 1])


func test_filled_line_clear_order_oldest() -> void:
	CurrentLevel.settings.blocks_during.filled_line_clear_max = 1
	CurrentLevel.settings.blocks_during.filled_line_clear_min = 3
	CurrentLevel.settings.blocks_during.filled_line_clear_order = BlocksDuringRules.FilledLineClearOrder.OLDEST
	
	assert_eq(clearer.calculate_lines_to_clear([5]), [])
	assert_eq(clearer.calculate_lines_to_clear([1, 5]), [])
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 5]), [5])
	assert_eq(clearer.calculate_lines_to_clear([1, 2, 6]), [1])
	assert_eq(clearer.calculate_lines_to_clear([2, 6, 7]), [2])
