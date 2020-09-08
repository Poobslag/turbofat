extends Control
"""
Emits signals as the player interacts with creatures in the creature editor.
"""

# how far away you can click and still trigger an event
const MAX_MOUSE_DISTANCE := 120

# emitted when the player moves their mouse over a new creature
signal hovered_creature_changed(value)

signal creature_clicked(value)

# cache the list of creatures; we don't want to call `get_nodes_in_group` every frame for mouseover events
onready var creatures: Array = get_tree().get_nodes_in_group("creatures")

var hovered_creature: Creature setget set_hovered_creature

func _input(event: InputEvent) -> void:
	if not event is InputEventMouse: return
	if not get_rect().has_point(event.position): return
	
	if event is InputEventMouseButton and event.button_mask & BUTTON_LEFT:
		# mouse click; select the nearest creature
		var mouse_event: InputEventMouseButton = event
		var closest_creature := _find_closest_creature(mouse_event.position)
		if closest_creature:
			$ClickSound.play()
			emit_signal("creature_clicked", closest_creature)
	
	if event is InputEventMouseMotion:
		# mouse motion; update the currently hovered creature
		var mouse_event: InputEventMouseMotion = event
		var closest_creature := _find_closest_creature(mouse_event.position)
		if hovered_creature != closest_creature:
			set_hovered_creature(closest_creature)


"""
Changes the hovered creature (the creature beneath the mouse)
"""
func set_hovered_creature(new_hovered_creature: Creature) -> void:
	hovered_creature = new_hovered_creature
	if hovered_creature:
		_set_all_creature_alpha(0.5)
		_set_creature_alpha(hovered_creature, 1.0)
		$HoverSound.play()
	else:
		_set_all_creature_alpha(1.0)
	emit_signal("hovered_creature_changed", hovered_creature)


"""
Finds the creature closest to the mouse.
"""
func _find_closest_creature(mouse_event_position: Vector2) -> Creature:
	var closest_creature: Creature
	var closest_distance := MAX_MOUSE_DISTANCE
	for creature_obj in creatures:
		var creature: Creature = creature_obj
		var distance := _distance_to_mouse(creature, mouse_event_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_creature = creature
	return closest_creature


func _distance_to_mouse(creature: Creature, mouse_event_position: Vector2) -> float:
	return (creature.position - Vector2(0, 30) * creature.scale).distance_to(mouse_event_position)


func _set_all_creature_alpha(alpha: float) -> void:
	for creature in creatures:
		_set_creature_alpha(creature, alpha)


func _set_creature_alpha(creature: Creature, alpha: float) -> void:
	creature.modulate.a = alpha


func _on_mouse_exited() -> void:
	_set_all_creature_alpha(1.0)
