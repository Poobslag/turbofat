class_name CustomerQueue
## Queue of creatures who appear when the player solves puzzles.
##
## This includes a 'priority queue' of creatures guaranteed to show up at the start of a puzzle, and a 'standard queue'
## of creatures who randomly show up during a puzzle.

## Path to the directory with standard customers. Can be changed for tests.
const DEFAULT_SECONDARY_CUSTOMERS_PATH := "res://assets/main/creatures/secondary"

## Path to the directory with standard customers. Can be changed for tests.
var secondary_customers_path := DEFAULT_SECONDARY_CUSTOMERS_PATH setget set_secondary_customers_path

## Queue of creatures who show up at the start of a puzzle.
var priority_queue := []
var priority_index: int

## Queue of creatures who randomly show up during a puzzle.
var standard_queue: Array
var standard_index := 0

func _init() -> void:
	_load_standard_customers()


func set_secondary_customers_path(value: String) -> void:
	secondary_customers_path = value
	standard_queue.clear()
	standard_index = 0
	_load_standard_customers()


## Returns 'true' if the priority customer queue has any creatures left.
func has_priority_customer() -> bool:
	return priority_index < priority_queue.size()


## Returns the next creature in the priority customer queue, and advances the queue.
func pop_priority_customer() -> CreatureDef:
	var creature_def: CreatureDef
	if has_priority_customer():
		creature_def = priority_queue[priority_index]
		priority_index += 1
	return creature_def


## Returns 'true' if the standard customer queue has any creatures left.
func has_standard_customer() -> bool:
	return standard_index < standard_queue.size()


## Returns the next creature in the standard customer queue, and advances the queue.
func pop_standard_customer() -> CreatureDef:
	var creature_def: CreatureDef
	if has_standard_customer():
		creature_def = standard_queue[standard_index]
		# don't loop back through the queue; we don't want the same customer showing up twice during a puzzle
		standard_index += 1
	return creature_def


## Empties the queue of creatures who will show up at the start of the next puzzle.
##
## Also rotates the standard customers so the same creatures don't show up over and over.
func clear() -> void:
	priority_queue = []
	priority_index = 0
	reset_standard_customer_queue()


## Resets the queue of standard customers; recognizable characters who show up now and then, but don't have any chats
## or levels
##
## This resets the queue_index to 0, and moves the beginning of the queue to the end.
func reset_standard_customer_queue() -> void:
	if standard_queue and standard_index > 0:
		var new_queue := []
		new_queue += standard_queue.slice(
				standard_index, standard_queue.size() - 1)
		new_queue += standard_queue.slice(0, standard_index - 1)
		standard_queue = new_queue
		standard_index = 0


## Shift standard customers in the queue so that they will not be summoned soon.
##
## This prevents the player from seeing a random customer from the standard queue at an inopportune time, such as
## picking a level featuring a creature and then having them show up in the restaurant later during that same level.
##
## Parameters:
## 	'creature_ids': The ids of creatures who should be shifted in the queue
func pop_standard_customers(creature_ids: Array) -> void:
	for creature_id in creature_ids:
		var creature_index := -1
		for i in range(standard_queue.size()):
			if standard_queue[i].creature_id == creature_id:
				creature_index = i
				break
		
		if creature_index == -1:
			# creature not found
			pass
		else:
			var creature_def: CreatureDef = standard_queue[creature_index]
			standard_queue.remove(creature_index)
			if creature_index >= standard_index:
				# when moving a creature backwards in the queue, we advance standard_index
				standard_index += 1
			standard_queue.insert(standard_index - 1, creature_def)


## Loads all standard customer data from a directory of json files.
func _load_standard_customers() -> void:
	if not secondary_customers_path:
		return
	
	var dir := Directory.new()
	dir.open(secondary_customers_path)
	dir.list_dir_begin(true, true)
	while true:
		var file := dir.get_next()
		if not file:
			break
		else:
			var creature_def: CreatureDef = CreatureDef.new()
			creature_def = creature_def.from_json_path("%s/%s" % [dir.get_current_dir(), file.get_file()])
			standard_queue.append(creature_def)
	dir.list_dir_end()
	standard_queue.shuffle()
