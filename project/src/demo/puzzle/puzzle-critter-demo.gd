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
## 	[C]: Manipulate carrots
## 	[C] -> [0]: Remove a carrot
## 	[C] -> [1]: Add a carrot
## 	[C] -> [2]: Toggle the amount of carrot smoke, and add a carrot
## 	[C] -> [3]: Toggle the carrot size, and add a carrot

enum CritterType {
	NONE,
	CARROT,
	MOLE,
}

var critter_type: int = CritterType.NONE

var _carrot_config := CarrotConfig.new()

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
		KEY_C: critter_type = CritterType.CARROT
		KEY_M: critter_type = CritterType.MOLE
	
	match critter_type:
		CritterType.CARROT: _carrot_input(event)
		CritterType.MOLE: _mole_input(event)


func _mole_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			var mole_config := MoleConfig.new()
			$Puzzle/Fg/Critters/Moles.add_moles(mole_config)
		KEY_BRACKETRIGHT:
			$Puzzle/Fg/Critters/Moles.advance_moles()


func _carrot_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0:
			$Puzzle/Fg/Critters/Carrots.remove_carrots(1)
		KEY_1:
			_carrot_config.columns = [0, 1, 2]
			$Puzzle/Fg/Critters/Carrots.add_carrots(_carrot_config)
		KEY_2:
			_carrot_config.smoke = (_carrot_config.smoke + 1) % CarrotConfig.Smoke.size()
			$Puzzle/Fg/Critters/Carrots.add_carrots(_carrot_config)
		KEY_3:
			_carrot_config.size = (_carrot_config.size + 1) % CarrotConfig.CarrotSize.size()
			$Puzzle/Fg/Critters/Carrots.add_carrots(_carrot_config)
