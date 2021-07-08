#tool #uncomment to view creature in editor
class_name CreatureCurve
extends SmoothPath
"""
Draws a big blobby shape defining a part of the creature's shadow.

Godot has no out-of-the-box method for tweening curves, so this class exposes a 'fatness' property which can be from
0.0 to 10.0 to tween between a few different torso curves. It also provides some utility methods for developers to
maintain these curve definitions, as they can't be edited with the usual animation editor.
"""

# Emitted when the curve becomes drawn, becomes non-drawn, or changes its shape
signal appearance_changed

"""
Setting this to 'true' will prevent the body's current curve from being overwritten by the fatness property.
"""
export (bool) var editing := true

# toggle to save the currently edited curve in this node's 'curve_defs'
export (bool) var _save_curve: bool setget save_curve

# defines the shadow curve coordinates for each of the creature's levels of fatness.
export (Array) var curve_defs: Array setget set_curve_defs

# if false, the body will not render this curve when the creature faces away from the camera.
export (bool) var drawn_when_facing_north: bool = true

# if false, the body will not render this curve when the creature faces toward the camera.
export (bool) var drawn_when_facing_south: bool = true

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

# If true, the curve is drawn on the creature's body.
# This is independent of the 'visible' property. When the game is running, these curves will be invisible but still
# must be drawn. When developers are editing the curve data, these curves must  visible for Godot's Path2D tools.
var drawn := true setget set_drawn

var creature_visuals: CreatureVisuals

func _ready() -> void:
	_refresh_creature_visuals_path()
	_refresh_curve()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


"""
Saves the currently edited curve in this node's 'curve_defs'.
"""
func save_curve(value: bool) -> void:
	if not value:
		return
	if not creature_visuals:
		push_warning("Curve not saved. creature_visuals not set")
		return
	
	var fatness_index := 0
	while fatness_index < curve_defs.size() \
			and stepify(creature_visuals.visual_fatness, 0.01) \
				> stepify(float(curve_defs[fatness_index].fatness), 0.01):
		fatness_index += 1
	
	var new_entry := {
		"fatness": creature_visuals.visual_fatness,
		"curve_def": []
	}
	for i in curve.get_point_count():
		new_entry.curve_def.append([curve.get_point_position(i), curve.get_point_in(i), curve.get_point_out(i)])
	
	if fatness_index < curve_defs.size() \
			and is_equal_approx(float(curve_defs[fatness_index].fatness), creature_visuals.visual_fatness):
		# Found an exact match. Replace the current curve.
		curve_defs[fatness_index] = new_entry
	else:
		# The current fatness setting isn't set yet. Add a new curve.
		curve_defs.insert(fatness_index, new_entry)


"""
Updates the 'drawn' property based on the creature's orientation.
"""
func refresh_drawn() -> void:
	var new_drawn := true
	if creature_visuals:
		if not drawn_when_facing_north and creature_visuals.oriented_north():
			new_drawn = false
		if not drawn_when_facing_south and creature_visuals.oriented_south():
			new_drawn = false
	set_drawn(new_drawn)


func set_drawn(new_drawn: bool) -> void:
	if drawn == new_drawn:
		return
	drawn = new_drawn
	emit_signal("appearance_changed")


func set_curve_defs(new_curve_defs: Array) -> void:
	curve_defs = new_curve_defs
	_refresh_curve()


"""
Disconnects creature visuals listeners specific to arm shadows.

Can be overridden to disconnect additional listeners.
"""
func disconnect_creature_visuals_listeners() -> void:
	creature_visuals.disconnect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")
	creature_visuals.disconnect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
	creature_visuals.disconnect("dna_loaded", self, "_on_CreatureVisuals_dna_loaded")


"""
Connects creature visuals listeners specific to arm shadows.

Can be overridden to connect additional listeners.
"""
func connect_creature_visuals_listeners() -> void:
	creature_visuals.connect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")
	creature_visuals.connect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
	creature_visuals.connect("dna_loaded", self, "_on_CreatureVisuals_dna_loaded")


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	if creature_visuals:
		disconnect_creature_visuals_listeners()
	creature_visuals = get_node(creature_visuals_path)
	connect_creature_visuals_listeners()


func _refresh_curve() -> void:
	if editing or not is_inside_tree() or not creature_visuals:
		# Don't overwrite the curve based on the fatness attribute. The developer is currently making manual changes
		# to it, and we don't want to undo their changes.
		return
	
	curve.clear_points()
	if curve_defs:
		# curve_def_low is the lower fatness curve. curve_def_high is the higher fatness curve. we lerp between them
		# to calculate the curve to draw
		var curve_def_low: Dictionary = curve_defs[0]
		var curve_def_high: Dictionary = curve_defs[0]
		
		# How much of each curve we should use. A value greater than 0.5 means we'll mostly use curve_def_high, a
		# value less than 0.5 means we'll mostly use curve_def_low.
		var f_pct := 1.0
		
		if curve_defs.size() > 1:
			var fatness_index := 0
			while fatness_index < curve_defs.size() - 2 \
					and curve_defs[fatness_index + 1].fatness < creature_visuals.visual_fatness:
				fatness_index += 1
		
			curve_def_low = curve_defs[fatness_index]
			curve_def_high = curve_defs[fatness_index + 1]
			f_pct = inverse_lerp(curve_def_low.fatness, curve_def_high.fatness, creature_visuals.visual_fatness)
		
		for i in range(curve_def_low.curve_def.size()):
			var point_pos: Vector2 = lerp(curve_def_low.curve_def[i][0], curve_def_high.curve_def[i][0], f_pct)
			var point_in: Vector2 = lerp(curve_def_low.curve_def[i][1], curve_def_high.curve_def[i][1], f_pct)
			var point_out: Vector2 = lerp(curve_def_low.curve_def[i][2], curve_def_high.curve_def[i][2], f_pct)
			curve.add_point(point_pos, point_in, point_out)
	update()
	emit_signal("appearance_changed")


"""
Recalculates the curve coordinates based on how fat the creature is.

Parameters:
	'fatness': How fat the creature's body is; 5.0 = 5x normal size
"""
func _on_CreatureVisuals_visual_fatness_changed() -> void:
	_refresh_curve()


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, _new_orientation: int) -> void:
	refresh_drawn()


func _on_CreatureVisuals_dna_loaded() -> void:
	_refresh_curve()
