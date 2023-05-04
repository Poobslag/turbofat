class_name Carrot
extends Node2D
## A puzzle critter which rockets up the screen, blocking the player's vision.
##
## Carrots remain onscreen for several seconds. They have many different sizes, and can also leave behind a smokescreen
## which blocks the player's vision for even longer.

## Emitted when the carrot starts its 'hide' animation, indicating it will soon be freed.
signal started_hiding

## Duration in seconds it takes for the carrot's show animation.
const SHOW_DURATION := 0.20

## Duration in seconds it takes for the carrot's hide animation.
const HIDE_DURATION := 0.16

## When hiding, the carrots distort and become very thin. This is the resulting scale factor.
const HIDE_SCALE := Vector2(0.1, 2.0)

## Carrots have multiple facial animations. The first animations in this array are normal looking and appear more
## frequent. The last animations in this array are crazier and appear less frequently.
const FACE_ANIMATIONS := ["face-1", "face-2", "face-3", "face-4", "face-5", "face-6", "face-7", "face-8", "face-9"]

## CarrotVisuals scenes for each carrot size.
@export var carrot_visuals_by_size: Array[PackedScene]

## If 'true', the carrot will not be queued when hidden. Used for demos and testing.
@export var suppress_queue_free: bool = false

## Enum from CarrotConfig.Smoke for the size of the carrot's smoke cloud.
var smoke := CarrotConfig.Smoke.SMALL: set = set_smoke

## Enum from CarrotConfig.CarrotSize for the size of the carrot sprite.
var carrot_size := CarrotConfig.CarrotSize.MEDIUM: set = set_carrot_size

## 'true' if hide() has been called and the carrot will soon be freed.
var hiding := false

## Turns the carrot a solid color. Used to turn the carrot solid white during the show animation.
var _mix_color: Color = Color.TRANSPARENT: set = set_mix_color

## Handles the show/hide animations.
@onready var _show_tween: Tween

## Moves the carrot to the top of the screen.
@onready var _move_tween: Tween

## Stores details about the carrot's visuals, such as which sprites to use and the smoke location.
@onready var _visuals: Node2D = $Visuals

## Carrot's face sprite. This is distinct from the back sprite.
@onready var _face: Sprite2D = $Visuals/Face

## Material shared between the carrot's back sprite and face sprite.
@onready var _sprite_material: Material = $Visuals/Sprite2D.material

## Smoke particles.
@onready var _particles_2d: GPUParticles2D = $GPUParticles2D

## Timer which makes the carrot free itself from memory.
@onready var _free_timer := $FreeTimer

## AnimationPlayer which toggles the face sprite's frames.
@onready var _face_animation_player := $FaceAnimationPlayer

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_refresh_mix_color()
	_refresh_smoke()
	_refresh_carrot_size()
	show_carrot()


func set_smoke(new_smoke: CarrotConfig.Smoke) -> void:
	smoke = new_smoke
	_refresh_smoke()


func set_mix_color(new_mix_color: Color) -> void:
	_mix_color = new_mix_color
	_refresh_mix_color()


func set_carrot_size(new_carrot_size: CarrotConfig.CarrotSize) -> void:
	carrot_size = new_carrot_size
	_refresh_carrot_size()


