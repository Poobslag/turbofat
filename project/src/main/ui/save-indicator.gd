extends Control
## Shows a save indicator in the bottom-right corner when data is saved.

## The speed and amplitude of the bounce animation
const BOUNCE_SPEED := 0.6
const BOUNCE_AMPLITUDE := 4

## The duration the save indicator should remain visible
const DURATION := 1.5

var _tween: SceneTreeTween

onready var _sprite := $Sprite
onready var _animation_player := $AnimationPlayer

func _ready() -> void:
	_sprite.visible = false
	SystemSave.connect("before_save", self, "_on_SystemSave_before_save")
	SystemSave.connect("after_save", self, "_on_SystemSave_after_save")
	PlayerSave.connect("before_save", self, "_on_PlayerSave_before_save")
	PlayerSave.connect("after_save", self, "_on_PlayerSave_after_save")
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")


func is_playing() -> bool:
	return _tween != null


## Shows the save indicator with a 'pop in' animation.
##
## The save indicator loops continuously until "stop" is called.
func play() -> void:
	if is_playing():
		return
	
	_animation_player.play("pop_in")
	# Tween the sprite down, and schedule a continuous loop after the initial tween.
	_sprite.position.y = 20
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(_sprite, "position:y", 20 + BOUNCE_AMPLITUDE, BOUNCE_SPEED / 2.0) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_callback(self, "_schedule_looped_tween")


## Hides the save indicator with a 'pop out' animation.
func stop() -> void:
	if not is_playing():
		return
	
	_animation_player.play("pop_out")
	_tween = Utils.kill_tween(_tween)


## Tweens the sprite to loop continuously down, up, and down again.
func _schedule_looped_tween() -> void:
	_sprite.position.y = 20 + BOUNCE_AMPLITUDE
	_tween = Utils.recreate_tween(self, _tween)
	_tween.set_loops()
	_tween.tween_property(_sprite, "position:y", 20 - BOUNCE_AMPLITUDE, BOUNCE_SPEED) \
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_sprite, "position:y", 20 + BOUNCE_AMPLITUDE, BOUNCE_SPEED) \
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


## Schedules the save indicator to hide after a delay.
##
## We add a delay to ensure it's visible for a minimum amount of time.
func _schedule_stop() -> void:
	if is_inside_tree():
		get_tree().create_timer(DURATION).connect("timeout", self, "stop")


func _on_PlayerSave_before_save() -> void:
	Global.print_verbose("Player data saved; Showing save indicator")
	play()
	Global.print_verbose("Finished showing save indicator")


func _on_PlayerSave_after_save() -> void:
	Global.print_verbose("Player data saved; Hiding save indicator")
	_schedule_stop()
	Global.print_verbose("Finished hiding save indicator")


func _on_SystemSave_before_save() -> void:
	Global.print_verbose("System data saved; Showing save indicator")
	play()
	Global.print_verbose("Finished showing save indicator")


func _on_SystemSave_after_save() -> void:
	Global.print_verbose("Player data saved; Hiding save indicator")
	_schedule_stop()
	Global.print_verbose("Finished hiding save indicator")


func _on_SceneTransition_fade_out_started(_duration: float) -> void:
	if PlayerSave.save_scheduled:
		Global.print_verbose("Save scheduled; Showing save indicator")
		play()
		Global.print_verbose("Finished showing save indicator")
