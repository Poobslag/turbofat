tool
class_name CreditsLine
extends Node2D
## A line which scrolls vertically during the credits.
##
## This line usually includes text, but might include graphics too.

export (NodePath) var fade_in_point_path: NodePath setget set_fade_in_point_path
export (NodePath) var fade_out_point_path: NodePath setget set_fade_out_point_path

## Height in units. Used for calculating the scroll speed.
export (float) var line_height: float

var velocity := Vector2(0, -50)

## A point near the top of the screen where lines fade out.
onready var fade_out_point: Node2D
## A point near the bottom of the screen where lines fade in.
onready var fade_in_point: Node2D

func _ready() -> void:
	add_to_group("credits_lines")
	_refresh_fade_point_path()
	modulate = Color.transparent


func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	position += velocity * delta
	
	# Fade in or out based on our proximity to fade_out_point and fade_in_point
	var fade_out_factor: float = lerp(0.0, 1.0, clamp(
		global_position.y / Credits.FADE_RANGE - fade_out_point.global_position.y / Credits.FADE_RANGE, 0.0, 1.0))
	var fade_in_factor: float = lerp(0.0, 1.0, clamp(
		fade_in_point.global_position.y / Credits.FADE_RANGE - global_position.y / Credits.FADE_RANGE, 0.0, 1.0))
	modulate.a = min(fade_out_factor, fade_in_factor)
	
	## We wait to free credit lines until they're way off the top of the screen. We could usually free them earlier
	## than this, but the fade_out_point is dynamic and can cause invisible credit lines to fade back in.
	if global_position.y < -50.0:
		queue_free()


func set_fade_in_point_path(new_fade_in_point_path: NodePath) -> void:
	fade_in_point_path = new_fade_in_point_path
	_refresh_fade_point_path()


func set_fade_out_point_path(new_fade_out_point_path: NodePath) -> void:
	fade_out_point_path = new_fade_out_point_path
	_refresh_fade_point_path()


func _refresh_fade_point_path() -> void:
	if not is_inside_tree():
		return
	
	fade_in_point = get_node(fade_in_point_path) if fade_in_point_path else null
	fade_out_point = get_node(fade_out_point_path) if fade_out_point_path else null
