extends Control
"""
Demonstrates different scenarios.

Scenarios are launched by typing the 7-character cheat codes shown when the demo starts up.
"""

onready var ScenarioScene := preload("res://src/main/puzzle/Scenario.tscn")

var _scenario_scene_instance: Node

var cheats := {
	"boatric": "boatricia",
	"novegi5": "five-customers-no-vegetables",
}

func _ready() -> void:
	ResourceCache.minimal_resources = true
	
	$RichTextLabel.clear()
	for key in cheats.keys():
		$CheatCodeDetector.codes.append(key)
		$RichTextLabel.text += "%s -> %s\n" % [key, cheats[key]]

func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	detector.play_cheat_sound(true)
	
	if _scenario_scene_instance:
		remove_child(_scenario_scene_instance)
		_scenario_scene_instance.queue_free()
	
	var scenario_settings: ScenarioSettings = ScenarioLibrary.load_scenario_from_file(cheats[cheat])
	Global.scenario_settings = scenario_settings
	_scenario_scene_instance = ScenarioScene.instance()
	add_child(_scenario_scene_instance)
