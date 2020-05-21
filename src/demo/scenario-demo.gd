extends Control
"""
Demonstrates different scenarios.

Scenarios are launched by typing the 7-character cheat codes shown when the demo starts up.
"""

onready var ScenarioScene := preload("res://src/main/puzzle/Scenario.tscn")
onready var _scenario_text := $HBoxContainer/CenterPanel/ScenarioText
onready var _scenario_name := $HBoxContainer/SidePanel/SideButtons/ScenarioName

var _scenario_scene_instance: Node

func _ready() -> void:
	ResourceCache.minimal_resources = true
	var scenario_text: String = Global.get_file_as_text(ScenarioLibrary.scenario_path("ultra-normal"))
	_scenario_text.text = scenario_text
	_scenario_name.text = "ultra-normal"
	
	# back button should close scenario; shouldn't redirect us to a new scene
	Global.post_puzzle_target = ""


func _save_scenario(path: String) -> void:
	var file := File.new()
	file.open(path, File.WRITE)
	file.store_string(_scenario_text.text)
	file.close()


func _load_scenario(path: String) -> void:
	var scenario_text: String = Global.get_file_as_text(path)
	_scenario_text.text = scenario_text
	_scenario_name.text = ScenarioLibrary.scenario_name(path)


func _start_test() -> void:
	Global.scenario_settings = ScenarioLibrary.load_scenario(_scenario_name.text, _scenario_text.text)
	_scenario_scene_instance = ScenarioScene.instance()
	_scenario_scene_instance.connect("back_button_pressed", self, "_on_Scenario_back_button_pressed")
	add_child(_scenario_scene_instance)


func _stop_test() -> void:
	if _scenario_scene_instance:
		remove_child(_scenario_scene_instance)
		_scenario_scene_instance.queue_free()
		_scenario_scene_instance = null


func _on_OpenFile_pressed() -> void:
	$OpenFileDialog.popup_centered()


func _on_OpenResource_pressed() -> void:
	$OpenResourceDialog.popup_centered()


func _on_Save_pressed() -> void:
	$SaveDialog.current_file = ScenarioLibrary.scenario_filename(_scenario_name.text)
	$SaveDialog.popup_centered()


func _on_OpenResourceDialog_file_selected(path) -> void:
	_load_scenario(path)


func _on_OpenFileDialog_file_selected(path) -> void:
	_load_scenario(path)


func _on_SaveDialog_file_selected(path) -> void:
	_save_scenario(path)


func _on_Test_pressed() -> void:
	_stop_test()
	_start_test()


func _on_Scenario_back_button_pressed() -> void:
	_stop_test()
