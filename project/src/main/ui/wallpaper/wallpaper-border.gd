class_name WallpaperBorder
extends Control
## Wavy border which separates two solid colored sections of wallpaper.
##
## TextureRects can't scale their textures unless the control itself is scaled. However, scaled controls wreak havoc
## with Godot's layout manager. To reconcile this, WallpaperBorder is an unscaled control which contains a scaled
## TextureRect.

## size in pixels of the source wallpaper texture. this texture is scaled to the dimensions of the border.
const TEXTURE_SIZE := Vector2(512, 512)

## scroll velocity. only the x component is used
@export var velocity: Vector2

## desired width and height of the border.
## a value of [200, 50] means that the texture will be 200 pixels wide and 50 pixels high.
@export var texture_scale: Vector2 = Vector2(512.0, 512.0): set = set_texture_scale

@onready var _texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	connect("resized", Callable(self, "_on_resized"))
	_recalculate_texture_rect_size()


func _physics_process(delta: float) -> void:
	_texture_rect.position += delta * velocity
	_texture_rect.position.x = wrapf(_texture_rect.position.x,
			-TEXTURE_SIZE.x * _texture_rect.scale.x, 0)


func set_texture_scale(new_texture_scale: Vector2) -> void:
	texture_scale = new_texture_scale
	_recalculate_texture_rect_size()


## Assigns the two colors used for this border.
func set_gradient_colors(color_0: Color, color_1: Color) -> void:
	var shader_material: ShaderMaterial = _texture_rect.material
	var gradient_texture: GradientTexture2D = shader_material.get("shader_parameter/gradient")
	gradient_texture.gradient.colors[0] = color_0
	gradient_texture.gradient.colors[1] = color_1


## Updates the TextureRect's size and scale.
##
## The scale is adjusted so that the texture is tiled with the correct dimensions. The size is adjusted so that the
## TextureRect occupies the full width and height necessary
func _recalculate_texture_rect_size() -> void:
	if not is_inside_tree():
		return
	
	_texture_rect.scale = texture_scale / TEXTURE_SIZE
	_texture_rect.size.x = (size.x + TEXTURE_SIZE.x) / _texture_rect.scale.x
	_texture_rect.size.y = TEXTURE_SIZE.y


func _on_resized() -> void:
	_recalculate_texture_rect_size()
