class_name FocusCoordinator
## Determines and assigns focus neighbours to a group of controls based on cardinal directions within the provided set
## of controls.
##
## Godot's default focus behavior can sometimes lead to unexpected results, such as when navigating in the Creature
## Editor. For instance, moving right towards color buttons may redirect focus upwards to category buttons.
##
## This class overrides Godot's default focus behavior by explicitly defining focus neighbours for all four directions
## within the provided set of controls. Focus neighbours are prioritized as follows:
##
## 	1. Nearest control in a horizontal or vertical line. Controls do not need to share X/Y coordinates but must
## 		occupy the same horizontal or vertical screen space.
##
## 	2. Nearest control not in a horizontal or vertical line. Controls can be diagonal as long as they are in the
## 		appropriate direction.
##
## 	3. Self. If no suitable focus neighbour is found, the control is assigned as its own focus neighbour. This prevents
## 		Godot's default focus behavior from taking over.

## Controls to manage focus neighbours for.
var _controls: Array

## key: (Vector2) Unit vector for a cardinal direction.
## value: (String) Focus neighbour control property for the specified cardinal direction.
const FOCUS_NEIGHBOUR_PROPERTY_BY_DIRECTION := {
	Vector2.LEFT: "focus_neighbour_left",
	Vector2.UP: "focus_neighbour_top",
	Vector2.RIGHT: "focus_neighbour_right",
	Vector2.DOWN: "focus_neighbour_bottom",
}

## Parameters:
## 	'init_controls': Control nodes to manage focus neighbours for.
func _init(init_controls: Array) -> void:
	_controls = init_controls


## Defines focus neighbours for all managed controls.
func assign_all() -> void:
	for control in _controls:
		for direction in FOCUS_NEIGHBOUR_PROPERTY_BY_DIRECTION:
			_assign_focus_neighbour(control, direction)


## Finds the nearest control to the given control in a horizontal/vertical line.
##
## The two controls do not need to share X/Y coordinates, but they must be arranged occupy the same horizontal/
## vertical screen space.
##
## Parameters:
## 	'control': The Control node for which to find the nearest control.
##
## 	'direction': The direction vector in which to search for the nearest control.
##
## Returns:
## 	The nearest Control node in the specified direction, or 'null' if none was found.
func find_nearest_precise(control: Control, direction: Vector2) -> Control:
	var nearest_neighbour: Control = null
	var nearest_distance := 999999
	
	# A rectangle originating from "control" in the direction of "direction"
	var extended_control_rect := control.get_global_rect()
	extended_control_rect = extended_control_rect.expand(extended_control_rect.get_center() + 999999 * direction)
	
	for other_control in _controls:
		if other_control == control or not other_control.is_visible_in_tree():
			continue
		
		var center_difference := _center_difference(control, other_control)
		if extended_control_rect.intersects(other_control.get_global_rect()) \
				and center_difference.length() < nearest_distance:
			nearest_neighbour = other_control
			nearest_distance = _center_difference(control, other_control).length()
	
	return nearest_neighbour


## Finds the nearest control to the given control, searching 180° in the specified direction.
##
## The two controls can be diagonal, as long as they are in the appropriate direction.
##
## Parameters:
## 	'control': The Control node for which to find the nearest control.
##
## 	'direction': The direction vector in which to search for the nearest control.
##
## Returns:
## 	The nearest Control node in the specified direction, or 'null' if none was found.
func find_nearest_approximate(control: Control, direction: Vector2) -> Control:
	var nearest_neighbour: Control = null
	var nearest_distance := 999999
	
	for other_control in _controls:
		if other_control == control or not other_control.is_visible_in_tree():
			continue
		
		var center_difference := _center_difference(control, other_control)
		if direction.dot(center_difference.normalized()) > 0 \
				and center_difference.length() < nearest_distance:
			nearest_neighbour = other_control
			nearest_distance = center_difference.length()
	
	return nearest_neighbour


## Assigns a focus neighbour to the given control in the specified direction.
##
## Parameters:
## 	'control': The node for which to assign a focus neighbour.
##
## 	'direction': The direction vector in which to assign the focus neighbour.
func _assign_focus_neighbour(control: Control, direction: Vector2) -> void:
	var neighbour: Control
	if not neighbour:
		neighbour = find_nearest_precise(control, direction)
	if not neighbour:
		neighbour = find_nearest_approximate(control, direction)
	if not neighbour:
		neighbour = control
	var property: String = FOCUS_NEIGHBOUR_PROPERTY_BY_DIRECTION[direction]
	control.set(property, control.get_path_to(neighbour))


## Returns:
## 	The vector representing the difference in center positions between 'control1' and 'control2'.
func _center_difference(control1: Control, control2: Control) -> Vector2:
	return control2.get_global_rect().get_center() - control1.get_global_rect().get_center()
