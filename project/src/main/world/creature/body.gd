class_name Body
#tool #uncomment to view creature in editor
extends Node2D
## Draws the creature's torso. This includes the body shape, a belly, shadows and an outline.
##
## Because the creature can grow, the torso is drawn dynamically and is not represented by a sprite. The shape of the
## torso and its various parts are stored in CreatureCurve instances which are substituted at runtime. These
## CreatureCurve instances are invisible by default, but can be made visible by toggling the 'editing' flag. This is
## useful when editing curves in the Godot editor.

@export var creature_visuals_path: NodePath: set = set_creature_visuals_path

## Color for the body outline
@export var line_color := Color.BLACK

## Main color for most of the creature's body
@export var body_color := Color.GREEN

## Secondary color for the creature's belly
@export var belly_color := Color.RED

## Color to use for shadows, including an alpha component
@export var shadow_color := Color.BLUE

## If 'true', the CreatureCurve instances will be made visible. This is useful
## when editing curves in the Godot editor.
@export var editing := false: set = set_editing

## Rounded shape of the torso.
var body_shape: CreatureCurve

## (Optional) Shape of the belly markings.
var belly: CreatureCurve

## (Optional) Body-colored line which blends the neck with the back of the head
var neck_blend: CreatureCurve

## Node containing CreatureCurves which define the shapes of shadows for the arms, body and head.
var shadows: Node

var _creature_visuals: CreatureVisuals

func _ready() -> void:
	_refresh_creature_visuals_path()
	refresh_children()


func _draw() -> void:
	if _creature_visuals.movement_mode == Creatures.SPRINT:
		# don't draw creature while sprinting
		return
	
	_fill_body_shape()
	_fill_belly()
	_fill_shadows()
	_outline_body_shape()
	_draw_neck_blend()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


func set_editing(new_editing: bool) -> void:
	editing = new_editing
	_refresh_editing()


## Reassigns the CreatureCurve fields based on the current child nodes.
func refresh_children() -> void:
	_disconnect_curve_signals([body_shape, belly, neck_blend])
	if shadows:
		_disconnect_curve_signals(shadows.get_children())
	
	body_shape = $BodyShape if has_node("BodyShape") else null
	belly = $Belly if has_node("Belly") else null
	neck_blend = $NeckBlend if has_node("NeckBlend") else null
	shadows = $Shadows if has_node("Shadows") else null
	_refresh_editing()
	_connect_curve_signals([body_shape, belly, neck_blend])
	if shadows:
		_connect_curve_signals(shadows.get_children())
	
	queue_redraw()


## Connects signals to receive updates from the specified CreatureCurves.
func _connect_curve_signals(creature_curves: Array) -> void:
	for creature_curve in creature_curves:
		if creature_curve:
			creature_curve.appearance_changed.connect(_on_CreatureCurve_appearance_changed)


## Disconnects signals to no longer receive updates from the specified CreatureCurves.
func _disconnect_curve_signals(creature_curves: Array) -> void:
	for creature_curve in creature_curves:
		if creature_curve:
			creature_curve.appearance_changed.disconnect(_on_CreatureCurve_appearance_changed)


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and not creature_visuals_path.is_empty()):
		return
	
	if _creature_visuals:
		_creature_visuals.movement_mode_changed.disconnect(_on_CreatureVisuals_movement_mode_changed)
	_creature_visuals = get_node(creature_visuals_path) if not creature_visuals_path.is_empty() else null
	if _creature_visuals:
		_creature_visuals.movement_mode_changed.connect(_on_CreatureVisuals_movement_mode_changed)


func _refresh_editing() -> void:
	if not is_inside_tree():
		return
	
	if body_shape:
		body_shape.visible = editing
	if belly:
		belly.visible = editing
	if neck_blend:
		neck_blend.visible = editing
	if shadows:
		shadows.visible = editing


