class_name GoopViewports
extends Control
## Maintains viewports for drawing smeared snack/cake goop globs.

## minimum smear size for globs which are smeared slowly.
export (float) var glob_min_scale := 1.0

## maximum smear size for globs which are smeared quickly.
export (float) var glob_max_scale := 1.0

export (PackedScene) var GoopGlobScene: PackedScene

func _ready() -> void:
	$Viewport.size = rect_size
	$RainbowViewport.size = rect_size


## Adds a goop smear.
##
## The glob is added to the appropriate viewport and stretched in the direction of its movement.
func add_smear(glob: GoopGlob) -> void:
	var new_glob: GoopGlob = GoopGlobScene.instance()
	new_glob.copy_from(glob)
	if new_glob.is_rainbow():
		$RainbowViewport.add_child(new_glob)
	else:
		$Viewport.add_child(new_glob)
	new_glob.position -= get_global_transform().get_origin()
	new_glob.modulate.a = clamp(new_glob.modulate.a + rand_range(0.1, 0.2), 0.0, 1.0)
	
	# stretch the glob in the direction of its movement
	new_glob.scale.x = rand_range(glob_min_scale, glob_max_scale)
	new_glob.scale.y = 1 / new_glob.scale.x
	new_glob.scale *= 0.44
	new_glob.rotation = new_glob.velocity.angle()
	
	new_glob.fade()
