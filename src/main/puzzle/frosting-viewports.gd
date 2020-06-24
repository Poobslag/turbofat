class_name FrostingViewports
extends Control
"""
Maintains viewports for drawing smeared snack/cake frosting globs.
"""

# the minimum smear size for globs which are smeared slowly.
export (float) var glob_min_scale := 1.0

# the maximum smear size for globs which are smeared quickly.
export (float) var glob_max_scale := 1.0

func _ready() -> void:
	$Viewport.size = rect_size
	$RainbowViewport.size = rect_size


"""
Adds a frosting smear.

The glob is added to the appropriate viewport and stretched in the direction of its movement.
"""
func add_smear(glob: FrostingGlob) -> void:
	if glob.is_rainbow():
		glob.reparent($RainbowViewport)
	else:
		glob.reparent($Viewport)
	glob.position -= get_global_transform().get_origin()
	glob.modulate.a = clamp(glob.modulate.a + rand_range(0.2, 0.4), 0.0, 1.0)
	
	# stretch the glob in the direction of its movement
	glob.scale.x = rand_range(glob_min_scale, glob_max_scale)
	glob.scale.y = 1 / glob.scale.x
	glob.scale *= 0.44
	glob.rotation = glob.velocity.angle()
	
	glob.fade()
