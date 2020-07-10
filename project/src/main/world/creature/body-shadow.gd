tool
extends SmoothPath
"""
Draws a big blobby shape defining a part of the creature's shadow.

Godot has no out-of-the-box method for tweening curves, so this class exposes a 'fatness' property which can be from
0.0 to 10.0 to tween between a few different torso curves. It also provides some utility methods for developers to
maintain these curve definitions, as they can't be edited with the usual animation editor.
"""

# How fat the creature's body is; 5.0 = 5x normal size
export (float) var fatness := 1.0 setget set_fatness, get_fatness

"""
Setting this to 'true' will prevent the body's current curve from being overwritten by the fatness property, and will
print the curve's definition to the debugger output so that it can be pasted into the _curve_defs field.
"""
export (bool) var editing := true

# toggle to save the currently edited curve in this node's 'curve_defs'
export (bool) var save_curve: bool setget save_curve

# defines the shadow curve coordinates for each of the creature's levels of fatness.
export (Array) var curve_defs: Array

"""
Saves the currently edited curve in this node's 'curve_defs'.
"""
func save_curve(value: bool) -> void:
	if not value:
		return
	
	var fatness_index := 0
	while fatness_index < curve_defs.size() and float(curve_defs[fatness_index].fatness) < fatness:
		fatness_index += 1
	
	var new_entry: Dictionary = {
		"fatness": fatness,
		"curve_def": []
	}
	for i in curve.get_point_count():
		new_entry.curve_def.append([curve.get_point_position(i), curve.get_point_in(i), curve.get_point_out(i)])
	
	if fatness_index < curve_defs.size() and is_equal_approx(float(curve_defs[fatness_index].fatness), fatness):
		# Found an exact match. Replace the current curve.
		curve_defs[fatness_index] = new_entry
	else:
		# The current fatness setting isn't set yet. Add a new curve.
		curve_defs.insert(fatness_index, new_entry)


"""
Sets how fat the creature's body is, and recalculates the curve coordinates.

Parameters:
	'fatness': How fat the creature's body is; 5.0 = 5x normal size
"""
func set_fatness(new_fatness: float) -> void:
	fatness = new_fatness
	if editing:
		# Don't overwrite the curve based on the fatness attribute. The developer is currently making manual changes
		# to it, and we don't want to undo their changes.
		return

	var fatness_index := 0
	while fatness_index < curve_defs.size() - 2 and curve_defs[fatness_index + 1].fatness < fatness:
		fatness_index += 1

	# curve_def_low is the lower fatness curve. curve_def_high is the higher fatness curve
	var curve_def_low: Dictionary = curve_defs[fatness_index]
	var curve_def_high: Dictionary = curve_defs[fatness_index + 1]
	curve.clear_points()

	# Calculate how much of each curve we should use. A value greater than 0.5 means we'll mostly use curve_def_high,
	# a value less than 0.5 means we'll mostly use curve_def_low.
	var f_pct := clamp((fatness - curve_def_low.fatness) / (curve_def_high.fatness - curve_def_low.fatness), 0, 1.0)

	for i in range(curve_def_low.curve_def.size()):
		var point_pos: Vector2 = lerp(curve_def_low.curve_def[i][0], curve_def_high.curve_def[i][0], f_pct)
		var point_in: Vector2 = lerp(curve_def_low.curve_def[i][1], curve_def_high.curve_def[i][1], f_pct)
		var point_out: Vector2 = lerp(curve_def_low.curve_def[i][2], curve_def_high.curve_def[i][2], f_pct)
		curve.add_point(point_pos, point_in, point_out)
	update()


func get_fatness() -> float:
	return fatness
