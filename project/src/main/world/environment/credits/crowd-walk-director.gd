class_name CrowdWalkDirector
extends Node
## Orchestrates a unique cutscene where the player and Fat Sensei walk through a cheering crowd.
##
## Arranges nodes and schedules events to synchronize the cutscene with the music.

## Emitted when creatures are moved to their starting positions for the cutscene.
signal played

## Emitted when the cutscenes animations are stopped.
signal stopped

## Number in the range [0.0, 1.0] for how many creatures should jump up and down with their arms raised.
export (float, 0.0, 1.0) var bouncing_crowd_percent := 0.0 setget set_bouncing_crowd_percent

export (NodePath) var player_path: NodePath
export (NodePath) var sensei_path: NodePath
export (NodePath) var destination_path: NodePath

var _tween: SceneTreeTween

## key: (Node2D) node whose position should be initialized
## value: (Vector2) initial position
var _initial_positions_by_node: Dictionary

onready var _animation_player := $AnimationPlayer
onready var _player: WalkingBuddy = get_node(player_path)
onready var _sensei: WalkingBuddy = get_node(sensei_path)

## Location where which the player and Fat Sensei run towards. This also decides the starting position for creatures in
## the scene.
onready var _destination: Node2D = get_node(destination_path)

func _ready() -> void:
	_refresh_bouncing_crowd_percent()
	_save_initial_positions()


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


## Moves all creatures to their starting positions, and schedules the cutscene events.
##
## The starting positions are calculated by taking the destination, calculating how far the player and Fat Sensei can
## run in the alotted time, and placing all creatures that far from the destination.
func play(time_until_launch: float) -> void:
	var look_around_duration := min(time_until_launch / 0.5, 1.5)
	
	# reset the player and fat sensei to an appropriate elevation, in case they were midair
	_animation_player.play("RESET")
	set_bouncing_crowd_percent(0.9)
	_player.elevation = 0
	_sensei.elevation = 0
	_player.start_walking()
	_sensei.start_walking()
	
	# calculate the slowest of player's speed, and fat sensei's speed
	var min_speed := min(_player.get_run_speed(), _sensei.get_run_speed())
	
	# calculate the center position (within reason)
	var run_velocity := min_speed * Vector2(-0.7071, 0.7071)
	var run_duration := max(0.5, time_until_launch - look_around_duration - 0.25)
	var new_center_position := _destination.position - run_duration * run_velocity
	var distance_to_move_everyone := Global.to_iso(
			(new_center_position.x - _initial_positions_by_node[_player].x) * Vector2(1, -1))
	
	# reposition the player, fat sensei, the crowds and so that they'll run the appropriate distance
	_load_initial_positions()
	for node in _initial_positions_by_node:
		node.position += distance_to_move_everyone
	
	# crowd gradually becomes calmer, until they toss the player and sensei into the air
	_tween = Utils.recreate_tween(self, _tween).set_parallel(true)
	_tween.tween_callback(self, "set_bouncing_crowd_percent", [0.9]).set_delay(time_until_launch * 0.3)
	_tween.tween_callback(self, "set_bouncing_crowd_percent", [0.7]).set_delay(time_until_launch * 0.4)
	_tween.tween_callback(self, "set_bouncing_crowd_percent", [0.5]).set_delay(time_until_launch * 0.5)
	_tween.tween_callback(self, "set_bouncing_crowd_percent", [0.3]).set_delay(time_until_launch * 0.6)
	_tween.tween_callback(self, "set_bouncing_crowd_percent", [0.1]).set_delay(time_until_launch * 0.7)
	_tween.tween_callback(self, "set_bouncing_crowd_percent", [0.0]).set_delay(time_until_launch * 0.8)
	
	# fat sensei and the player look around, and then are launched into the air
	_tween.tween_callback(_animation_player, "play", ["look_around"]) \
			.set_delay(time_until_launch - look_around_duration)
	_tween.tween_callback(_animation_player, "play", ["launch"]).set_delay(time_until_launch)
	_tween.tween_callback(self, "crowd_launch").set_delay(time_until_launch)
	
	emit_signal("played")


## Stops any cutscene animations.
func stop() -> void:
	_player.stop_walking()
	_sensei.stop_walking()
	_animation_player.stop()
	_tween = Utils.kill_tween(_tween)
	emit_signal("stopped")


func set_bouncing_crowd_percent(new_bouncing_crowd_percent: float) -> void:
	bouncing_crowd_percent = new_bouncing_crowd_percent
	
	_refresh_bouncing_crowd_percent()


## Makes all crowdies jump up and down with their arms raised.
func crowd_launch() -> void:
	if not is_inside_tree():
		return
	for crowd in get_tree().get_nodes_in_group("lava_crowdies"):
		crowd.bouncing = true
		crowd.raise_arms()


## Updates the number of crowdies who jump up and down with their arms raised.
func _refresh_bouncing_crowd_percent() -> void:
	if not is_inside_tree():
		return
	
	var bouncing_crowd_count := 0
	var total_crowd_count := 0
	
	for crowd in get_tree().get_nodes_in_group("lava_crowdies"):
		total_crowd_count += 1
		if crowd.bouncing:
			bouncing_crowd_count += 1
	
	var desired_bouncing_crowd_count := ceil(bouncing_crowd_percent * total_crowd_count)
	
	if desired_bouncing_crowd_count > bouncing_crowd_count:
		_toggle_bouncing(desired_bouncing_crowd_count - bouncing_crowd_count, true)
	if bouncing_crowd_count > desired_bouncing_crowd_count:
		_toggle_bouncing(bouncing_crowd_count - desired_bouncing_crowd_count, false)


## Changes a specific number of crowdies to start or stop jumping up and down.
##
## Parameters:
## 	'count': The number of crowdies to toggle
##
## 	'new_bouncing': True if the crowdies should start jumping up and down, false if they should stop.
func _toggle_bouncing(count: int, new_bouncing: bool) -> void:
	if not is_inside_tree():
		return
	if count == 0:
		return
	
	var remaining_toggle_count := count
	var lava_crowdies := get_tree().get_nodes_in_group("lava_crowdies")
	lava_crowdies.shuffle()
	
	for crowd in lava_crowdies:
		if crowd.bouncing != new_bouncing:
			crowd.bouncing = new_bouncing
			remaining_toggle_count -= 1
		if remaining_toggle_count <= 0:
			break
