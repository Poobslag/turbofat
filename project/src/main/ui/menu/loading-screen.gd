extends Control
## Shows a progress bar while resources are loading.

onready var _wallpaper := $Wallpaper
onready var _orb := $Holder/Orb
onready var _progress_bar := $Holder/ProgressBar

## covers the loading screen with a dark color, and immediately fades out
onready var _fade_cover: ColorRect = $FadeCover

func _ready() -> void:
	ResourceCache.connect("finished_loading", self, "_on_ResourceCache_finished_loading")
	
	_orb.modulate = _wallpaper.light_color.lightened(0.5)
	_progress_bar.modulate = _orb.modulate
	
	var _fade_cover_tween: SceneTreeTween = create_tween()
	_fade_cover.visible = true
	_fade_cover_tween.tween_property(_fade_cover, "modulate", Utils.to_transparent(_fade_cover.color), 0.3)
	if SystemData.fast_mode:
		# immediately start loading
		ResourceCache.start_load()
	else:
		# load after the fade effect finishes
		_fade_cover_tween.tween_callback(ResourceCache, "start_load")


func _process(_delta: float) -> void:
	_progress_bar.value = ResourceCache.get_progress()


func _on_ResourceCache_finished_loading() -> void:
	var flags := {}
	if SystemData.fast_mode:
		# run faster for debug builds
		flags[SceneTransition.FLAG_FADE_OUT_DURATION] = SceneTransition.DEFAULT_FADE_OUT_DURATION * 0.5
		flags[SceneTransition.FLAG_FADE_IN_DURATION] = SceneTransition.DEFAULT_FADE_IN_DURATION * 0.5
	else:
		# This scene transition looks pretty so it's nice to draw attention to it. But we don't want every scene
		# transition to be this slow or the game will be tedious to navigate. So, we just slow it down for the loading
		# screen.
		flags[SceneTransition.FLAG_FADE_OUT_DURATION] = SceneTransition.DEFAULT_FADE_OUT_DURATION + 0.6
		flags[SceneTransition.FLAG_FADE_IN_DURATION] = SceneTransition.DEFAULT_FADE_IN_DURATION + 0.6
	SceneTransition.push_trail(Global.SCENE_SPLASH, flags)
