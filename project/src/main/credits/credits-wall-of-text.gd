tool
class_name CreditsWallOfText
extends Node2D
## A wall of text which appears and disappears during the credits.
##
## Note: Our properties are intended to be assigned once, and then left alone. They launch timers so setting them over
## and over when we're already running will have unusual effects.

const FADE_DURATION := 0.5

export (String) var text: String setget set_text

## Time in seconds the text remains visible before fading out.
var duration: float = 5.0 setget set_duration

var _modulate_tween: SceneTreeTween

onready var _label := $Label

## Timer which makes us disappear after a delay.
onready var _timer := $Timer

func _ready() -> void:
	_label.modulate = Color.transparent
	_refresh()


func set_duration(new_duration: float) -> void:
	duration = new_duration
	_refresh()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh()


## Updates our text and restarts our timer.
func _refresh() -> void:
	if not (is_inside_tree() and _label):
		return

	_label.text = PlayerData.creature_library.substitute_variables(text)
	_timer.start(max(duration - FADE_DURATION, 0.5))

	modulate = Color.white
	_modulate_tween = Utils.recreate_tween(self, _modulate_tween)
	_modulate_tween.tween_property(_label, "modulate", Color.white, FADE_DURATION)


## When the timer times out we fade out and queue ourselves for deletion.
func _on_Timer_timeout() -> void:
	_modulate_tween = Utils.recreate_tween(self, _modulate_tween)
	_modulate_tween.tween_property(_label, "modulate", Color.transparent, FADE_DURATION)
	_modulate_tween.tween_callback(self, "queue_free")
