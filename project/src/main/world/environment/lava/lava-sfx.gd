extends Node
## Plays sound effects for Chocolava Canyon's cutscenes.

var _tween: SceneTreeTween

onready var _cheer := $Cheer

func _ready() -> void:
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")


## Fade out and stop the sound effect
func _stop_sfx(duration: float) -> void:
	if not is_inside_tree():
		# avoid errors from null tween
		return
	
	_tween = Utils.recreate_tween(self, _tween)
	_tween.set_parallel(true)
	_tween.tween_property(_cheer, "volume_db", -23.0, duration)
	_tween.tween_callback(_cheer, "stop").set_delay(duration)


## Listen for 'play_sfx' chat events and play sound effects
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"play_sfx lava_cheer":
			_tween = Utils.kill_tween(_tween)
			_cheer.volume_db = -8.0
			_cheer.play()
		"stop_sfx lava_cheer":
			_stop_sfx(1.0)


func _on_SceneTransition_fade_out_started(duration: float) -> void:
	_stop_sfx(duration * 0.5)
