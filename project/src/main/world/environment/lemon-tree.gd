tool
extends OverworldObstacle
## Tree which appears in the overworld for Lemony Thickets.
##
## This script randomizes the tree's appearance, and controls how it looks around and blinks.

## Animation names for the tree's lemon eyes
const LEMON_ANIMATION_NAMES := ["default-0", "default-1", "default-2"]

## An editor toggle which randomizes the tree's appearance
export (bool) var shuffle: bool setget set_shuffle

## Controls the shape of the tree's leaves. Modifying this in the editor has no effect until the scene is reloaded.
export (int) var leaf_type: int

## Controls the shape of the tree's mouth. Modifying this in the editor has no effect until the scene is reloaded.
export (int) var mouth_type: int

onready var _leaves := $Leaves
onready var _lemons := $Lemons
onready var _mouth := $Mouth

onready var _leaf_player := $LeafPlayer
onready var _lemon_player := $LemonPlayer
onready var _mouth_player := $MouthPlayer

func _ready() -> void:
	if Engine.editor_hint:
		return
	
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
	
	if Engine.editor_hint:
		if not _leaves:
			_initialize_onready_variables()
	
	# update the leaf appearance
	leaf_type = randi() % 3
	_leaves.scale.x = 1 if randf() > 0.5 else -1
	_leaf_player.play(_leaf_animation_name())
	_leaf_player.advance(0)
	_leaf_player.stop()
	
	# update the mouth appearance
	mouth_type = randi() % 5
	_mouth.scale.x = 1 if randf() > 0.5 else -1
	_mouth_player.play(_mouth_animation_name())
	_mouth_player.advance(0)
	_mouth_player.stop()
	
	# update the lemon appearance (only affects the editor)
	_lemon_player.play(Utils.rand_value(LEMON_ANIMATION_NAMES))
	_lemons.scale.x = 1 if randf() > 0.5 else -1


## Preemptively initializes onready variables to avoid null references
func _initialize_onready_variables() -> void:
	_leaves = $Leaves
	_lemons = $Lemons
	_mouth = $Mouth
	_leaf_player = $LeafPlayer
	_lemon_player = $LemonPlayer
	_mouth_player = $MouthPlayer


func _leaf_animation_name() -> String:
	return "default-%s" % [leaf_type]


func _mouth_animation_name() -> String:
	return "default-%s" % [mouth_type]


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
	player.advance(rand_range(0, player.get_current_animation_length()))


## When this timer elapses we point the tree's lemon eyes in a new direction.
func _on_LemonChangeTimer_timeout() -> void:
	var possible_animations := Utils.subtract(LEMON_ANIMATION_NAMES, [_lemon_player.current_animation])
	_play_randomly_from_middle(_lemon_player, Utils.rand_value(possible_animations))
	_lemons.scale.x = 1 if randf() > 0.5 else -1
