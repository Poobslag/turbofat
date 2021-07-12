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
	# Initialize the Breadcrumb trail so that cutscenes will return to this demo after they finish.
	Breadcrumb.initialize_trail()
	
	_load_demo_data()
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
	var path := ChatHistory.path_from_history_key(_open_input.value)
	var chat_tree := ChatLibrary.chat_tree_from_file(path)
	CurrentLevel.set_launched_level(cutscene_prefix)
	
	if chat_tree:
		CutsceneManager.enqueue_chat_tree(chat_tree)
		SceneTransition.push_trail(chat_tree.cutscene_scene_path())
	else:
		push_warning("Invalid cutscene path: %s" % [_open_input.value])


func _on_OpenFileDialog_file_selected(_path: String) -> void:
	var full_path: String = _open_dialog.current_path
	if full_path.begins_with("res://assets/main/") \
			and full_path.ends_with(ChatLibrary.CHAT_EXTENSION):
		_open_input.value = ChatHistory.history_key_from_path(full_path)
	else:
		_error_dialog.dialog_text = "%s doesn't seem like the path to a cutscene file." % [full_path]
		_error_dialog.popup_centered()


func _on_OpenButton_pressed() -> void:
	_open_dialog.popup_centered()
