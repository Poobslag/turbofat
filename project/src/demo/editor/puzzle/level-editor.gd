class_name LevelEditor
extends Node
## Graphical level editor which lets players create, load and save levels.
##
## This editor was used in the game until August 2024 when it was removed. Its UI was undecorated, unintuitive,
## incomplete and incompatible with gamepads. It will need a massive overhaul before it can meet the standards to be
## included in the game.
##
## Full instructions are available at https://github.com/Poobslag/turbofat/wiki/level-editor

## default to an empty level; players may be confused if it's not empty
const DEFAULT_LEVEL_ID := "practice/ultra_normal"

export (PackedScene) var PuzzleScene: PackedScene

## level scene currently being tested
var _test_scene: Node

onready var level_id_label := $HBoxContainer/SideButtons/LevelId
onready var _level_json := $HBoxContainer/SideButtons/Json
onready var _test_button := $HBoxContainer/SideButtons/Test

func _ready() -> void:
	var level_text := FileUtils.get_file_as_text(LevelSettings.path_from_level_key(DEFAULT_LEVEL_ID))
	
	# grab initial focus for controller/keyboard
	_test_button.grab_focus()
	
	# immediately parse and upgrade the level; LevelEditor will behave strangely with older level formats
	_parse_level(DEFAULT_LEVEL_ID, level_text)
	Breadcrumb.connect("trail_popped", self, "_on_Breadcrumb_trail_popped")


func save_level(path: String) -> void:
	FileUtils.write_file(path, _level_json.text)
	level_id_label.text = LevelSettings.level_key_from_path(path)


func load_level(path: String) -> void:
	var level_id := LevelSettings.level_key_from_path(path)
	var level_text := FileUtils.get_file_as_text(path)
	_parse_level(level_id, level_text)


func _parse_level(level_id: String, level_text: String) -> void:
	# immediately parse and upgrade the level; LevelEditor will behave strangely with older level formats
	var settings := LevelSettings.new()
	settings.load_from_text(level_id, level_text)
	_level_json.text = Utils.print_json(settings.to_json_dict())
	
	_level_json.reset_editors()
	level_id_label.text = level_id


func _start_test() -> void:
	var settings := LevelSettings.new()
	settings.load_from_text(level_id_label.text, _level_json.text)
	CurrentLevel.start_level(settings)
	_test_scene = PuzzleScene.instance()
	
	# back button should close level; shouldn't redirect us to a new scene
	SceneTransition.push_trail("res://src/demo/editor/puzzle/LevelEditor.tscn::test",
			{SceneTransition.FLAG_TYPE: SceneTransition.TYPE_NONE})
	add_child(_test_scene)
	
	# hide the level controls while testing a level, otherwise hitting 'esc' will do two things
	$HBoxContainer.visible = false


func _stop_test() -> void:
	if _test_scene:
		_test_scene.queue_free()
		_test_scene = null
		MusicPlayer.stop()
		
		# re-enable the level controls which was disabled while testing the level
		$HBoxContainer.visible = true


func _on_Test_pressed() -> void:
	_stop_test()
	_start_test()


func _on_Breadcrumb_trail_popped(prev_path: String) -> void:
	if prev_path == "res://src/demo/editor/puzzle/LevelEditor.tscn::test":
		# player exited the level under test; stop the test
		_stop_test()


func _on_Quit_pressed() -> void:
	SceneTransition.pop_trail()
