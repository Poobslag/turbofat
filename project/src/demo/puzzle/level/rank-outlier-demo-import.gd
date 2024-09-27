extends Control
## RankOutlierDemo tab which imports player score data into a .score file.

## Emitted when new data is imported, changing the contents of our text field
signal text_changed(score_text)

## Current version for player score data. Should be updated if and only if the level format changes. This version
## number follows a 'ymdh' hex date format which is documented in issue #234.
const SCORE_DATA_VERSION := "59d3"

export (NodePath) var dialogs_path: NodePath

var _import_json_dialog: FileDialog
var _export_score_dialog: FileDialog
var _error_dialog: AcceptDialog

onready var _dialogs: Control = get_node(dialogs_path)
onready var _text_edit := $VBoxContainer/TextEdit

func _ready() -> void:
	_import_json_dialog = _dialogs.get_node("ImportJson")
	_export_score_dialog = _dialogs.get_node("ExportScore")
	_error_dialog = _dialogs.get_node("Error")
	
	_import_json_dialog.connect("file_selected", self, "_on_ImportJsonDialog_file_selected")
	_export_score_dialog.connect("file_selected", self, "_on_ExportScoreDialog_file_selected")
	
	_refresh_text_edit()


## Outputs the player's score data to a text area.
##
## This score data includes all levels they've finished, along with the score and time corresponding to their best
## performance.
func _refresh_text_edit() -> void:
	var new_text := ""
	
	var header := {}
	header["version"] = SCORE_DATA_VERSION
	header["id"] = _score_id()
	new_text += to_json(header) + "\n\n"
	
	var level_ids := PlayerData.level_history.finished_levels.keys()
	level_ids.sort()
	for level_id in level_ids:
		var best_result := PlayerData.level_history.best_result(level_id)
		new_text += "%s score=%s seconds=%.1f\n" % [level_id, best_result.score, best_result.seconds]
	
	new_text = new_text.strip_edges()
	_text_edit.text = new_text
	emit_signal("text_changed", _text_edit.text)


## Returns the id to use for the filename and id field of the '.score' file.
func _score_id() -> String:
	return PlayerData.creature_library.player_def.creature_name.to_lower()


func _on_ButtonImport_pressed() -> void:
	_import_json_dialog.popup_centered()


func _on_ButtonExport_pressed() -> void:
	_export_score_dialog.current_path \
			= ProjectSettings.globalize_path("res://assets/demo/puzzle/score/%s.score" % [_score_id()])
	_export_score_dialog.popup_centered()


func _on_ImportJsonDialog_file_selected(path: String) -> void:
	var load_successful := PlayerSave.load_player_data_from_file(path)
	if not load_successful:
		_dialogs.show_error("Error loading player data.")
		return
	
	_refresh_text_edit()


func _on_ExportScoreDialog_file_selected(path: String) -> void:
	FileUtils.write_file(path, _text_edit.text)
