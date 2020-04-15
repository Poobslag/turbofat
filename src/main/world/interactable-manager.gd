extends Node
"""
Tracks Turbo's location and the location of all interactables. Handles questions like 'which interactable is focused'
and 'which interactables are nearby'.
"""

# Signal emitted when focus changes to a new object, or when all objects are unfocused.
signal focus_changed

# Maximum range for Turbo to successfully interact with an object
const MAX_INTERACT_DISTANCE := 50.0

# The player's sprite
var _turbo: Turbo setget set_turbo

# A list of all interactable objects which can be focused and interacted with
var _interactables := []

# The currently focused object
var _focused: Spatial

"""
Purges all node instances from the manager.

Because InteractableManager is a singleton, node instances must be purged before changing scenes. Otherwise it's
possible for an invisible object from a previous scene to receive focus.
"""
func clear() -> void:
	_turbo = null
	_interactables.clear()
	_focused = null


func set_turbo(turbo: Turbo) -> void:
	_turbo = turbo


func add_interactable(interactable: Spatial) -> void:
	_interactables.append(interactable)


func _physics_process(delta: float) -> void:
	var min_distance := MAX_INTERACT_DISTANCE
	var new_focus: Spatial

	if _turbo and _interactables:
		# iterate over all interactables and find the nearest one
		for interactable_object in _interactables:
			if not interactable_object:
				continue
			var interactable: Spatial = interactable_object
			var distance = interactable.global_transform.origin.distance_to(_turbo.global_transform.origin)
			if distance <= min_distance:
				min_distance = distance
				new_focus = interactable
	
	if new_focus != _focused:
		_focused = new_focus
		emit_signal("focus_changed", new_focus)
