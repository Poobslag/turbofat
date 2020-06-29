tool
extends SmoothPath
"""
Draws and fills a big blobby curve defining the creature's torso, and provides logic for making it bigger and smaller.

Godot has no out-of-the-box method for tweening curves, so this class exposes a 'fatness' property which can be from
0.0 to 10.0 to tween between a few different torso curves. It also provides some utility methods for developers to
maintain these curve definitions, as they can't be edited with the usual animation editor.
"""

# How fat the creature's body is; 5.0 = 5x normal size
export (float) var fatness := 1.0 setget set_fatness, get_fatness

"""
Setting this to 'true' will prevent the body's current curve from being overwritten by the fatness property, and will
print the curve's definition to the debugger output so that it can be pasted into the _curve_defs field.

The expected workflow is that the developer can adjust the AnimationPlayer to the desired frame, set 'editing' to
true, tweak the SmoothPath coordinates, launch the application, and then copy the printed curve definitions into this
class.
"""
export (bool) var editing := true

# Defines the torso curve coordinates for each of the creature's levels of fatness.
var _curve_defs := [
	{"fatness": 1.0,
		"curve_def": [
			[Vector2(-11.158, -72.063904), Vector2(24.9977, 0.341151), Vector2(-32.903702, -0.449047)],
			[Vector2(-62.051601, -16.445499), Vector2(-0.631155, -31.549101), Vector2(0.500038, 24.995001)],
			[Vector2(-13.1955, 28.0658), Vector2(-27.2528, -0.551655), Vector2(30.985201, 0.627207)],
			[Vector2(37.767101, -13.4088), Vector2(-0.010441, 25), Vector2(0.011404, -27.308201)],
			[Vector2(-11.0971, -72.078102), Vector2(27.096399, -1.30105), Vector2(-24.971201, 1.19901)],
		]},
	{"fatness": 1.5,
		"curve_def": [
			[Vector2(2.48196, -98.051903), Vector2(24.979601, 1.01005), Vector2(-47.211102, -1.90899)],
			[Vector2(-73.3638, -25.1984), Vector2(-0.830624, -38.093201), Vector2(0.634766, 29.110901)],
			[Vector2(0.225128, 32.501999), Vector2(-35.993198, -0.577805), Vector2(42.113602, 0.676056)],
			[Vector2(77.995201, -21.8535), Vector2(-0.801091, 32.944302), Vector2(1.04004, -42.770901)],
			[Vector2(3.64993, -98.051903), Vector2(47.535599, -1.59304), Vector2(-24.986, 0.837346)],
		]},
	{"fatness": 2.0,
		"curve_def": [
			[Vector2(-0.795074, -123.774002), Vector2(24.9736, 1.14793), Vector2(-54.332802, -2.49744)],
			[Vector2(-103.721001, -28.409201), Vector2(0.105613, -58.087898), Vector2(-0.072546, 39.901001)],
			[Vector2(-3.13336, 45.235298), Vector2(-63.802299, 0.391274), Vector2(61.3144, -0.376016)],
			[Vector2(99.250504, -28.409201), Vector2(-0.06645, 39.297901), Vector2(0.097053, -57.396599)],
			[Vector2(-0.352325, -123.877998), Vector2(52.4123, -1.59304), Vector2(-24.988501, 0.759509)],
		]},
	{"fatness": 3.0,
		"curve_def": [
			[Vector2(-8.91397, -205.408997), Vector2(24.998699, 0.254314), Vector2(-81.092499, -0.824962)],
			[Vector2(-153.753006, -56.668701), Vector2(-0.645028, -82.339104), Vector2(0.43048, 54.951599)],
			[Vector2(-7.45096, 49.156601), Vector2(-83.869598, 1.41249), Vector2(82.6315, -1.39163)],
			[Vector2(138.363998, -50.816601), Vector2(-0.945125, 49.6637), Vector2(1.22209, -64.217499)],
			[Vector2(-8.91397, -204.921997), Vector2(88.370598, -1.59304), Vector2(-24.996, 0.450598)],
		]},
	{"fatness": 5.0,
		"curve_def": [
			[Vector2(-15.1975, -342.556), Vector2(24.9942, -0.537486), Vector2(-120.339996, 2.58783)],
			[Vector2(-262.069, -87.764297), Vector2(-2.46623, -173.910004), Vector2(1.31159, 92.488998)],
			[Vector2(-29.1206, 90.612198), Vector2(-137.335999, -0.624495), Vector2(163.981003, 0.745659)],
			[Vector2(236.408005, -78.804703), Vector2(-0.799582, 82.650398), Vector2(1.55683, -160.925003)],
			[Vector2(-14.9055, -342.556), Vector2(128.186996, -2.16184), Vector2(-24.9965, 0.421561)],
		]},
	{"fatness": 10.0,
		"curve_def": [
			[Vector2(-1.29367, -658.921021), Vector2(24.996201, 0.436254), Vector2(-186.572998, -3.25622)],
			[Vector2(-494.141998, -156.332993), Vector2(-4.48658, -290.76001), Vector2(3.44123, 223.014008)],
			[Vector2(-18.8258, 204.050003), Vector2(-219.143005, -2.18805), Vector2(241.903, 2.4153)],
			[Vector2(497.39801, -131.007996), Vector2(2.04043, 215.119003), Vector2(-3.31852, -349.867004)],
			[Vector2(0.654327, -658.921021), Vector2(194.419998, -4.10986), Vector2(-24.994499, 0.528361)],
		]}
	]

func _ready() -> void:
	if editing:
		# Print the curve's details. This is used for developers to add or modify the curve definitions in this class.
		for i in curve.get_point_count():
			print("[Vector2%s, Vector2%s, Vector2%s]," % \
					[curve.get_point_position(i), curve.get_point_in(i), curve.get_point_out(i)])


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
	while fatness_index < _curve_defs.size() - 2 and _curve_defs[fatness_index + 1].fatness < fatness:
		fatness_index += 1

	# curve_def_low is the lower fatness curve. curve_def_high is the higher fatness curve
	var curve_def_low: Dictionary = _curve_defs[fatness_index]
	var curve_def_high: Dictionary = _curve_defs[fatness_index + 1]
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


func _on_Creature_movement_mode_changed(movement_mode: bool) -> void:
	visible = not movement_mode
