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
var _focused: Spatial setget ,get_focused

# 'false' if the player is temporarily disallowed from interacting with nearby objects, such as while chatting
var _focus_enabled := true setget set_focus_enabled, is_focus_enabled

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


func get_focused() -> Spatial:
	return _focused


func is_focused(interactable: Spatial) -> bool:
	return interactable == _focused


"""
Globally enables/disables focus for nearby objects.

Regardless of whether or not the focused object changed, this notifies all listeners with a 'focus_changed' event.
This is because some UI elements render themselves differently during chats when the player can't interact with
anything.
"""
func set_focus_enabled(focus_enabled: bool) -> void:
	_focus_enabled = focus_enabled
	
	if not _focus_enabled:
		_focused = null
		# when focus is globally disabled, chat icons vanish. emit a signal to notify listeners
		emit_signal("focus_changed")


func is_focus_enabled() -> bool:
	return _focus_enabled


func _physics_process(_delta: float) -> void:
	var min_distance := MAX_INTERACT_DISTANCE
	var new_focus: Spatial

	if _focus_enabled and _turbo and _interactables:
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
		emit_signal("focus_changed")
