extends Control
"""
Demonstrates cutscenes.

The user can select and launch any cutscene, and change how fat the creatures are.
"""

func _ready() -> void:
	Breadcrumb.trail = ["res://src/demo/world/CutsceneDemo.tscn"]


func _on_StartButton_pressed() -> void:
	Level.set_launched_level($VBoxContainer/Open/LineEdit.text)
	Level.push_cutscene_trail(true)


func _on_OpenFileDialog_file_selected(path: String) -> void:
	var full_path: String = $Dialogs/OpenFile.current_path
	if full_path.begins_with("res://assets/main/puzzle/levels/cutscenes/") and full_path.ends_with(".json"):
		full_path = full_path.trim_prefix("res://assets/main/puzzle/levels/cutscenes/")
		full_path = full_path.trim_suffix(".json").replace("-", "_")
		$VBoxContainer/Open/LineEdit.text = full_path
	else:
		$Dialogs/Error.dialog_text = "%s doesn't seem like the path to a cutscene file." % [full_path]
		$Dialogs/Error.popup_centered()


func _on_OpenButton_pressed() -> void:
	$Dialogs/OpenFile.popup_centered()
