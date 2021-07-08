extends Control
"""
Demonstrates cutscenes.

The user can select and launch any cutscene, and change how fat the creatures are.
"""

# property keys to use when saving/loading data
const SAVE_KEY_FLAGS := "cutscene-demo.flags"
const SAVE_KEY_OPEN := "cutscene-demo.open"

onready var _demo_save := $DemoSave
onready var _flags_input := $Input/Flags
onready var _open_input := $Input/Open
onready var _start_button := $Input/StartButton
onready var _error_dialog := $Dialogs/Error
onready var _open_dialog := $Dialogs/OpenFile

func _ready() -> void:
	_load_demo_data()
	Breadcrumb.trail = ["res://src/demo/world/CutsceneDemo.tscn"]
	_start_button.grab_focus()


func _load_demo_data() -> void:
	if _demo_save.demo_data.has(SAVE_KEY_FLAGS):
		_flags_input.value = _demo_save.demo_data[SAVE_KEY_FLAGS]
	if _demo_save.demo_data.has(SAVE_KEY_OPEN):
		_open_input.value = _demo_save.demo_data[SAVE_KEY_OPEN]


func _save_demo_data() -> void:
	_demo_save.demo_data[SAVE_KEY_FLAGS] = _flags_input.value
	_demo_save.demo_data[SAVE_KEY_OPEN] = _open_input.value
	_demo_save.save_demo_data()


func _on_StartButton_pressed() -> void:
	_save_demo_data()
	_flags_input.apply_flags()
	
	var cutscene_prefix := StringUtils.substring_before_last(_open_input.value, "_")
	var cutscene_index := int(StringUtils.substring_after_last(_open_input.value, "_"))
	CurrentLevel.set_launched_level(cutscene_prefix)
	CurrentLevel.cutscene_force = true
	
	if cutscene_index >= 0 and cutscene_index < 100:
		# launch 'before level' cutscene
		CurrentLevel.push_preroll_trail(true)
	elif cutscene_index >= 100 and cutscene_index < 200:
		# launch 'after level' cutscene
		CurrentLevel.cutscene_state = CurrentLevel.CutsceneState.AFTER
		var chat_tree := ChatLibrary.chat_tree_for_postroll(CurrentLevel.level_id)
		SceneTransition.push_trail(chat_tree.cutscene_scene_path())
	else:
		push_warning("Invalid cutscene path: %s" % [_open_input.value])


func _on_OpenFileDialog_file_selected(_path: String) -> void:
	var full_path: String = _open_dialog.current_path
	if full_path.begins_with("res://assets/main/puzzle/levels/cutscenes/") \
			and full_path.ends_with(ChatLibrary.CHAT_EXTENSION):
		full_path = full_path.trim_prefix("res://assets/main/puzzle/levels/cutscenes/")
		full_path = full_path.trim_suffix(".chat")
		full_path = StringUtils.hyphens_to_underscores(full_path)
		_open_input.value = full_path
	else:
		_error_dialog.dialog_text = "%s doesn't seem like the path to a cutscene file." % [full_path]
		_error_dialog.popup_centered()


func _on_OpenButton_pressed() -> void:
	_open_dialog.popup_centered()
