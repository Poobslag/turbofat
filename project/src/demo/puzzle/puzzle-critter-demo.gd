extends Node
## Shows off the puzzle critters.
##
## The letter keys A-Z toggle between different critters. The non-letter keys add and manipulate those critters. For
## example, you can add a mole to the playfield by pressing 'M' for mole, and then '1' to add a mole.
##
## Keys:
## 	[M]: Manipulate moles
## 	[M] -> [1]: Add a mole
## 	[M] -> ']': Advance moles

enum CritterType {
	NONE,
	MOLE,
}

var critter_type: int = CritterType.NONE

onready var _tutorial_hud: TutorialHud = $Puzzle/Hud/Center/TutorialHud

## a local path to a json level resource to demo
export (String, FILE, "*.json") var level_path: String

func _ready() -> void:
	var settings: LevelSettings = LevelSettings.new()
	if level_path:
		var json_text := FileUtils.get_file_as_text(level_path)
		var json_dict: Dictionary = parse_json(json_text)
		var level_key := LevelSettings.level_key_from_path(level_path)
		settings.from_json_dict(level_key, json_dict)
		# Ignore the start_level property so we can test the middle parts of tutorials
		settings.other.start_level = ""
	
	CurrentLevel.keep_retrying = true
	CurrentLevel.start_level(settings)
	_tutorial_hud.replace_tutorial_module()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_M: critter_type = CritterType.MOLE
	
	match critter_type:
		CritterType.MOLE: _mole_input(event)


func _mole_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			var mole_config := MoleConfig.new()
			$Puzzle/Fg/Critters/Moles.add_moles(mole_config)
		KEY_BRACKETRIGHT:
			$Puzzle/Fg/Critters/Moles.advance_moles()
