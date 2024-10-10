extends Control
## Renders a blue glow in front of candy buttons when they have focus.

## Parameters for the pulsing effect of the blue glow.
const OPACITY_MIN := 0.16
const OPACITY_MAX := 0.36
const SCALE_MIN := 0.98
const SCALE_MAX := 1.12
const ANIMATION_DURATION := 1.2

var _tween: SceneTreeTween = null

onready var _sprite := $Sprite
onready var _parent := get_parent()

func _ready() -> void:
	_parent.connect("focus_entered", self, "_on_CandyButton_focus_entered")
	_parent.connect("focus_exited", self, "_on_CandyButton_focus_exited")
	_refresh()


## Can be overridden by child classes to support candy buttons with unusual sizes.
func get_button_size() -> Vector2:
	return _parent.rect_size


func _refresh() -> void:
	if _parent.has_focus():
		_start_glow_animation()
	else:
		_stop_glow_animation()


## Shows the glow sprite and starts a looped glow animation.
func _start_glow_animation() -> void:
	_sprite.visible = true
	_sprite.scale = SCALE_MIN * (get_button_size() / 135.0)
	_sprite.modulate.a = 0.0
	
	_tween = Utils.recreate_tween(self, _tween)
	_tween.set_loops()
	_tween.tween_property(_sprite, "scale", SCALE_MAX * (get_button_size() / 135.0), ANIMATION_DURATION) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.parallel().tween_property(_sprite, "modulate:a", OPACITY_MAX, ANIMATION_DURATION) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	_tween.tween_property(_sprite, "scale", SCALE_MIN * (get_button_size() / 135.0), ANIMATION_DURATION) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.parallel().tween_property(_sprite, "modulate:a", OPACITY_MIN, ANIMATION_DURATION) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Hides the glow sprite and stops the animation.
func _stop_glow_animation() -> void:
	_tween = Utils.kill_tween(_tween)
	_sprite.visible = false
	_sprite.scale = get_button_size() / 135.0


func _on_CandyButton_focus_entered() -> void:
	_refresh()


func _on_CandyButton_focus_exited() -> void:
	_refresh()
