class_name RestaurantPuzzleScene
extends Node

## emitted on the frame when customer bites into some food
signal food_eaten(food_type)

signal current_customer_index_changed(value)

## the index of the customer being served
var current_customer_index := 0 setget set_current_customer_index

onready var _world := $World
onready var _door_chime := $DoorChime

func _ready() -> void:
	for customer_obj in _world.customers:
		var customer: Creature = customer_obj
		customer.connect("food_eaten", self, "_on_Creature_food_eaten")


func set_current_customer_index(new_index: int) -> void:
	if current_customer_index == new_index:
		return
	current_customer_index = new_index
	emit_signal("current_customer_index_changed", new_index)


## Recolors the customer according to the specified creature definition. This involves updating shaders and sprite
## properties.
##
## Parameters:
## 	'creature_def': defines the customer's attributes such as name and appearance.
func summon_customer(creature_def: CreatureDef, customer_index: int = -1) -> void:
	var customer := get_customer(customer_index)
	customer.set_creature_def(creature_def)
	customer.set_comfort(0)


func get_chef() -> Creature:
	return _world.chef


func get_customers() -> Array:
	return _world.customers


func get_customer(customer_index: int = -1) -> Creature:
	return _world.customers[current_customer_index] if customer_index == -1 else _world.customers[customer_index]


## Temporarily suppresses 'hello' and 'door chime' sounds.
func briefly_suppress_sfx(duration: float = 1.0) -> void:
	_door_chime.briefly_suppress_sfx(duration)


func play_door_chime() -> void:
	_door_chime.play_door_chime()


func _on_Creature_food_eaten(food_type: int) -> void:
	emit_signal("food_eaten", food_type)
