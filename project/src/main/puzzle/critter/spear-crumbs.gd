extends Particles2D
## Emits crumb particles as blocks are speared.

## Emits particle properties based on the speared blocks.
##
## Parameters:
## 	'crumb_colors': An array of Color instances corresponding to crumb colors for destroyed blocks.
##
## 	'width': The width in pixels which should be covered in crumbs.
func emit_crumbs(crumb_colors: Array, width: float) -> void:
	if emitting:
		return
	
	if not crumb_colors:
		return
	
	modulate = Utils.rand_value(crumb_colors)
	
	# assign width, position, scale
	process_material.emission_box_extents.x = width * 0.5
	position.x = width * 0.5
	
	# assign particle count (6 * cell width)
	amount = 6 * max(1.0, width / 72.0)
	
	emitting = true