## Makes the carrot appear.
##
## Blinks the carrot into view with an animation.
func show_carrot() -> void:
	_visuals.modulate = Color.TRANSPARENT
	_mix_color = Color.WHITE
	_visuals.scale = HIDE_SCALE
	
	_show_tween = Utils.recreate_tween(self, _show_tween).set_parallel()
	_show_tween.tween_property(_visuals, "modulate", Color.WHITE,
			SHOW_DURATION)
	_show_tween.tween_property(self, "_mix_color", Color.TRANSPARENT,
			SHOW_DURATION * 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_show_tween.tween_property(_visuals, "scale", Vector2.ONE,
			SHOW_DURATION)


## Makes the carrot disappear, and schedules it to free itself from memory.
##
## Blinks the carrot out of view with an animation. Once the animation completes, the carrot waits a few seconds and
## frees itself from memory.
func hide_carrot() -> void:
	hiding = true
	emit_signal("started_hiding")
	
	_show_tween = Utils.recreate_tween(self, _show_tween).set_parallel()
	_show_tween.tween_property(_visuals, "modulate", Color.TRANSPARENT, HIDE_DURATION)
	_show_tween.tween_property(_visuals, "scale", HIDE_SCALE, HIDE_DURATION)
	_show_tween.chain().tween_callback(Callable(self, "_on_Tween_hide_completed"))


## Moves the carrot to the specified location (somewhere near the top of the screen.)
##
## Parameters:
## 	'destination': The target position in pixels.
##
## 	'duration': The duration in seconds to travel toward the destination.
func launch(destination: Vector2, duration: float) -> void:
	_move_tween = Utils.recreate_tween(self, _move_tween)
	_move_tween.tween_property(self, "position", destination, duration)
	## When the carrot reaches its destination, we hide it.
	_move_tween.chain().tween_callback(Callable(self, "hide_carrot"))


## Updates the shader parameters based on our 'mix_color' property.
func _refresh_mix_color() -> void:
	if not is_inside_tree():
		return
	
	_sprite_material.set_shader_parameter("mix_color", _mix_color)


## Updates the smoke Particles2D based on our 'smoke' property.
func _refresh_smoke() -> void:
	if not is_inside_tree():
		return
	
	_particles_2d.emitting = smoke != CarrotConfig.Smoke.NONE
	
	match smoke:
		CarrotConfig.Smoke.NONE:
			_particles_2d.amount = 1
		CarrotConfig.Smoke.SMALL:
			_particles_2d.amount = 9
			_particles_2d.lifetime = 0.4
			_particles_2d.process_material.scale_max = 1.00 * scale.x
			_particles_2d.process_material.scale_min = _particles_2d.process_material.scale_max
		CarrotConfig.Smoke.MEDIUM:
			_particles_2d.amount = 64
			_particles_2d.lifetime = 2.5
			_particles_2d.process_material.scale_max = 1.25 * scale.x
			_particles_2d.process_material.scale_min = _particles_2d.process_material.scale_max
		CarrotConfig.Smoke.LARGE:
			_particles_2d.amount = 128
			_particles_2d.lifetime = 5.0
			_particles_2d.process_material.scale_max = 1.50 * scale.x
			_particles_2d.process_material.scale_min = _particles_2d.process_material.scale_max


## Updates our Sprites and our Particles2D position based on our 'carrot_size' property.
func _refresh_carrot_size() -> void:
	if not is_inside_tree():
		return
	
	# remove the old visuals node
	var old_visuals_index := _visuals.get_index()
	_visuals.queue_free()
	remove_child(_visuals)
	
	# add the new visuals node to the same location in the tree
	var new_visuals_scene: PackedScene = carrot_visuals_by_size[carrot_size]
	_visuals = new_visuals_scene.instantiate()
	_face = _visuals.get_node("Face")
	_sprite_material = _visuals.get_node("Sprite2D").material
	add_child(_visuals)
	move_child(_visuals, old_visuals_index)
	
	# move the particles to the smoke hook position
	var smoke_hook: Node2D =  _visuals.get_node("SmokeHook")
	_particles_2d.position = smoke_hook.position + _visuals.position
	
	_randomize_face()


## Plays a random face animation.
##
## This face animation is played when the carrot appears and loops forever. It decides the carrot's facial expression.
func _randomize_face() -> void:
	if randf() > 0.5:
		_face.flip_h = true
	
	# Choose a random face animation, weighting towards the earlier animations. The later animations are wacky and
	# should only come up once in a while.
	var face_animation_index := int(min(
		randf_range(0, FACE_ANIMATIONS.size()),
		randf_range(0, FACE_ANIMATIONS.size())))
	var face_animation: String = FACE_ANIMATIONS[face_animation_index]
	
	_face_animation_player.play(face_animation)


## After the carrot's 'hide' animation completes, we wait for the smoke particles to fade out and then free it.
func _on_Tween_hide_completed() -> void:
	_particles_2d.emitting = false
	_free_timer.start(_particles_2d.lifetime)


## When the FreeTimer elapses, we free the carrot from memory.
##
## The suppress_queue_free flag is used in demos to prevent the carrot from freeing itself.
func _on_FreeTimer_timeout() -> void:
	if not suppress_queue_free:
		queue_free()
