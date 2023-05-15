extends Node
## Displays FPS for various numbers of packed sprites.
##
## Godot has no way of handling packed sprites, but there are many different plugins and ad-hoc solutions for it. This
## stress test is useful for comparing them to determine which is most performant. It is not specific to Sprites or
## AnimatedSprites, and will work with any Node2D.

## how long we're willing to block a thread to add more sprites
const CHUNK_SECONDS := 0.01

## Node2D scene to test
@export (PackedScene) var SpriteScene: PackedScene

@onready var _sprite_container := $SpriteContainer
@onready var _count := $Ui/Control/Count

## desired number of sprites to show
var _target_sprite_count := 10

func _physics_process(_delta: float) -> void:
	var start_msec := Time.get_ticks_msec()
	while _sprite_container.get_child_count() != _target_sprite_count \
			and Time.get_ticks_msec() < start_msec + 1000 * CHUNK_SECONDS:
		if _sprite_container.get_child_count() < _target_sprite_count:
			_add_sprite()
		elif _sprite_container.get_child_count() > _target_sprite_count:
			_remove_sprite()
	_count.text = StringUtils.comma_sep(_sprite_container.get_child_count())


## Adds a Node2D to the test, increasing the load on the system.
func _add_sprite() -> void:
	var new_child: Node2D = SpriteScene.instantiate()
	new_child.position.x = randf_range(0, Global.window_size.x)
	new_child.position.y = randf_range(0, Global.window_size.y)
	_sprite_container.add_child(new_child)


## Removes a Node2D from the test, decreasing the load on the system.
func _remove_sprite() -> void:
	var child: Node2D = _sprite_container.get_children().back()
	_sprite_container.remove_child(child)
	child.queue_free()


func _on_Times2_pressed() -> void:
	_target_sprite_count *= 2


func _on_PlusTen_pressed() -> void:
	_target_sprite_count += 10


func _on_MinusTen_pressed() -> void:
	_target_sprite_count -= 10


func _on_Divide2_pressed() -> void:
	_target_sprite_count /= 2
