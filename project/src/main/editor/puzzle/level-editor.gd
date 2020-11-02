class_name LevelEditor
extends Control
"""
A graphical level editor which lets players create, load and save levels.

Full instructions are available at https://github.com/Poobslag/turbofat/wiki/level-editor
"""

# default to an empty level; players may be confused if it's not empty
const DEFAULT_LEVEL := "ultra_normal"

# level scene currently being tested
var _test_scene: Node

onready var PuzzleScene := preload("res://src/main/puzzle/Puzzle.tscn")

onready var level_name := $HBoxContainer/SideButtons/LevelName
onready var _level_json := $HBoxContainer/SideButtons/Json

func _ready() -> void:
	if not ResourceCache.is_done():
		# when launched standalone, we don't load creature resources (they're slow)
		ResourceCache.minimal_resources = true
	
	var level_text := FileUtils.get_file_as_text(LevelSettings.level_path(DEFAULT_LEVEL))
	_level_json.text = level_text
	_level_json.refresh_tile_map()
	level_name.text = DEFAULT_LEVEL
	Breadcrumb.connect("trail_popped", self, "_on_Breadcrumb_trail_popped")


func save_level(path: String) -> void:
	FileUtils.write_file(path, _level_json.text)


func load_level(path: String) -> void:
	var level_text := FileUtils.get_file_as_text(path)
	_level_json.text = level_text
	_level_json.refresh_tile_map()
	level_name.text = LevelSettings.level_name(path)


func _start_test() -> void:
	var settings := LevelSettings.new()
	settings.load_from_text(level_name.text, _level_json.text)
	Level.start_level(settings)
	_test_scene = PuzzleScene.instance()
	
	# back button should close level; shouldn't redirect us to a new scene
	Breadcrumb.push_trail("res://src/main/editor/puzzle/LevelEditor.tscn::test")
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
	if prev_path == "res://src/main/editor/puzzle/LevelEditor.tscn::test":
		# player exited the level under test; stop the test
		_stop_test()
	elif not Breadcrumb.trail:
		# player exited the level editor when it was launched standalone; exit to loading screen to avoid jitter
		ResourceCache.minimal_resources = false
		get_tree().change_scene("res://src/main/ui/menu/LoadingScreen.tscn")


func _on_Quit_pressed() -> void:
	Breadcrumb.pop_trail()
