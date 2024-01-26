extends Node
## Demonstrates cutscenes.
##
## The user can select and launch any cutscene, and change how fat the creatures are.

## property keys to use when saving/loading data
const SAVE_KEY_FLAGS := "cutscene-demo.flags"
const SAVE_KEY_OPEN := "cutscene-demo.open"

onready var _demo_save := $DemoSave
onready var _flags_input := $Input/Flags
onready var _open_input := $Input/Open
onready var _open_button := $Input/Open/Button
onready var _start_button := $Input/StartButton
onready var _error_dialog := $Dialogs/Error
onready var _open_dialog := $Dialogs/OpenFile

func _ready() -> void:
	# Initialize the Breadcrumb trail so that cutscenes will return to this demo after they finish.
	Breadcrumb.initialize_trail()
	
	# stop any music which was playing during the cutscene
	MusicPlayer.stop()
	
	_load_demo_data()
	
	_assign_focus()
	
	PlayerData.creature_library.clear_all_fatness()


func _assign_focus() -> void:
	if not _start_button.disabled:
		_start_button.grab_focus()
	else:
		_open_button.grab_focus()


func _load_demo_data() -> void:
	if _demo_save.demo_data.has(SAVE_KEY_FLAGS):
		_flags_input.value = _demo_save.demo_data[SAVE_KEY_FLAGS]
	
	if _demo_save.demo_data.has(SAVE_KEY_OPEN):
		var path: String = _demo_save.demo_data[SAVE_KEY_OPEN]
		_open_input.value = path
		
		if not _open_input.valid:
			# Report a warning if the player selects an invalid cutscene file. We do not show a dialog because the UI
			# components might not be initialized yet.
			push_warning("%s doesn't seem like the path to a cutscene file." % [path])
	
	_refresh_start_button()


func _save_demo_data() -> void:
	_demo_save.demo_data[SAVE_KEY_FLAGS] = _flags_input.value
	_demo_save.demo_data[SAVE_KEY_OPEN] = _open_input.value
	_demo_save.save_demo_data()


## Disables the start button if the selected cutscene is invalid.
func _refresh_start_button() -> void:
	_start_button.disabled = not _open_input.valid


func _on_StartButton_pressed() -> void:
	_save_demo_data()
	_flags_input.apply_flags()
	
	CurrentCutscene.set_launched_cutscene(ChatLibrary.chat_key_from_path(_open_input.value))
	CurrentCutscene.push_cutscene_trail()


func _on_OpenFileDialog_file_selected(path: String) -> void:
	_open_input.value = path
	
	if not _open_input.valid:
		# show a dialog if the player selects an invalid cutscene
		_error_dialog.dialog_text = "%s doesn't seem like the path to a cutscene file." % [path]
		_error_dialog.popup_centered()


func _on_OpenButton_pressed() -> void:
	_open_dialog.current_path = _open_input.value
	_open_dialog.popup_centered()


func _on_Open_valid_changed() -> void:
	_refresh_start_button()


func _on_OpenFile_hide() -> void:
	_assign_focus()


func _on_Error_hide() -> void:
	_assign_focus()
