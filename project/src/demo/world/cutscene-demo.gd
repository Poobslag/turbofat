extends Control
"""
Demonstrates cutscenes.

The user can select and launch any cutscene, and change how fat the creatures are.
"""

func _ready() -> void:
	Breadcrumb.trail = ["res://src/demo/world/CutsceneDemo.tscn"]


func _on_StartButton_pressed() -> void:
	var cutscene_prefix := StringUtils.substring_before_last($VBoxContainer/Open/LineEdit.text, "_")
	var cutscene_index := int(StringUtils.substring_after_last($VBoxContainer/Open/LineEdit.text, "_"))
	Level.set_launched_level(cutscene_prefix)
	
	if cutscene_index >= 0 and cutscene_index < 100:
		# launch 'before level' cutscene
		Level.push_cutscene_trail(true)
	elif cutscene_index >= 100 and cutscene_index < 200:
		# launch 'after level' cutscene
		Level.level_state = Level.LevelState.AFTER
		var chat_tree := ChatLibrary.chat_tree_for_postroll(Level.launched_level_id)
		Breadcrumb.push_trail(chat_tree.cutscene_scene_path())
	else:
		push_warning("Invalid cutscene path: %s" % [$VBoxContainer/Open/LineEdit.text])


func _on_OpenFileDialog_file_selected(_path: String) -> void:
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
