class_name NightModeToggler
extends Node
## Changes the color/visibility of nodes at night.
##
## During night mode, some nodes darken to different shades of blue, some nighttime nodes are made visible, and other
## daytime nodes are made invisible. To change the color/visibility of a node at night, it must be assigned to one of
## the following groups:
##
## 	'night_mode_dark': The node and its children will become dark blue at night, and uncolored during the day
## 	'night_mode_dark_self': The node will become dark blue at night, and uncolored during the day
## 	'night_mode_invisible': The node will become invisible at night, and visible during the day
## 	'night_mode_light': The node and its children will become light blue at night, and uncolored during the day
## 	'night_mode_light_self': The node will become light blue at night, and uncolored during the day
## 	'night_mode_visible': The node will become visible at night, and invisible during the day

## Dark blue color assigned to nodes in the 'night_mode_dark' group
const DARK_BLUE := Color("6b6bdc")

## Light blue color assigned to nodes in the 'night_mode_light' group
const LIGHT_BLUE := Color("aed8d0")

## Amount of time it takes to transition from day to night, or from night to day.
const TWEEN_DURATION := 0.3

var _night_mode := false

## Adjusts node colors and visibility during day/night transitions.
var _tween: SceneTreeTween

## Nodes being tweened to transparent. After the tween completes, we set the 'visible' property on these nodes to
## 'false'.
##
## key: (Node) node being modulated to transparent
## kalue: (bool) true
var _nodes_modulated_to_transparent := {}

func _exit_tree() -> void:
	# unset night filter if it was enabled
	MusicPlayer.night_filter = false


## Transition the puzzle to day/night mode, with an accompanying visual effect.
##
## Parameters:
## 	'new_night_mode': 'true' to transition to night mode, 'false' to transition to day mode.
##
## 	'duration': (Optional) Transition duration in seconds. A value of 0.0 will transition instantly. If omitted, a
## 		default transition duration will be used.
func set_night_mode(new_night_mode: bool, duration := TWEEN_DURATION) -> void:
	if _night_mode == new_night_mode:
		return
	_night_mode = new_night_mode
	
	MusicPlayer.night_filter = _night_mode
	_start_night_tween(duration)


func is_night_mode() -> bool:
	return _night_mode


## Tweens the modulate properties of all daytime/nighttime nodes in the scene tree.
##
## This finds all nodes in the 'night_mode_...' groups and adjusts their modulate property appropriately. This usually
## involves launching a tween, although a duration of '0.0' will result in an instantaneous change without a tween.
##
## Parameters:
## 	'duration': (Optional) Transition duration in seconds. A value of 0.0 will transition instantly. If omitted, a
## 		default transition duration will be used.
func _start_night_tween(duration := TWEEN_DURATION) -> void:
	if not is_inside_tree():
		return
	_nodes_modulated_to_transparent.clear()
	if duration > 0.0:
		_tween = Utils.recreate_tween(self, _tween).set_parallel()
	
	for node in get_tree().get_nodes_in_group("night_mode_dark"):
		_tween_property(node, "modulate", DARK_BLUE if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_dark_self"):
		_tween_property(node, "self_modulate", DARK_BLUE if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_invisible"):
		if duration == 0.0 and _night_mode:
			# immediately make the node invisible
			node.visible = false
		else:
			# make the node visible and gradually tween its modulate property
			node.visible = true
		
		_tween_property(node, "modulate", Color.transparent if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_light"):
		_tween_property(node, "modulate", LIGHT_BLUE if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_light_self"):
		_tween_property(node, "self_modulate", LIGHT_BLUE if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_visible"):
		if duration == 0.0 and not _night_mode:
			# immediately make the node invisible
			node.visible = false
		else:
			# make the node visible and gradually tween its modulate property
			node.visible = true
		_tween_property(node, "modulate", Color.white if _night_mode else Color.transparent, duration)
	
	if duration == 0.0:
		_turn_modulated_nodes_invisible()
	else:
		_tween.chain().tween_callback(self, "_turn_modulated_nodes_invisible")


## Interpolates a node's property, or sets it instantly if duration is zero.
##
## Animates 'property' of 'node' from its current value to 'final_val' for 'duration' seconds. If duration is zero, the
## value is immediately set instead.
func _tween_property(node: Node, property: String, final_val, duration: float) -> void:
	if duration == 0.0:
		node.set(property, final_val)
	else:
		_tween.tween_property(node, property, final_val, duration)
	
	if property == "modulate" and final_val == Color.transparent:
		_nodes_modulated_to_transparent[node] = true


## Tweening nodes transparent makes them invisible. This method also toggles their 'visible' property to false.
func _turn_modulated_nodes_invisible() -> void:
	for node in _nodes_modulated_to_transparent:
		node.visible = false
