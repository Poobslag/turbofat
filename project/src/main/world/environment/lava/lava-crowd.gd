tool
class_name LavaCrowd
extends OverworldObstacle
## Chocolava canyon crowd member which appears in the credits.
##
## This script randomizes the crowd member's appearance and animates them.

const BOUNCE_DURATION := 0.48780
const BOUNCE_HEIGHT := 30

## Percent of crowd members who have cheer lines over their head
const CHEER_PROBABILITY := 0.35

const CROWD_COLORS := [
	Color("3d291f"),
	Color("4c3125"),
	Color("5d3b2b"),
	Color("6c4331"),
]

export (NodePath) var gaze_target_path: NodePath setget set_gaze_target_path

## Current frame to display from the sprite sheet.
export (int) var frame: int setget set_frame

## Editor toggle which randomizes the obstacle's appearance
export (bool) var shuffle: bool setget set_shuffle

export (int, 0, 3) var crowd_color_index: int setget set_crowd_color_index

export (bool) var collision_disabled: bool = false setget set_collision_disabled

## 'true' if this crowd member should jump up and down with their arms raised.
var bouncing: bool setget set_bouncing

## Node which this crowd member should orient towards.
var _gaze_target: Node

var _tween: SceneTreeTween

onready var _sprite_holder := $SpriteHolder
onready var _sprite := $SpriteHolder/Sprite
onready var _cheer_sprite := $SpriteHolder/CheerSprite
onready var _collision_shape := $CollisionShape2D

## Timer which makes the crowd member animate slightly, alternating between two frames
onready var _wiggle_timer := $WiggleTimer

onready var _bounce_timer := $BounceTimer

func _ready() -> void:
	if Engine.editor_hint:
		# don't animate the crowd member in the editor, otherwise it randomizes the 'frame' and 'wait_time' fields
		# polluting version control
		pass
	else:
		_wiggle_timer.start(rand_range(0.0, 7.0))
	
	if not Engine.editor_hint and Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")
	
	_refresh()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


func set_collision_disabled(new_collision_disabled: bool) -> void:
	collision_disabled = new_collision_disabled
	_refresh()


func set_frame(new_frame: int) -> void:
	frame = new_frame
	_refresh()


func set_crowd_color_index(new_crowd_color_index: int) -> void:
	crowd_color_index = new_crowd_color_index
	_refresh()


func set_gaze_target_path(new_gaze_target_path: NodePath) -> void:
	gaze_target_path = new_gaze_target_path
	_refresh()


## Randomizes the obstacle's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	if not _sprite:
		_initialize_onready_variables()
	
	var crowd_member_index: int = randi() % (_sprite.hframes * _sprite.vframes / 4)
	set_frame(crowd_member_index * 4 + randi() % 2)
	set_crowd_color_index(Utils.randi_range(0, CROWD_COLORS.size() - 1))
	scale = Vector2.ONE
	
	property_list_changed_notify()


func set_bouncing(new_bouncing: bool) -> void:
	if bouncing == new_bouncing:
		return
	
	bouncing = new_bouncing
	
	_refresh_bouncing()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_sprite_holder = $SpriteHolder
	_sprite = $SpriteHolder/Sprite
	_cheer_sprite = $SpriteHolder/CheerSprite
	_wiggle_timer = $WiggleTimer
	_bounce_timer = $BounceTimer
	_collision_shape = $CollisionShape2D


## Starts/stops the crowd member bouncing based on the 'bouncing' field.
func _refresh_bouncing() -> void:
	# set the creature back on the ground
	_tween = Utils.recreate_tween(self, _tween)
	
	# calculate a randomized delay duration, so that all creatures do not bounce in sync
	var delay_duration := BOUNCE_DURATION * randf()
	
	_tween.tween_property(_sprite_holder, "position", Vector2.ZERO, delay_duration * 0.5)
	_cheer_sprite.visible = false
	_cheer_sprite.playing = false
	
	lower_arms()
	
	if bouncing:
		# make the creature start bouncing continuously, after a short randomized delay
		_bounce_timer.start(delay_duration)
	else:
		# prevent the creature from bouncing, in case a bounce was already scheduled
		_bounce_timer.stop()


## Changes to a non-bouncing (arms lowered) frame.
func lower_arms() -> void:
	# warning-ignore:integer_division
	set_frame(int(frame / 4) * 4 + frame % 2)


## Changes to a bouncing (arms raised) frame.
func raise_arms() -> void:
	# warning-ignore:integer_division
	set_frame(int(frame / 4) * 4 + 2 + frame % 2)


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	if not _sprite:
		_initialize_onready_variables()
	
	_gaze_target = get_node(gaze_target_path) if gaze_target_path else null
	_sprite.frame = frame
	_sprite.modulate = CROWD_COLORS[crowd_color_index]
	# call_deferred to avoid error: 'Can't change this state while flushing queries...'
	_collision_shape.call_deferred("set", "disabled", collision_disabled)


## When the WiggleTimer times out, we animate the crowd member slightly.
##
## Crowd members each have two frames. When the timer times out we switch to their other frame.
func _on_WiggleTimer_timeout() -> void:
	# switch the crowd member to their other frame
	if frame % 2 == 0:
		set_frame(frame + 1)
	else:
		set_frame(frame - 1)
	
	# randomly vary the wiggle timer slightly
	_wiggle_timer.start(rand_range(6.0, 7.0))


## When the BounceTimer times out, we animate the creature to bounce up and down.
func _on_BounceTimer_timeout() -> void:
	raise_arms()
	
	_cheer_sprite.visible = randf() < CHEER_PROBABILITY
	_cheer_sprite.playing = true
	
	_tween = Utils.recreate_tween(self, _tween)
	_sprite_holder.position = Vector2.ZERO
	var bounce_position := Vector2(0, -BOUNCE_HEIGHT * rand_range(0.8, 1.2))
	var bounce_duration := BOUNCE_DURATION * rand_range(0.8, 1.2)
	_tween.tween_property(_sprite_holder, "position", bounce_position, bounce_duration * 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_sprite_holder, "position", Vector2.ZERO, bounce_duration * 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.set_loops()


## Periodically orient the crowd member towards the gaze target.
func _on_GazeTimer_timeout() -> void:
	if not _gaze_target:
		return
	
	var translated_gaze_target_position: Vector2 = \
			_gaze_target.get_global_transform().origin - get_global_transform().origin
	
	if translated_gaze_target_position.x > 0:
		_sprite.flip_h = false
		_cheer_sprite.flip_h = false
		_cheer_sprite.position.x = abs(_cheer_sprite.position.x)
	elif translated_gaze_target_position.x < 0:
		_sprite.flip_h = true
		_cheer_sprite.flip_h = true
		_cheer_sprite.position.x = -abs(_cheer_sprite.position.x)


## Listen for 'lava_crowd' chat events and spawn LavaCrowd instances.
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"lava_crowd start_bouncing":
			set_bouncing(true)
		"lava_crowd stop_bouncing":
			set_bouncing(false)
