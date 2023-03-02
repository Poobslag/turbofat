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

## A dark blue color assigned to nodes in the 'night_mode_dark' group
const DARK_BLUE := Color("6b6bdc")

## A light blue color assigned to nodes in the 'night_mode_light' group
const LIGHT_BLUE := Color("aed8d0")

## The amount of time it takes to transition from day to night, or from night to day.
const TWEEN_DURATION := 0.3

var _night_mode := false

## Adjusts node colors and visibility during day/night transitions.
onready var _tween := $Tween

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


## Tweens the modulate properties of all daytime/nighttime nodes in the scene tree.
##
## This finds all nodes in the 'night_mode_...' groups and adjusts their modulate property appropriately. This usually
## involves launching a tween, although a duration of '0.0' will result in an instantaneous change without a tween.
##
## Parameters:
## 	'duration': (Optional) Transition duration in seconds. A value of 0.0 will transition instantly. If omitted, a
## 		default transition duration will be used.
func _start_night_tween(duration := TWEEN_DURATION) -> void:
	_tween.remove_all()
	
	for node in get_tree().get_nodes_in_group("night_mode_dark"):
		_interpolate_property(node, "modulate", DARK_BLUE if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_dark_self"):
		_interpolate_property(node, "self_modulate", DARK_BLUE if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_invisible"):
		if duration == 0.0 and _night_mode:
			# immediately make the node invisible
			node.visible = false
		else:
			# make the node visible and gradually tween its modulate property
			node.visible = true
		
		_interpolate_property(node, "modulate", Color.transparent if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_light"):
		_interpolate_property(node, "modulate", LIGHT_BLUE if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_light_self"):
		_interpolate_property(node, "self_modulate", LIGHT_BLUE if _night_mode else Color.white, duration)
	
	for node in get_tree().get_nodes_in_group("night_mode_visible"):
		if duration == 0.0 and not _night_mode:
			# immediately make the node invisible
			node.visible = false
		else:
			# make the node visible and gradually tween its modulate property
			node.visible = true
		_interpolate_property(node, "modulate", Color.white if _night_mode else Color.transparent, duration)
	
	if duration > 0.0:
		_tween.start()


## Interpolates a node's property, or sets it instantly if duration is zero.
##
## Animates 'property' of 'node' from its current value to 'final_val' for 'duration' seconds. If duration is zero, the
## value is immediately set instead.
func _interpolate_property(node: Node, property: String, final_val, duration: float) -> void:
	if duration == 0.0:
		node.set(property, final_val)
	else:
		_tween.interpolate_property(node, property, null, final_val, duration)


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	if key == ":modulate" and object.modulate == Color.transparent:
		object.visible = false
