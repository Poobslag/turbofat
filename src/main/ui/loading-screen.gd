extends Control
"""
Shows a progress bar while resources are loading.
"""

func _ready() -> void:
	ResourceCache.connect("finished_loading", self, "change_scene")


func _process(delta: float) -> void:
	$ProgressBar.value = 100.0 * ResourceCache.get_progress()


func change_scene() -> void:
	get_tree().change_scene("res://src/main/ui/ScenarioMenu.tscn")
