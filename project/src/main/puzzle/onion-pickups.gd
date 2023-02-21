class_name OnionPickups
extends Control
## Draws pickups on the playfield for certain levels during night mode.
##
## These pickups are synchronized with daytime pickups, and rendered over them.

export (PackedScene) var PickupScene: PackedScene

## pickups to synchronize with
var source_pickups: Pickups

## key: (Vector2) playfield cell positions
## value: (OnionPickup) Pickup node contained within that cell
var _pickups_by_cell := {}

onready var _visuals := $Visuals

## synchronize our state with the source pickups
func _process(_delta: float) -> void:
	## remove any pickups not in the source pickups
	for cell in Utils.subtract(_pickups_by_cell.keys(), source_pickups.get_cells_with_pickups()):
		_remove_pickup(cell)
	
	## add any missing pickups from the source pickups
	for cell in Utils.subtract(source_pickups.get_cells_with_pickups(), _pickups_by_cell.keys()):
		_add_pickup(cell)
	
	## synchronize the pickup state from the source pickups
	for cell in _pickups_by_cell:
		_synchronize_pickup(cell)


## Removes a pickup from a playfield cell.
func _remove_pickup(cell: Vector2) -> void:
	_pickups_by_cell[cell].queue_free()
	_pickups_by_cell.erase(cell)


## Adds a pickup to a playfield cell.
func _add_pickup(cell: Vector2) -> void:
	var pickup: OnionPickup = PickupScene.instance()
	pickup.food_type = source_pickups.get_pickup(cell).food_type
	pickup.food_shown = source_pickups.get_pickup(cell).food_shown
	pickup.position = source_pickups.get_pickup(cell).position
	pickup.scale = source_pickups.get_pickup(cell).scale
	pickup.z_index = 4
	
	_pickups_by_cell[cell] = pickup
	_visuals.add_child(pickup)


## Synchronize a pickup's state with the source pickup.
func _synchronize_pickup(cell: Vector2) -> void:
	_pickups_by_cell[cell].food_type = source_pickups.get_pickup(cell).food_type
	_pickups_by_cell[cell].food_shown = source_pickups.get_pickup(cell).food_shown
