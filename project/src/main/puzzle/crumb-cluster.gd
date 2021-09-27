class_name CrumbCluster
extends Node2D
"""
A cluster of crumbs which appears when the customer eats.
"""

# The lifetime of the particles in seconds. The CrumbCluster also deletes itself after this duration.
export (float) var lifetime := 1.0

# An int corresponding to a FoodItem frame
var food_type setget set_food_type

# Timer which causes the CrumbCluster to free itself
onready var _timer := $Timer

# This cluster is made up of multiple CPUParticles2D instances so that multiple colors can be shown.
onready var _particles := [$Particles0, $Particles1, $Particles2]

func _ready() -> void:
	_timer.start(lifetime)
	for particles in _particles:
		particles.emitting = true
		particles.lifetime = lifetime
	_refresh_food_type()


func set_food_type(new_food_type: int) -> void:
	food_type = new_food_type
	_refresh_food_type()


"""
Updates the crumb count and colors based on the food type.
"""
func _refresh_food_type() -> void:
	if not is_inside_tree():
		return
	
	var crumb_definition := CrumbDefinitions.get_definition(food_type)
	var crumb_colors := crumb_definition.crumb_colors.duplicate()
	crumb_colors.shuffle()
	
	for i in range(_particles.size()):
		var particles: Particles2D = _particles[i]
		# if max_crumb_count is 9.0, rand_range(1, 4) returns a float from 1.00 to 3.999
		particles.amount = rand_range(1, 1 + crumb_definition.max_crumb_count / 3.0)
		particles.modulate = crumb_colors[i % crumb_colors.size()]


"""
Frees the CrumbCluster instance after the particles expire.
"""
func _on_Timer_timeout() -> void:
	queue_free()
