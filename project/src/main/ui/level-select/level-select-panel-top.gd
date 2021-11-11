extends Control
## Shows the top portion of the level select panel, including the level buttons and cutscene button.

func _ready() -> void:
	$CutsceneButton.connect("resized", self, "_on_CutsceneButton_resized")
	_reposition_cutscene_button()


func _reposition_cutscene_button() -> void:
	$CutsceneButton.rect_position = Vector2(4, 360 - $CutsceneButton.rect_size.y)


func _on_CutsceneButton_resized() -> void:
	_reposition_cutscene_button()