func _fill_body_shape() -> void:
	if not _curve_drawn(body_shape):
		return
	
	_draw_body_polygon(body_shape.curve.get_baked_points(), body_color)


func _outline_body_shape() -> void:
	if not _curve_drawn(body_shape):
		return
	
	_draw_body_polyline(body_shape.curve.get_baked_points(), line_color,
			body_shape.line_width, body_shape.closed)


func _draw_neck_blend() -> void:
	if not _curve_drawn(neck_blend):
		return
	
	var shaded_body_color := body_color.blend(shadow_color)
	_draw_body_polyline(neck_blend.curve.get_baked_points(), shaded_body_color,
			neck_blend.line_width, neck_blend.closed)


func _curve_drawn(creature_curve: CreatureCurve) -> bool:
	return creature_curve and creature_curve.drawn


## Fills the shadows for the arms, body and head.
##
## The shadow shapes overrun the body shape and overlap each other. We perform some processing to avoid drawing
## overlapping shadows and to avoid drawing outside the body shape.
func _fill_shadows() -> void:
	if not shadows:
		return
	
	# Collect all of the polygon point data in a big list
	var all_polypoints := []
	for shadow_obj in shadows.get_children():
		var shadow: CreatureCurve = shadow_obj
		if not _curve_drawn(shadow):
			continue
		all_polypoints.append(shadow.curve.get_baked_points())
	
	# Merge any intersecting polygons
	var i := 0
	var j := 1
	while i < all_polypoints.size():
		j = i + 1
		while j < all_polypoints.size():
			var result: Array = Geometry2D.merge_polygons(all_polypoints[i], all_polypoints[j])
			if result.size() == 1:
				# the polygons intersect. replace the two entries a merged polygon
				all_polypoints.remove_at(j)
				all_polypoints[i] = result[0]
				continue
			
			# polygons didn't intersect; continue checking for intersections
			j += 1
		i += 1
	
	# Draw the resulting polygons
	var body_shape_points := body_shape.curve.get_baked_points()
	for polypoints in all_polypoints:
		# Avoid drawing outside the body shape
		var intersecting_points_array := Geometry2D.intersect_polygons(body_shape_points, polypoints)
		for intersecting_points_obj in intersecting_points_array:
			_draw_body_polygon(intersecting_points_obj, shadow_color)


## Fills the creature's belly markings.
##
## The belly markings overrun the body shape. We perform some processing to avoid drawing outside the body shape.
func _fill_belly() -> void:
	if not _curve_drawn(belly):
		return
	
	var body_shape_points := body_shape.curve.get_baked_points()
	var belly_points := belly.curve.get_baked_points()
	
		# Avoid drawing outside the body shape
	var intersecting_points_array := Geometry2D.intersect_polygons(body_shape_points, belly_points)
	for intersecting_points_obj in intersecting_points_array:
		_draw_body_polygon(intersecting_points_obj, belly_color)


## Draw a filled polygon.
func _draw_body_polygon(points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3 or color.a == 0:
		# don't waste cycles filling invisible polygons
		return
	
	# todo: polygon antialiasing is disabled; this used to be specified as a parameter to draw_colored_polygon but 'Normal maps are now specified as part of the CanvasTexture rather than specifying them on the Canvasitem itself' https://github.com/godotengine/godot/issues/59683
	draw_colored_polygon(points, color)


## Draw a polyline.
func _draw_body_polyline(points: PackedVector2Array, color: Color, line_width: float, closed: bool) -> void:
	if points.size() < 3 or color.a == 0:
		# don't waste cycles outlining invisible polygons
		return
	
	if closed:
		points.append(points[0])
	draw_polyline(points, color, line_width)


func _on_CreatureCurve_appearance_changed() -> void:
	queue_redraw()


func _on_CreatureVisuals_movement_mode_changed(_old_mode: Creatures.MovementMode, _new_mode: Creatures.MovementMode) -> void:
	queue_redraw()
