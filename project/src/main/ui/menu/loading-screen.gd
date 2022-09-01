extends Control
## Shows a progress bar while resources are loading.

onready var _wallpaper := $Wallpaper
onready var _orb := $Holder/Orb
onready var _progress_bar := $Holder/ProgressBar

func _ready() -> void:
	ResourceCache.connect("finished_loading", self, "_on_ResourceCache_finished_loading")
	ResourceCache.start_load()
	
	_orb.modulate = _wallpaper.light_color.lightened(0.5)
	_progress_bar.modulate = _orb.modulate


func _process(_delta: float) -> void:
	_progress_bar.value = ResourceCache.get_progress()


func _on_ResourceCache_finished_loading() -> void:
	SceneTransition.push_trail(Global.SCENE_SPLASH)
