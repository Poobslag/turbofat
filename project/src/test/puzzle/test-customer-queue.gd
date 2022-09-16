extends "res://addons/gut/test.gd"

var customer_queue := CustomerQueue.new()

func before_each() -> void:
	customer_queue.secondary_customers_path = ""


func test_secondary_queue_has_creatures() -> void:
	assert_eq(customer_queue.secondary_queue.size(), 0)
	customer_queue.secondary_customers_path = "res://assets/test/secondary-creatures"
	assert_eq(customer_queue.secondary_queue.size(), 2)


func test_has_secondary_customer() -> void:
	assert_eq(false, customer_queue.has_secondary_customer())
	_populate_secondary_queue(["ofa_100"], 0)
	assert_eq(true, customer_queue.has_secondary_customer())


func test_pop_secondary_customer() -> void:
	_populate_secondary_queue(["ofa_100"], 0)
	
	# should only be able to pop one creature; then the queue is empty
	_assert_creature_id(customer_queue.pop_secondary_customer(), "ofa_100")
	_assert_creature_id(customer_queue.pop_secondary_customer(), "")


func test_reset_secondary_customer_queue() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200"], 0)
	_assert_creature_id(customer_queue.pop_secondary_customer(), "ofa_100")
	customer_queue.reset_secondary_customer_queue()
	
	# resetting should add ofa_100 to the end of the queue again
	_assert_creature_id(customer_queue.pop_secondary_customer(), "ofa_200")
	_assert_creature_id(customer_queue.pop_secondary_customer(), "ofa_100")
	_assert_creature_id(customer_queue.pop_secondary_customer(), "")


## Populates the secondary queue with the specified creature ids and secondary index
func test_pop_secondary_customers_before() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200", "ofa_300"], 2)
	customer_queue.pop_secondary_customers(["ofa_100"])
	
	_assert_secondary_queue(["ofa_200", "ofa_100", "ofa_300"], 2)


func test_pop_secondary_customers_current() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200", "ofa_300"], 1)
	customer_queue.pop_secondary_customers(["ofa_200"])
	
	_assert_secondary_queue(["ofa_100", "ofa_200", "ofa_300"], 2)


func test_pop_secondary_customers_after() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200", "ofa_300"], 0)
	customer_queue.pop_secondary_customers(["ofa_300"])
	
	_assert_secondary_queue(["ofa_300", "ofa_100", "ofa_200"], 1)


func test_pop_secondary_customers_not_found() -> void:
	_populate_secondary_queue(["ofa_100"], 0)
	customer_queue.pop_secondary_customers(["ofa_invalid"])
	
	_assert_secondary_queue(["ofa_100"], 0)


func test_pop_secondary_customers_empty() -> void:
	_populate_secondary_queue(["ofa_100"], 0)
	customer_queue.pop_secondary_customers([])
	
	_assert_secondary_queue(["ofa_100"], 0)


func test_pop_secondary_customers_multiple() -> void:
	_populate_secondary_queue(["ofa_100", "ofa_200", "ofa_300", "ofa_400", "ofa_500"], 2)
	customer_queue.pop_secondary_customers(["ofa_200", "ofa_400"])
	
	_assert_secondary_queue(["ofa_100", "ofa_200", "ofa_400", "ofa_300", "ofa_500"], 3)


func _populate_secondary_queue(new_creature_ids: Array, new_secondary_index: int) -> void:
	for creature_id in new_creature_ids:
		var creature_def := CreatureDef.new()
		creature_def.creature_id = creature_id
		customer_queue.secondary_queue.append(creature_def)
	customer_queue.secondary_index = new_secondary_index


## Asserts a creature's id.
##
## A null id can be asserted; this assertion is successful if the creature or its id is null.
func _assert_creature_id(creature_def: CreatureDef, expected_id: String) -> void:
	assert_eq("" if not creature_def else creature_def.creature_id, expected_id)


func _assert_secondary_queue(expected_ids: Array, expected_secondary_index: int) -> void:
	var actual_ids := []
	for creature_def in customer_queue.secondary_queue:
		actual_ids.append(creature_def.creature_id)
	assert_eq(actual_ids, expected_ids)
	assert_eq(customer_queue.secondary_index, expected_secondary_index)
