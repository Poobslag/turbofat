class_name CreatureEditorDialogs
extends Control
## Shows popup dialogs for the creature editor.

export (NodePath) var overworld_environment_path: NodePath

## Object and method to call after the player confirms or cancels the "unsaved changes" dialog
var _unsaved_changes_confirmation_target: Object
var _unsaved_changes_confirmation_method: String

onready var _error: AcceptDialog = $Error
onready var _export: FileDialog = $Export
onready var _import: FileDialog = $Import
onready var _unsaved_changes_confirmation := $UnsavedChangesConfirmation

onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)

func _ready() -> void:
	# Workaround for Godot #29674 (https://github.com/godotengine/godot/issues/29674).
	#
	# Assign default dialog paths. These path properties were removed in Godot 3.5 in 2022 as a security precaution
	# and can no longer be assigned in the Godot editor, so we assign them here.
	_export.current_dir = "/"
	_export.current_file = "509e7c82-9399-425a-9f15-9370c2b3de8b"
	
	_import.current_dir = "/"
	_import.current_file = "509e7c82-9399-425a-9f15-9370c2b3de8b"
	
	_unsaved_changes_confirmation.get_ok().text = tr("Save")
	_unsaved_changes_confirmation.get_cancel().text = tr("Discard")
	_unsaved_changes_confirmation.connect("confirmed",
			self, "_on_UnsavedChangesQuitConfirmation_save_pressed")
	_unsaved_changes_confirmation.get_cancel().connect("pressed",
			self, "_on_UnsavedChangesQuitConfirmation_discard_pressed")
	_unsaved_changes_confirmation.get_close_button().connect("pressed",
			self, "_on_UnsavedChangesQuitConfirmation_closed")


## Pops up an "unsaved changes" dialog. After the player chooses "Save" or "Discard", the specified callback is
## called.
##
## If the player closes the dialog, the callback is not called.
##
## Parameters:
## 	'target': The class whose method should be called after the player selects "Save" or "Discard".
##
## 	'method': The method to call after the player selects "Save" or "Discard".
func show_unsaved_changes_confirmation(target: Object, method: String) -> void:
	_unsaved_changes_confirmation_target = target
	_unsaved_changes_confirmation_method = method
	_unsaved_changes_confirmation.popup_centered()


func show_import_dialog() -> void:
	assign_default_dialog_dir(_import, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), "")
	_import.popup_centered()


func show_export_dialog() -> void:
	assign_default_dialog_dir(_export, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), "")
	
	var sanitized_creature_name := StringUtils.sanitize_file_root(_overworld_environment.player.creature_short_name)
	_export.current_file = "%s.json" % sanitized_creature_name
	_export.popup_centered()


func show_error_dialog(text: String) -> void:
	_error.dialog_text = text
	_error.popup_centered()


## Save the changes, and then perform the requested operation (quitting or importing)
func _on_UnsavedChangesQuitConfirmation_save_pressed() -> void:
	PlayerData.creature_library.player_def = _overworld_environment.player.get_creature_def()
	PlayerSave.save_player_data()
	
	if _unsaved_changes_confirmation_target:
		_unsaved_changes_confirmation_target.call(_unsaved_changes_confirmation_method)


## Don't save the changes, perform the requested operation (quitting or importing)
func _on_UnsavedChangesQuitConfirmation_discard_pressed() -> void:
	if _unsaved_changes_confirmation_target:
		_unsaved_changes_confirmation_target.call(_unsaved_changes_confirmation_method)


## Don't save the changes, and don't perform the requested operation (quitting or importing)
func _on_UnsavedChangesQuitConfirmation_closed() -> void:
	pass


## Assigns a default path for a FileDialog.
##
## At runtime, this will default to the user data directory. During development, this will default to a resource path
## for convenience when authoring Turbo Fat's creature's/levels.
##
## Note: We only want to assign the path the first time, but we can't check 'is the path empty' because an empty path
## is a valid choice -- a player can navigate to the root directory. So instead of checking 'is the path empty' we
## check 'is the path this specific UUID' since that's something the user will never navigate to accidentally.
static func assign_default_dialog_dir(dialog: FileDialog, default_dir: String, default_file) -> void:
	if dialog.current_path == "/509e7c82-9399-425a-9f15-9370c2b3de8b":
		dialog.current_dir = default_dir
		dialog.current_file = default_file
