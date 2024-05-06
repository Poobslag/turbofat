tool
extends Control
## Emits a burst of particles in four diagonal directions.
##
## Using a single Particles2D with a 360° spread is problematic, because it often emits a burst of particles in the
## same direction instead of a spread in all directions. This script aims a set of Particles2D nodes in different
## directions to get a more uniform spread.

## Total amount of particles to split amongst all four directions.
##
## A value of 8 will result in 2 particles being fired in all four directions.
export (int, 4, 200) var amount := 8 setget set_amount

func _ready() -> void:
	_refresh_amount()


## Emits a burst of particles in four diagonal directions.
func emit() -> void:
	for particles_2d_node in get_children():
		var particles_2d: Particles2D = particles_2d_node
		particles_2d.restart()
		particles_2d.emitting = true


func set_amount(new_amount: int) -> void:
	amount = new_amount
	_refresh_amount()


## Assigns the Particles2D.amount property for all four Particles2D children.
##
## We distribute the particles as evenly as possible among the children. If the chosen amount is not evenly divisible,
## some children will randomly emit one extra particle.
func _refresh_amount() -> void:
	if not is_inside_tree():
		return
	
	var amount_left := amount
	
	## reorder the children randomly so that none of the children are favored
	var children: Array = get_children()
	children.shuffle()
	
	while children:
		var particles_2d: Particles2D = children.front()
		
		## give the next child an equal share of the remaining particles, rounding up
		particles_2d.amount = int(ceil(float(amount_left) / children.size()))
		amount_left -= particles_2d.amount
		
		children.pop_front()
