class_name CreatureQueue
## Queue of creatures who appear when the player solves puzzles.
##
## This includes a 'primary queue' of creatures guaranteed to show up at the start of a puzzle, and a 'secondary queue'
## of creatures who randomly show up during a puzzle.

## Path to the directory with secondary creatures. Can be changed for tests.
const DEFAULT_SECONDARY_CREATURES_PATH := "res://assets/main/creatures/secondary"

## Path to the directory with secondary creatures. Can be changed for tests.
var secondary_creatures_path := DEFAULT_SECONDARY_CREATURES_PATH setget set_secondary_creatures_path

## Queue of creatures who show up at the start of a puzzle.
var primary_queue := []
var primary_index: int

## Queue of creatures who randomly show up during a puzzle.
var secondary_queue: Array
var secondary_index := 0

func _init() -> void:
	_load_secondary_creatures()


func set_secondary_creatures_path(value: String) -> void:
	secondary_creatures_path = value
	secondary_queue.clear()
	secondary_index = 0
	_load_secondary_creatures()


## Returns 'true' if the primary creature queue has any creatures left.
func has_primary_creature() -> bool:
	return primary_index < primary_queue.size()


## Returns the next creature in the primary creature queue, and advances the queue.
func pop_primary_creature() -> CreatureDef:
	var creature_def: CreatureDef
	if has_primary_creature():
		creature_def = primary_queue[primary_index]
		primary_index += 1
	return creature_def


## Returns 'true' if the secondary creature queue has any creatures left.
func has_secondary_creature() -> bool:
	return secondary_index < secondary_queue.size()


## Returns the next creature in the secondary creature queue, and advances the queue.
func pop_secondary_creature() -> CreatureDef:
	var creature_def: CreatureDef
	if has_secondary_creature():
		creature_def = secondary_queue[secondary_index]
		# don't loop back through the queue; we don't want the same customer showing up twice during a puzzle
		secondary_index += 1
	return creature_def


## Empties the queue of creatures who will show up at the start of the next puzzle.
##
## Also rotates the secondary creatures so the same creatures don't show up over and over.
func clear() -> void:
	primary_queue = []
	primary_index = 0
	reset_secondary_creature_queue()


## Resets the queue of secondary creatures; recognizable characters who show up now and then, but don't have any chats
## or levels
##
## This resets the queue_index to 0, and moves the beginning of the queue to the end.
func reset_secondary_creature_queue() -> void:
	if secondary_queue and secondary_index > 0:
		var new_queue := []
		new_queue += secondary_queue.slice(
				secondary_index, secondary_queue.size() - 1)
		new_queue += secondary_queue.slice(0, secondary_index - 1)
		secondary_queue = new_queue
		secondary_index = 0


## Loads all secondary creature data from a directory of json files.
func _load_secondary_creatures() -> void:
	if not secondary_creatures_path:
		return
	
	var dir := Directory.new()
	dir.open(secondary_creatures_path)
	dir.list_dir_begin(true, true)
	while true:
		var file := dir.get_next()
		if not file:
			break
		else:
			var creature_def: CreatureDef = CreatureDef.new()
			creature_def = creature_def.from_json_path("%s/%s" % [dir.get_current_dir(), file.get_file()])
			creature_def.creature_id = file.get_file().get_basename()
			secondary_queue.append(creature_def)
	dir.list_dir_end()
	secondary_queue.shuffle()
