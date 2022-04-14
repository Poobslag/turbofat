class_name RestaurantPuzzleScene
extends Node2D
## Handles animations and audio/visual effects for the restaurant and its creatures.

## emitted on the frame when creature bites into some food
signal food_eaten(food_type)
signal current_creature_index_changed(value)

## the creature which food is currently being served to
var current_creature_index := 0 setget set_current_creature_index

## all of the seats in the scene. each 'seat' includes a table, chairs, a creature, etc...
onready var _seats := [$Seat1, $Seat2, $Seat3]
onready var _creatures := [$Creature1, $Creature2, $Creature3]

func _ready() -> void:
	for i in range(3):
		_get_seat(i).set_creature(_creatures[i])
		_get_seat(i).refresh()
	
	var chef_id := StringUtils.default_if_empty(CurrentLevel.chef_id, CreatureLibrary.PLAYER_ID)
	$Chef.set_creature_def(PlayerData.creature_library.get_creature_def(chef_id))
	$Chef.set_orientation(Creatures.SOUTHWEST)


func set_current_creature_index(new_index: int) -> void:
	if current_creature_index == new_index:
		return
	current_creature_index = new_index
	emit_signal("current_creature_index_changed", new_index)


## Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
## properties.
##
## Parameters:
## 	'creature_def': defines the creature's attributes such as name and appearance.
func summon_customer(creature_def: CreatureDef, creature_index: int = -1) -> void:
	get_customer(creature_index).set_creature_def(creature_def)
	get_customer(creature_index).set_comfort(0)
	_get_seat(creature_index).refresh()


func set_fatness(new_fatness_percent: float, creature_index: int = -1) -> void:
	get_customer(creature_index).set_fatness(new_fatness_percent)


func get_fatness(creature_index: int = -1) -> float:
	return get_customer(creature_index).get_fatness()


func get_chef() -> Creature:
	return $Chef as Creature


## Returns an array of Creature objects representing customers in the scene.
func get_customers() -> Array:
	return _creatures


## Returns the creature with the specified optional index. Defaults to the creature being fed.
func get_customer(creature_index: int = -1) -> Creature:
	return _creatures[current_creature_index] if creature_index == -1 else _creatures[creature_index]


## Temporarily suppresses 'hello' and 'door chime' sounds.
func briefly_suppress_sfx(duration: float = 1.0) -> void:
	$DoorChime.briefly_suppress_sfx(duration)


## Returns the seat with the specified optional index. Defaults to the seat of the creature being fed.
func _get_seat(seat_index: int = -1) -> Control:
	return _seats[current_creature_index] if seat_index == -1 else _seats[seat_index]


func _on_CreatureVisuals_food_eaten(food_type: int) -> void:
	emit_signal("food_eaten", food_type)
