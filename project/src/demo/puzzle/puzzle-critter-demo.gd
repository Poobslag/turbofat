extends Node
## Shows off the puzzle critters.
##
## The letter keys A-Z toggle between different critters. The non-letter keys add and manipulate those critters. For
## example, you can add a mole to the playfield by pressing 'M' for mole, and then '1' to add a mole.
##
## Keys:
## 	[A]: Manipulate spears (asparagus)
## 	[A] -> [0]: Remove a spear
## 	[A] -> [1]: Add a spear
## 	[A] -> [2]: Toggle spear size
## 	[A] -> [3]: Toggle spear width
## 	[A] -> ']': Advance spears
## 	[C]: Manipulate carrots
## 	[C] -> [0]: Remove a carrot
## 	[C] -> [1]: Add a carrot
## 	[C] -> [2]: Toggle the amount of carrot smoke, and add a carrot
## 	[C] -> [3]: Toggle the carrot size, and add a carrot
## 	[C] -> '=': Increase carrot count to 99 for stress testing
## 	[M]: Manipulate moles
## 	[M] -> [1]: Add a mole
## 	[M] -> ']': Advance moles
## 	[M] -> '=': Increase mole count to 99 for stress testing
## 	[O] -> [0]: Despawn the onion
## 	[O] -> [1]: Spawn an onion with a regular day/night cycle
## 	[O] -> [2]: Advance the onion through different phases
## 	[O] -> [3]: Force daytime
## 	[O] -> [4]: Force day end
## 	[O] -> [5]: Force night
## 	[O] -> [6]: Force 'none'
## 	[Q]: Manipulate the playfield
## 	[Q] -> [1,2]: Insert a line at different locations in the playfield
## 	[S]: Manipulate sharks
## 	[S] -> [1]: Add a small shark
## 	[S] -> [2]: Add a medium shark
## 	[S] -> [3]: Add a large shark
## 	[S] -> [4]: Toggle shark patience
## 	[S] -> ']': Advance sharks
## 	[S] -> '=': Increase shark count to 99 for stress testing
## 	[T]: Manipulate tomatoes
## 	[T] -> [0]: Remove all tomatoes
## 	[T] -> [1]: Add some tomatoes

enum CritterType {
	NONE,
	CARROT,
	MOLE,
	ONION,
	PLAYFIELD,
	SHARK,
	SPEAR,
	TOMATO,
}

const SPEAR_CONFIG_SIZES := [
	"l4",
	"r4",
	"l3r3",
	"x4",
]

## local path to a json level resource to demo
export (String, FILE, "*.json") var level_path: String

export (bool) var cache_resources := false

var critter_type: int = CritterType.NONE

var _carrot_config := CarrotConfig.new()
var _mole_config := MoleConfig.new()
var _shark_config := SharkConfig.new()
var _spear_config := SpearConfig.new()

onready var _tutorial_hud: TutorialHud = $Puzzle/Hud/Center/TutorialHud

func _ready() -> void:
	if cache_resources:
		ResourceCache.start_load()
	
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
		KEY_A: critter_type = CritterType.SPEAR
		KEY_C: critter_type = CritterType.CARROT
		KEY_M: critter_type = CritterType.MOLE
		KEY_O: critter_type = CritterType.ONION
		KEY_Q: critter_type = CritterType.PLAYFIELD
		KEY_S: critter_type = CritterType.SHARK
		KEY_T: critter_type = CritterType.TOMATO
	
	match critter_type:
		CritterType.CARROT: _carrot_input(event)
		CritterType.MOLE: _mole_input(event)
		CritterType.ONION: _onion_input(event)
		CritterType.PLAYFIELD: _playfield_input(event)
		CritterType.SHARK: _shark_input(event)
		CritterType.SPEAR: _spear_input(event)
		CritterType.TOMATO: _tomato_input(event)


func _carrot_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0:
			$Puzzle/Fg/Critters/Carrots.remove_carrots(1)
		KEY_1:
			$Puzzle/Fg/Critters/Carrots.add_carrots(_carrot_config)
		KEY_2:
			_carrot_config.smoke = (_carrot_config.smoke + 1) % CarrotConfig.Smoke.size()
			$Puzzle/Fg/Critters/Carrots.add_carrots(_carrot_config)
		KEY_3:
			_carrot_config.size = (_carrot_config.size + 1) % CarrotConfig.CarrotSize.size()
			$Puzzle/Fg/Critters/Carrots.add_carrots(_carrot_config)
		KEY_EQUAL:
			_carrot_config.count = 99


