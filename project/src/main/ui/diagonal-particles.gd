extends Control
## Emits a burst of particles in four diagonal directions.
##
## Using a single Particles2D with a 360° spread is problematic, because it often emits a burst of particles in the
## same direction instead of a spread in all directions. This script aims a set of Particles2D nodes in different
## directions to get a more uniform spread.

## Emits a burst of particles in four diagonal directions.
func emit() -> void:
	for particles_2d_node in get_children():
		var particles_2d: Particles2D = particles_2d_node
		particles_2d.restart()
		particles_2d.emitting = true
