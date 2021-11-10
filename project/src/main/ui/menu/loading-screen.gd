extends Control
## Shows a progress bar while resources are loading.

onready var _progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	ResourceCache.connect("finished_loading", self, "_on_ResourceCache_finished_loading")
	ResourceCache.start_load()


func _process(_delta: float) -> void:
	_progress_bar.value = 100.0 * ResourceCache.get_progress()


func _on_ResourceCache_finished_loading() -> void:
	SceneTransition.push_trail(Global.SCENE_SPLASH)
