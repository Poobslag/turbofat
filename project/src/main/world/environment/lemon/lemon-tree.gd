@tool
extends OverworldObstacle
## Tree which appears in the overworld for Lemony Thickets.
##
## This script randomizes the tree's appearance, and controls how it looks around and blinks.

## Animation names for the tree's lemon eyes
const LEMON_ANIMATION_NAMES := ["default-0", "default-1", "default-2"]

## Editor toggle which randomizes the tree's appearance
@export (bool) var shuffle: bool: set = set_shuffle

## Controls the shape of the tree's leaves. Modifying this in the editor has no effect until the scene is reloaded.
## There are only three leaf shapes, odd leaf types are mirrored versions of even leaf types.
@export (int, 0, 5) var leaf_type: int: set = set_leaf_type

## Controls the shape of the tree's mouth. Modifying this in the editor has no effect until the scene is reloaded.
## There are only three mouth shapes, odd mouth types are mirrored versions of even leaf types.
@export (int, 0, 9) var mouth_type: int: set = set_mouth_type

@onready var _leaves := $Leaves
@onready var _lemons := $Lemons
@onready var _mouth := $Mouth

@onready var _leaf_player := $LeafPlayer
@onready var _lemon_player := $LemonPlayer
@onready var _mouth_player := $MouthPlayer

func _ready() -> void:
	if Engine.is_editor_hint():
		# update the tree's appearance, but don't play any animations
		_refresh_tree_in_editor()
	else:
		# launch the tree's animations
		_play_randomly_from_middle(_leaf_player, _leaf_animation_name())
		_play_randomly_from_middle(_mouth_player, _mouth_animation_name())
		
		_play_randomly_from_middle(_lemon_player, Utils.rand_value(LEMON_ANIMATION_NAMES))
		_lemons.scale.x = 1 if randf() > 0.5 else -1


## Preemptively initializes onready variables to avoid null references
func _enter_tree() -> void:
	_initialize_onready_variables()


## Randomizes the tree's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	leaf_type = randi() % 6
	mouth_type = randi() % 10
	
	_refresh_tree_in_editor()
	
	notify_property_list_changed()


func set_leaf_type(new_leaf_type: int) -> void:
	leaf_type = new_leaf_type
	
	_refresh_tree_in_editor()


func set_mouth_type(new_mouth_type: int) -> void:
	mouth_type = new_mouth_type
	
	_refresh_tree_in_editor()


## Updates the tree's appearance without animating it.
func _refresh_tree_in_editor() -> void:
	if not is_inside_tree():
		return
	
	if Engine.is_editor_hint():
		if not _leaves:
			_initialize_onready_variables()
	
	_leaves.flip_h = leaf_type % 2 == 1
	_leaf_player.play(_leaf_animation_name())
	_leaf_player.advance(0)
	_leaf_player.stop()
	
	# update the mouth appearance
	_mouth.flip_h = mouth_type % 2 == 1
	_mouth_player.play(_mouth_animation_name())
	_mouth_player.advance(0)
	_mouth_player.stop()
	
	# update the lemon appearance (only affects the editor)
	_lemon_player.play(Utils.rand_value(LEMON_ANIMATION_NAMES))
	_lemon_player.advance(0)
	_lemons.flip_h = randf() > 0.5
	_lemon_player.stop()


## Preemptively initializes onready variables to avoid null references
func _initialize_onready_variables() -> void:
	_leaves = $Leaves
	_lemons = $Lemons
	_mouth = $Mouth
	_leaf_player = $LeafPlayer
	_lemon_player = $LemonPlayer
	_mouth_player = $MouthPlayer


func _leaf_animation_name() -> String:
	# warning-ignore:integer_division
	return "default-%s" % [int(leaf_type / 2)]


func _mouth_animation_name() -> String:
	# warning-ignore:integer_division
	return "default-%s" % [int(mouth_type / 2)]


## Randomly advance the current animation up to 2.0 seconds to ensure trees don't blink in unison.
func advance_lemon_animation_randomly() -> void:
	_lemon_player.advance(randf() * 2.0)


## Play an animation from a random point of time in the middle.
##
## Parameters:
## 	'player': The AnimationPlayer whose animation is played.
##
## 	'anim_name': The name of the animation to play.
func _play_randomly_from_middle(player: AnimationPlayer, anim_name: String) -> void:
	player.play(anim_name)
	player.advance(randf_range(0, player.get_current_animation_length()))


## When this timer elapses we point the tree's lemon eyes in a new direction.
func _on_LemonChangeTimer_timeout() -> void:
	var possible_animations := Utils.subtract(LEMON_ANIMATION_NAMES, [_lemon_player.current_animation])
	_play_randomly_from_middle(_lemon_player, Utils.rand_value(possible_animations))
	_lemons.flip_h = randf() > 0.5