func _mole_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			$Puzzle/Fg/Critters/Moles.add_moles(_mole_config)
		KEY_BRACKETRIGHT:
			$Puzzle/Fg/Critters/Moles.advance_moles()
		KEY_EQUAL:
			_mole_config.count = 99


func _onion_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0:
			$Puzzle/Fg/Critters/Onions.remove_onion()
		KEY_1:
			$Puzzle/Fg/Critters/Onions.remove_onion()
			$Puzzle/Fg/Critters/Onions.add_onion(OnionConfig.new("denn."))
		KEY_2:
			$Puzzle/Fg/Critters/Onions.advance_onion()
		KEY_3:
			$Puzzle/Fg/Critters/Onions.remove_onion()
			$Puzzle/Fg/Critters/Onions.add_onion(OnionConfig.new("dd"))
		KEY_4:
			$Puzzle/Fg/Critters/Onions.remove_onion()
			$Puzzle/Fg/Critters/Onions.add_onion(OnionConfig.new("ee"))
		KEY_5:
			$Puzzle/Fg/Critters/Onions.remove_onion()
			$Puzzle/Fg/Critters/Onions.add_onion(OnionConfig.new("nn"))
		KEY_6:
			$Puzzle/Fg/Critters/Onions.remove_onion()
			$Puzzle/Fg/Critters/Onions.add_onion(OnionConfig.new(".."))


func _playfield_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			CurrentLevel.puzzle.get_playfield().line_inserter.insert_line([""], PuzzleTileMap.ROW_COUNT - 1)
		KEY_2:
			CurrentLevel.puzzle.get_playfield().line_inserter.insert_line([""], PuzzleTileMap.ROW_COUNT - 5)


func _shark_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			_shark_config.size = SharkConfig.SharkSize.SMALL
			$Puzzle/Fg/Critters/Sharks.add_sharks(_shark_config)
		KEY_2:
			_shark_config.size = SharkConfig.SharkSize.MEDIUM
			$Puzzle/Fg/Critters/Sharks.add_sharks(_shark_config)
		KEY_3:
			_shark_config.size = SharkConfig.SharkSize.LARGE
			$Puzzle/Fg/Critters/Sharks.add_sharks(_shark_config)
		KEY_4:
			_shark_config.patience = 0 if _shark_config.patience == 3 else 3
		KEY_BRACKETRIGHT:
			$Puzzle/Fg/Critters/Sharks.advance_sharks()
		KEY_EQUAL:
			_shark_config.count = 99


func _spear_input(event: InputEvent) -> void:
	_spear_config.lines = [PuzzleTileMap.ROW_COUNT - 4]
	
	match Utils.key_scancode(event):
		KEY_0:
			$Puzzle/Fg/Critters/Spears.pop_out_spears(1)
		KEY_1:
			$Puzzle/Fg/Critters/Spears.add_spears(_spear_config)
		KEY_2:
			var wide := _is_spear_config_wide()
			var spear_config_size_index := _spear_config_size_index()
			spear_config_size_index = (spear_config_size_index + 1) % SPEAR_CONFIG_SIZES.size()
			_spear_config.sizes = [SPEAR_CONFIG_SIZES[spear_config_size_index]]
			
			if wide:
				# preserve 'wideness'
				_spear_config.sizes[0] = _spear_config.sizes[0].to_upper()
		KEY_3:
			if _spear_config_size_index() == -1:
				_spear_config.sizes = [SPEAR_CONFIG_SIZES[0]]
			
			var wide := _is_spear_config_wide()
			if wide:
				_spear_config.sizes[0] = _spear_config.sizes[0].to_lower()
			else:
				_spear_config.sizes[0] = _spear_config.sizes[0].to_upper()
			
		KEY_BRACKETRIGHT:
			$Puzzle/Fg/Critters/Spears.advance_spears()


func _tomato_input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0:
			for y in range(PuzzleTileMap.ROW_COUNT):
				$Puzzle/Fg/Critters/Tomatoes.remove_tomato(y)
		KEY_1:
			for i in range(3):
				$Puzzle/Fg/Critters/Tomatoes.add_tomato(Utils.randi_range(0, PuzzleTileMap.ROW_COUNT - 1))


func _spear_config_size_index() -> int:
	return SPEAR_CONFIG_SIZES.find(_spear_config.sizes[0].to_lower())


func _is_spear_config_wide() -> bool:
	return SpearConfig.is_wide(_spear_config.sizes[0])
