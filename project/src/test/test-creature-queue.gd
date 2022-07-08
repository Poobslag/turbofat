extends "res://addons/gut/test.gd"

var creature_queue := CreatureQueue.new()

func before_each() -> void:
	creature_queue.secondary_creatures_path = ""


func test_secondary_queue_has_creatures() -> void:
	assert_eq(creature_queue.secondary_queue.size(), 0)
	creature_queue.secondary_creatures_path = "res://assets/test/secondary-creatures"
	assert_eq(creature_queue.secondary_queue.size(), 2)


func test_has_secondary_creature() -> void:
	assert_eq(false, creature_queue.has_secondary_creature())
	_populate_secondary_queue(["ofa_100"], 0)
	assert_eq(true, creature_queue.has_secondary_creature())


func test_pop_secondary_creature() -> void:
	_populate_secondary_queue(["ofa_100"], 0)
	
	# should only be able to pop one creature; then the queue is empty
	_assert_creature_id(creature_queue.pop_secondary_creature(), "ofa_100")
	_assert_creature_id(creature_queue.pop_secondary_creature(), "")


func test_reset_secondary_creature_queue() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200"], 0)
	_assert_creature_id(creature_queue.pop_secondary_creature(), "ofa_100")
	creature_queue.reset_secondary_creature_queue()
	
	# resetting should add ofa_100 to the end of the queue again
	_assert_creature_id(creature_queue.pop_secondary_creature(), "ofa_200")
	_assert_creature_id(creature_queue.pop_secondary_creature(), "ofa_100")
	_assert_creature_id(creature_queue.pop_secondary_creature(), "")


## Populates the secondary queue with the specified creature ids and secondary index
func test_pop_secondary_creatures_before() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200", "ofa_300"], 2)
	creature_queue.pop_secondary_creatures(["ofa_100"])
	
	_assert_secondary_queue(["ofa_200", "ofa_100", "ofa_300"], 2)


func test_pop_secondary_creatures_current() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200", "ofa_300"], 1)
	creature_queue.pop_secondary_creatures(["ofa_200"])
	
	_assert_secondary_queue(["ofa_100", "ofa_200", "ofa_300"], 2)


func test_pop_secondary_creatures_after() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200", "ofa_300"], 0)
	creature_queue.pop_secondary_creatures(["ofa_300"])
	
	_assert_secondary_queue(["ofa_300", "ofa_100", "ofa_200"], 1)


func test_pop_secondary_creatures_not_found() -> void:
	_populate_secondary_queue(["ofa_100"], 0)
	creature_queue.pop_secondary_creatures(["ofa_invalid"])
	
	_assert_secondary_queue(["ofa_100"], 0)


func test_pop_secondary_creatures_empty() -> void:
	_populate_secondary_queue(["ofa_100"], 0)
	creature_queue.pop_secondary_creatures([])
	
	_assert_secondary_queue(["ofa_100"], 0)


func test_pop_secondary_creatures_multiple() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200", "ofa_300", "ofa_400", "ofa_500"], 2)
	creature_queue.pop_secondary_creatures(["ofa_200", "ofa_400"])
	
	_assert_secondary_queue(["ofa_100", "ofa_200", "ofa_400", "ofa_300", "ofa_500"], 3)


func _populate_secondary_queue(new_creature_ids: Array, new_secondary_index: int) -> void:
	for creature_id in new_creature_ids:
		var creature_def := CreatureDef.new()
		creature_def.creature_id = creature_id
		creature_queue.secondary_queue.append(creature_def)
	creature_queue.secondary_index = new_secondary_index


## Asserts a creature's id.
##
## A null id can be asserted; this assertion is successful if the creature or its id is null.
func _assert_creature_id(creature_def: CreatureDef, expected_id: String) -> void:
	assert_eq("" if not creature_def else creature_def.creature_id, expected_id)


func _assert_secondary_queue(expected_ids: Array, expected_secondary_index: int) -> void:
	var actual_ids := []
	for creature_def in creature_queue.secondary_queue:
		actual_ids.append(creature_def.creature_id)
	assert_eq(actual_ids, expected_ids)
	assert_eq(creature_queue.secondary_index, expected_secondary_index)
