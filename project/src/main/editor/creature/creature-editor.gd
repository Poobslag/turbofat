extends Node
## Graphical creature editor which lets players design their own creatures.

export (NodePath) var overworld_environment_path: NodePath
export (NodePath) var dialogs_path: NodePath
export (NodePath) var creature_saver_path: NodePath

onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)
onready var _dialogs: CreatureEditorDialogs = get_node(dialogs_path)
onready var _creature_saver: CreatureSaver = get_node(creature_saver_path)

func _ready() -> void:
	MusicPlayer.play_menu_track()
	
	$Buttons/VBoxContainer/CategorySelector.set_selected_category_index(0)


func _quit() -> void:
	SceneTransition.pop_trail()


func _show_import_dialog() -> void:
	_dialogs.show_import_dialog()


func _perform_export_operation() -> void:
	_dialogs.show_export_dialog()


func _perform_import_operation() -> void:
	if _creature_saver.has_unsaved_changes() and not _creature_saver.is_freshly_imported_creature_def():
		_dialogs.show_unsaved_changes_confirmation(self, "_show_import_dialog")
	else:
		_show_import_dialog()


func _perform_save_operation() -> void:
	_creature_saver.save_creature()


func _on_AlleleButtons_operation_button_pressed(operation_id: String) -> void:
	match operation_id:
		"export":
			_perform_export_operation()
		"import":
			_perform_import_operation()
		"save":
			_perform_save_operation()


func _on_Export_file_selected(path: String) -> void:
	if not _overworld_environment.player:
		return
	
	var exported_def := _overworld_environment.player.creature_def
	exported_def.creature_id = NameUtils.short_name_to_id(exported_def.creature_short_name)
	exported_def.chef_if = "true"
	exported_def.customer_if = "true"
	var exported_json := exported_def.to_json_dict()
	FileUtils.write_file(path, Utils.print_json(exported_json))


func _on_Import_file_selected(path: String) -> void:
	var imported_def: CreatureDef = CreatureDef.new().from_json_path(path)
	if imported_def:
		imported_def.creature_id = CreatureLibrary.PLAYER_ID
		_overworld_environment.player.set_creature_def(imported_def)
	else:
		_dialogs.show_error_dialog(tr("Error importing creature."))


func _on_Quit_pressed() -> void:
	if _creature_saver.has_unsaved_changes():
		_dialogs.show_unsaved_changes_confirmation(self, "_quit")
	else:
		_quit()
