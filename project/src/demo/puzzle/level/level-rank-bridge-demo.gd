extends Node
## Calculates the percentage thresholds for different ranks, using the legacy math-based rank model.
##
## The math-based rank algorithms have been replaced with simpler percent-based algorithms, where there is a
## perfect score and then other goals are calculated based on a percentage of the perfect score. This demo calculates these percentages for a given level.
##
## For example, following the classic math-based model, a level might have the following requirements:
##
## 	M: ¥4,294
## 	SSS: ¥3,179
## 	SS+: ¥2,536
## 	SS: ¥2,020
##
## This demo calculates these scores using the classic math-based model and shows them as percentages in this demo. We
## can then use these percentages when defining our percentage thresholds in RankCriteria.

## property keys to use when saving/loading data
const SAVE_KEY_OPEN := "level-rank-bridge-demo.open"

onready var _error_dialog := $Dialogs/Error
onready var _open_dialog := $Dialogs/OpenFile
onready var _open_input := $Input/Open
onready var _text_edit := $Input/Output
onready var _demo_save := $DemoSave

func _ready() -> void:
	_load_demo_data()
	_refresh_level()


func _refresh_level() -> void:
	# load the level settings
	var level_settings := LevelSettings.new()
	level_settings.load_from_resource(_open_input.value)
	CurrentLevel.start_level(level_settings)
	_calculate()


## Calculates and outputs the necessary level metadata for the player to attain different grades.
func _calculate() -> void:
	_text_edit.text = ""
	
	var rank_target_calculator := LegacyRankTargetCalculator.new()
	var target_best := rank_target_calculator.target_for_grade(Ranks.BEST_GRADE)
	for grade in Ranks.GRADES:
		var target := rank_target_calculator.target_for_grade(grade)
		var target_string := ""
		var target_percent := 0.0
		if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
			target_string = StringUtils.format_duration(target)
			target_percent = float(target_best) / max(target, 1.0)
		else:
			target_string = StringUtils.format_money(target)
			target_percent = float(target) / max(target_best, 1.0)
		
		_text_edit.text += "%s: %s (%.1f%%)\n" % [grade, target_string, 100 * target_percent]
	
	# trim extra newlines from the output
	_text_edit.text = _text_edit.text.strip_edges()


## Reads the developer's in-memory data from a save file.
func _load_demo_data() -> void:
	if _demo_save.demo_data.has(SAVE_KEY_OPEN):
		_open_input.value = _demo_save.demo_data[SAVE_KEY_OPEN]


## Writes the developer's in-memory data to a save file.
func _save_demo_data() -> void:
	_demo_save.demo_data[SAVE_KEY_OPEN] = _open_input.value
	_demo_save.save_demo_data()


func _on_OpenFileDialog_file_selected(path: String) -> void:
	if path.begins_with("res://assets/main/") and path.ends_with(".json"):
		_open_input.value = LevelSettings.level_key_from_path(path)
		_save_demo_data()
	else:
		_error_dialog.dialog_text = "%s doesn't seem like the path to a level file." % [path]
		_error_dialog.popup_centered()
	
	_refresh_level()


func _on_OpenButton_pressed() -> void:
	_open_dialog.current_path = LevelSettings.path_from_level_key(_open_input.value)
	_open_dialog.popup_centered()
