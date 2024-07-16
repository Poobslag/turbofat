extends Control
## Shows popup dialogs for the old creature editor.

export (NodePath) var creature_editor_path: NodePath

onready var _creature_editor: CreatureEditorOld = get_node(creature_editor_path)
onready var _error_dialog := $Error
onready var _import_dialog := $Import
onready var _export_dialog := $Export
onready var _save_confirmation := $SaveConfirmation

func _ready() -> void:
	_assign_default_dialog_paths()


## Assign default dialog paths. These path properties were removed in Godot 3.5 in 2022 as a security precaution and
## can no longer be assigned in the Godot editor, so we assign them here. See Godot #29674
## (https://github.com/godotengine/godot/issues/29674)
func _assign_default_dialog_paths() -> void:
	# During development, the second of these assignments will succeed, but at runtime the assignment will have no
	# effect. This gives us a more convenient default directory when authoring Turbo Fat's creatures.
	_import_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	_import_dialog.current_dir = ProjectSettings.globalize_path("res://assets/main/creatures/nonstory/")
	
	_export_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	_export_dialog.current_dir = ProjectSettings.globalize_path("res://assets/main/creatures/nonstory/")


func _show_import_export_not_supported_error() -> void:
	_error_dialog.dialog_text = "Import/export isn't supported over the web. Sorry!"
	_error_dialog.popup_centered()


func _preserve_file_dialog_paths(dialog: FileDialog) -> void:
	for other_dialog in [_import_dialog, _export_dialog]:
		other_dialog.current_file = dialog.current_file
		other_dialog.current_path = dialog.current_path


func _on_ImportButton_pressed() -> void:
	if OS.has_feature("web"):
		_show_import_export_not_supported_error()
		return
	
	_import_dialog.popup_centered()


## Imports the specified creature into the editor.
func _on_ImportDialog_file_selected(path: String) -> void:
	var loaded_def: CreatureDef = CreatureDef.new().from_json_path(path)
	if loaded_def:
		_creature_editor.set_center_creature_def(loaded_def)
		_creature_editor.mutate_all_creatures()
	else:
		_error_dialog.dialog_text = "Error importing creature."
		_error_dialog.popup_centered()
	_preserve_file_dialog_paths(_import_dialog)


func _on_ExportButton_pressed() -> void:
	if OS.has_feature("web"):
		_show_import_export_not_supported_error()
		return
	
	var exported_creature: Creature = _creature_editor.center_creature
	var sanitized_creature_name := StringUtils.sanitize_file_root(exported_creature.creature_short_name)
	_export_dialog.current_file = "%s.json" % sanitized_creature_name
	_export_dialog.popup_centered()


## Imports the currently edited creature to a file.
func _on_ExportDialog_file_selected(path: String) -> void:
	var exported_creature: Creature = _creature_editor.center_creature
	var exported_creature_def := exported_creature.creature_def
	exported_creature_def.chef_if = "true"
	exported_creature_def.customer_if = "true"
	var exported_json := exported_creature_def.to_json_dict()
	FileUtils.write_file(path, Utils.print_json(exported_json))
	_preserve_file_dialog_paths(_export_dialog)


func _on_SaveButton_pressed() -> void:
	_save_confirmation.popup_centered()


## Updates the player character and writes it to their save file.
func _on_SaveConfirmation_confirmed() -> void:
	var saved_creature_def := _creature_editor.center_creature.creature_def
	saved_creature_def.chef_if = "true"
	saved_creature_def.customer_if = "false"
	PlayerData.creature_library.player_def = saved_creature_def
	PlayerSave.schedule_save()
