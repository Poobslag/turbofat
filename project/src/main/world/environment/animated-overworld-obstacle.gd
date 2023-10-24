tool
extends OverworldObstacle
## Overworld obstacle with different animation variations in an animation player.
##
## The scene should have an AnimationPlayer with animations named 'play0, play1, play2...'. This script will play the
## chosen animation, and also has logic for randomizing the sprite's appearance.

## The obstacle's variation, which decides the animation for the AnimationPlayer.
export (int) var variant: int setget set_variant

## If true, the sprite's texture is flipped horizontally.
export (bool) var flip_h: bool setget set_flip_h

## Editor toggle which randomizes the obstacle's appearance
export (bool) var shuffle: bool setget set_shuffle

onready var _sprite := $Sprite
onready var _animation_player := $AnimationPlayer

func _ready() -> void:
	_refresh()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


func set_variant(new_variant: int) -> void:
	variant = new_variant
	_refresh()


func set_flip_h(new_flip_h: bool) -> void:
	flip_h = new_flip_h
	_refresh()


## Randomizes the obstacle's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	if Engine.editor_hint:
		if not _animation_player:
			_initialize_onready_variables()
	
	var animation_count := 0
	while _animation_player.has_animation("play%s" % [animation_count]):
		animation_count += 1
	
	set_variant(Utils.randi_range(0, animation_count - 1))
	set_flip_h(randf() < 0.5)
	scale = Vector2.ONE
	
	property_list_changed_notify()


func _initialize_onready_variables() -> void:
	_sprite = $Sprite
	_animation_player = $AnimationPlayer


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _sprite:
			_initialize_onready_variables()
	
	if Engine.editor_hint:
		# in the editor, assign the sprite to first frame of the animation, but don't let the animation keep playing
		_animation_player.play("play%s" % [variant])
		_animation_player.seek(0.01, true)
		_animation_player.stop()
	else:
		# play the animation
		_animation_player.play("play%s" % [variant])
	
	_sprite.flip_h = flip_h
