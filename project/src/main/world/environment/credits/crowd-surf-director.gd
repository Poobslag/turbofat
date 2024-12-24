class_name CrowdSurfDirector
extends Node
## Orchestrates a unique cutscene where the player and Fat Sensei crowd surf on a cheering crowd.

## Emitted when creatures are moved to their starting positions for the cutscene.
signal played

## Emitted when the cutscenes animations are stopped.
signal stopped

export (NodePath) var player_path: NodePath
export (NodePath) var sensei_path: NodePath

## key: (Node2D) node whose position should be initialized
## value: (Vector2) initial position
var _initial_positions_by_node: Dictionary

onready var _player: CrowdSurfingBuddy = get_node(player_path)
onready var _sensei: CrowdSurfingBuddy = get_node(sensei_path)

func _ready() -> void:
	_save_initial_positions()


## Moves all creatures to their starting positions, and schedules the cutscene events.
func play() -> void:
	_load_initial_positions()
	
	_player.play_bounce_animation()
	_sensei.play_bounce_animation()
	
	emit_signal("played")


## Stops any cutscene animations.
func stop() -> void:
	_player.stop()
	_sensei.stop()
	emit_signal("stopped")


## Saves all creature positions to _initial_positions_by_node
func _save_initial_positions() -> void:
	if not is_inside_tree():
		return
	var repositionable_nodes := []
	repositionable_nodes.append(_player)
	repositionable_nodes.append(_sensei)
	for crowd in get_tree().get_nodes_in_group("recyclable_crowds"):
		repositionable_nodes.append(crowd)
	
	for node in repositionable_nodes:
		_initial_positions_by_node[node] = node.position


## Initializes all creature positions from _initial_positions_by_node
func _load_initial_positions() -> void:
	for node in _initial_positions_by_node.keys():
		node.position = _initial_positions_by_node[node]
