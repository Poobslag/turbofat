extends Node
## Library of level trigger effects.
##
## These effects are each mapped to a unique string so that they can be referenced from json.

## Clears any filled lines on the playfield.
##
## This normally has no effect, as filled lines on the playfield are automatically cleared. But it can result in
## interesting behavior when combined with effects which prevent or delay these automatic line clears.
class ClearFilledLinesEffect extends LevelTriggerEffect:
	var force: bool = false
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [force]: (Optional) If 'true', line clears will ignore any 'blocks during' conditions such as
	## 	'filled_line_clear_delay' or 'filled_line_clear_max'. Defaults to 'false'
	##
	## Example: ["add_moles count=2 reward=seed"]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("force"):
			force = Utils.to_bool(new_config["force"])
	
	
	func run() -> void:
		CurrentLevel.puzzle.get_playfield().line_clearer.schedule_filled_line_clears(force)
	
	
	func get_config() -> Dictionary:
		var config := {}
		if force != false:
			config["force"] = "true"
		return config


## Adds one or more carrots to the playfield.
class AddCarrotsEffect extends LevelTriggerEffect:
	var config: CarrotConfig = CarrotConfig.new()
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [count]: (Optional) How many carrots appear during a single 'add carrots' effect. Defaults to 1.
	## [duration]: (Optional) Duration in seconds that the carrot remains onscreen. Defaults to eight seconds.
	## [size]: (Optional) Carrot size: 'small', 'medium', 'large' or 'xl'. Defaults to 'medium'.
	## [smoke]: (Optional) Size of the smoke cloud: 'none', 'small', 'medium' or 'large'. Defaults to 'small'.
	## [x]: (Optional) Restricts which columns the carrots appear on, where '0' is the leftmost column of the
	## 	playfield. For large carrots, this corresponds to the leftmost column of the carrot.
	##
	## Example: ["add_carrots count=2 size=large"]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("count"):
			config.count = new_config["count"].to_int()
		if new_config.has("duration"):
			config.duration = new_config["duration"]
		if new_config.has("size"):
			config.size = Utils.enum_from_snake_case(CarrotConfig.CarrotSize, new_config["size"])
		if new_config.has("smoke"):
			config.smoke = Utils.enum_from_snake_case(CarrotConfig.Smoke, new_config["smoke"])
		if new_config.has("x"):
			config.columns = ConfigStringUtils.ints_from_config_string(new_config["x"], 8).keys()
	
	
	func run() -> void:
		CurrentLevel.puzzle.get_carrots().add_carrots(config)
	
	
	func get_config() -> Dictionary:
		var result := {}
		
		if config.count != 1:
			result["count"] = str(config.count)
		if config.duration != 8.0:
			result["duration"] = str(config.duration)
		if config.size != CarrotConfig.CarrotSize.MEDIUM:
			result["size"] = Utils.enum_to_snake_case(CarrotConfig.CarrotSize, config.size)
		if config.smoke != CarrotConfig.Smoke.SMALL:
			result["smoke"] = Utils.enum_to_snake_case(CarrotConfig.Smoke, config.smoke)
		if config.columns:
			result["x"] = ConfigStringUtils.config_string_from_ints(config.columns)
		
		return result


## Adds an onion to the playfield.
class AddOnionEffect extends LevelTriggerEffect:
	var config: OnionConfig = OnionConfig.new()
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [0]: A string defining the onion's day/night cycle. This accepts the following characters:
	## 		'.': 'None' state. The onion is underground.
	## 		'd': 'Day' state. The onion is dancing ominously.
	## 		'e': 'Day End' state. The onion raises their arms in warning.
	## 		'n': 'Night' state. The onion is in the sky, and the puzzle is cast in darkness.
	##
	## Example: ["add_onion dddennn."]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("0"):
			config.day_string = new_config["0"]
	
	
	func run() -> void:
		CurrentLevel.puzzle.get_onions().add_onion(config)
	
	
	func get_config() -> Dictionary:
		var result := {}
		
		if config.day_string:
			result["0"] = config.day_string
		
		return result


## Adds one or more moles to the playfield.
class AddMolesEffect extends LevelTriggerEffect:
	var config: MoleConfig = MoleConfig.new()
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [count]: (Optional) How many moles appear during a single 'add moles' effect. Defaults to 1.
	## [home]: (Optional) Restricts which types of tiles moles can appear: 'any', 'veg', 'box', 'surface', 'cake' or
	## 	'hole'.
	## [y]: (Optional) Restricts which rows the moles appear on, where '0' is the bottom row of the playfield and '16'
	## 	is the top.
	## [x]: (Optional) Restricts which columns the moles appear on, where '0' is the leftmost column of the playfield.
	## [dig_duration]: (Optional) How many turns/seconds/cycles the moles dig for. Defaults to 3.
	## [reward]: (Optional) Reward the moles dig up: 'seed' or 'star'. Defaults to 'star'.
	##
	## Example: ["add_moles count=2 reward=seed"]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("count"):
			config.count = new_config["count"].to_int()
		if new_config.has("home"):
			config.home = Utils.enum_from_snake_case(MoleConfig.Home, new_config["home"])
		if new_config.has("y"):
			var inverted_lines := ConfigStringUtils.ints_from_config_string(new_config["y"], 16)
			config.lines = ConfigStringUtils.invert_puzzle_row_indexes(inverted_lines.keys())
		if new_config.has("x"):
			config.columns = ConfigStringUtils.ints_from_config_string(new_config["x"], 8).keys()
		if new_config.has("dig_duration"):
			config.dig_duration = new_config["dig_duration"].to_int()
		if new_config.has("reward"):
			config.reward = Utils.enum_from_snake_case(MoleConfig.Reward, new_config["reward"])
	
	
	func run() -> void:
		CurrentLevel.puzzle.get_moles().add_moles(config)
	
	
	func get_config() -> Dictionary:
		var result := {}
		
		if config.count != 1:
			result["count"] = str(config.count)
		if config.home != MoleConfig.Home.ANY:
			result["home"] = Utils.enum_to_snake_case(MoleConfig.Home, config.home)
		if config.lines:
			var inverted_lines: Array = ConfigStringUtils.invert_puzzle_row_indexes(config.lines)
			result["y"] = ConfigStringUtils.config_string_from_ints(inverted_lines)
		if config.columns:
			result["x"] = ConfigStringUtils.config_string_from_ints(config.columns)
		if config.dig_duration != 3:
			result["dig_duration"] = str(config.dig_duration)
		if config.reward != MoleConfig.Reward.STAR:
			result["reward"] = Utils.enum_to_snake_case(MoleConfig.Reward, config.reward)
		
		return result


## Adds one or more sharks to the playfield.
class AddSharksEffect extends LevelTriggerEffect:
	var config: SharkConfig = SharkConfig.new()
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [count]: (Optional) How many sharks appear during a single 'add sharks' effect. Defaults to 1.
	## [home]: (Optional) Restricts which types of tiles sharks can appear: 'any', 'veg', 'box', 'surface', 'cake' or
	## 	'hole'.
	## [y]: (Optional) Restricts which rows the sharks appear on, where '0' is the bottom row of the playfield and '16'
	## 	is the top.
	## [x]: (Optional) Restricts which columns the sharks appear on, where '0' is the leftmost column of the playfield.
	## [patience]: (Optional) How long the shark waits before disappearing. Defaults to 'forever'.
	## [size]: (Optional) Size (and appetite) of the shark: 'small', 'medium' or 'large'. Defaults to 'medium'.
	##
	## Example: ["add_sharks size=small count=3 patience=5"]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("count"):
			config.count = new_config["count"].to_int()
		if new_config.has("home"):
			config.home = Utils.enum_from_snake_case(SharkConfig.Home, new_config["home"])
		if new_config.has("y"):
			var inverted_lines := ConfigStringUtils.ints_from_config_string(new_config["y"], 16)
			config.lines = ConfigStringUtils.invert_puzzle_row_indexes(inverted_lines.keys())
		if new_config.has("x"):
			config.columns = ConfigStringUtils.ints_from_config_string(new_config["x"], 8).keys()
		if new_config.has("patience"):
			config.patience = new_config["patience"].to_int()
		if new_config.has("size"):
			config.size = Utils.enum_from_snake_case(SharkConfig.SharkSize, new_config["size"])
	
	
	func run() -> void:
		CurrentLevel.puzzle.get_sharks().add_sharks(config)
	
	
	func get_config() -> Dictionary:
		var result := {}
		
		if config.count != 1:
			result["count"] = str(config.count)
		if config.home != SharkConfig.Home.ANY:
			result["home"] = Utils.enum_to_snake_case(SharkConfig.Home, config.home)
		if config.lines:
			var inverted_lines: Array = ConfigStringUtils.invert_puzzle_row_indexes(config.lines)
			result["y"] = ConfigStringUtils.config_string_from_ints(inverted_lines)
		if config.columns:
			result["x"] = ConfigStringUtils.config_string_from_ints(config.columns)
		if config.patience != 3:
			result["patience"] = str(config.patience)
		if config.size != SharkConfig.SharkSize.MEDIUM:
			result["size"] = Utils.enum_to_snake_case(SharkConfig.SharkSize, config.size)
		
		return result


## Adds one or more spears to the playfield.
class AddSpearsEffect extends LevelTriggerEffect:
	var config: SpearConfig = SpearConfig.new()
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [sizes]: (Optional) List of String sizes, like 'x5', 'l3', 'l2r4' or 'R8'. The letters 'l' and 'r' refer to
	## 	spears emerging from the left or right sides. Capital letters are used for wide spears. The number corresponds
	## 	to the spear's length in cells.
	## [count]: (Optional) How many spears appear during a single 'add spears' effect. Defaults to 1.
	## [duration]: (Optional) How long the spears wait before disappearing. Defaults to 'forever'
	## [y]: (Optional) Restricts which rows the spears appear on, where '0' is the bottom row of the playfield and '16'
	## 	is the top.
	##
	## Example: ["add_spears sizes=X6,l4r4 y=12-16"]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("sizes"):
			config.sizes = new_config["sizes"].split(",")
		if new_config.has("count"):
			config.count = new_config["count"].to_int()
		if new_config.has("duration"):
			config.duration = new_config["duration"].to_int()
		if new_config.has("wait"):
			config.wait = new_config["wait"].to_int()
		if new_config.has("y"):
			var inverted_lines := ConfigStringUtils.ints_from_config_string(new_config["y"], 16)
			config.lines = ConfigStringUtils.invert_puzzle_row_indexes(inverted_lines.keys())
	
	
	func run() -> void:
		CurrentLevel.puzzle.get_spears().add_spears(config)
	
	
	func get_config() -> Dictionary:
		var result := {}
		
		if config.sizes != SpearConfig.DEFAULT_SIZES:
			result["sizes"] = ",".join(config.sizes)
		if config.count != 1:
			result["count"] = str(config.count)
		if config.duration != -1:
			result["duration"] = str(config.duration)
		if config.wait != 2:
			result["wait"] = str(config.wait)
		if config.lines:
			var inverted_lines: Array = ConfigStringUtils.invert_puzzle_row_indexes(config.lines)
			result["y"] = ConfigStringUtils.config_string_from_ints(inverted_lines)
		
		return result


## Advances the day/night cycle of any onions on the playfield.
class AdvanceOnionEffect extends LevelTriggerEffect:
	func _init() -> void:
		priority = 86
	
	func run() -> void:
		CurrentLevel.puzzle.get_onions().advance_onion()


## Advances all moles on the playfield, allowing them to dig up pickups.
class AdvanceMolesEffect extends LevelTriggerEffect:
	func _init() -> void:
		priority = 86
	
	func run() -> void:
		CurrentLevel.puzzle.get_moles().advance_moles()


## Advances all sharks on the playfield, making them appear/disappear.
class AdvanceSharksEffect extends LevelTriggerEffect:
	func _init() -> void:
		priority = 86
	
	func run() -> void:
		CurrentLevel.puzzle.get_sharks().advance_sharks()


## Advances all spears on the playfield, making them appear/disappear.
class AdvanceSpearsEffect extends LevelTriggerEffect:
	func _init() -> void:
		priority = 86
	
	func run() -> void:
		CurrentLevel.puzzle.get_spears().advance_spears()


## Removes one or more carrots from the playfield.
class RemoveCarrotsEffect extends LevelTriggerEffect:
	var count := 1
	
	func _init() -> void:
		priority = 53
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [0]: (Optional) Number of carrots to remove. Defaults to 1.
	##
	## Example: ["remove_carrots 2"]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("0"):
			count = new_config["0"].to_int()
	
	
	func run() -> void:
		CurrentLevel.puzzle.get_carrots().remove_carrots(count)
	
	
	func get_config() -> Dictionary:
		var result := {}
		
		if count != 1:
			result["0"] = str(count)
		
		return result


## Removes the onion from the playfield.
class RemoveOnionEffect extends LevelTriggerEffect:
	func _init():
		priority = 53
	
	func run() -> void:
		CurrentLevel.puzzle.get_onions().remove_onion()


## Removes one or more carrots from the playfield.
class RemoveSpearsEffect extends LevelTriggerEffect:
	var count := 1
	
	func _init() -> void:
		priority = 53
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [0]: (Optional) Number of spears to remove. Defaults to 1.
	##
	## Example: ["remove_spears 2"]
	func set_config(new_config: Dictionary = {}) -> void:
		priority = 53
		if new_config.has("0"):
			count = new_config["0"].to_int()
	
	
	func run() -> void:
		CurrentLevel.puzzle.get_spears().pop_out_spears(count)


	func get_config() -> Dictionary:
		var result := {}

		if count != 1:
			result["0"] = str(count)

		return result


## Rotates one or more pieces in the piece queue.
class RotateNextPiecesEffect extends LevelTriggerEffect:
	enum Rotation {
		NONE, CW, CCW, FLIP
	}
	
	## enum in Rotation corresponding to the direction to rotate
	var rotate_dir: int = Rotation.NONE
	
	## First piece index in the queue to rotate, inclusive
	var next_piece_from_index: int = 0
	
	## Last piece index in the queue to rotate, inclusive
	var next_piece_to_index: int = 999999
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [0]: (Optional) Direction to rotate, 'cw', 'ccw', '180' or 'none'. Defaults to 'none'.
	## [1]: (Optional) First piece index in the queue to rotate. Defaults to 0.
	## [2]: (Optional) Last piece index in the queue to rotate. Defaults to 999999.
	##
	## Example: ["cw", "0", "0"]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("0"):
			match new_config["0"]:
				"none": rotate_dir = Rotation.NONE
				"cw": rotate_dir = Rotation.CW
				"ccw": rotate_dir = Rotation.CCW
				"180": rotate_dir = Rotation.FLIP
		
		if new_config.has("1"):
			next_piece_from_index = new_config["1"].to_int()
		
		if new_config.has("2"):
			next_piece_to_index = new_config["2"].to_int()
	
	
	func run() -> void:
		var pieces: Array = CurrentLevel.puzzle.get_piece_queue().pieces
		for i in range(next_piece_from_index, next_piece_to_index + 1):
			if i >= pieces.size():
				break
			var next_piece: NextPiece = pieces[i]
			match rotate_dir:
				Rotation.CW: next_piece.orientation = next_piece.get_cw_orientation()
				Rotation.CCW: next_piece.orientation = next_piece.get_ccw_orientation()
				Rotation.FLIP: next_piece.orientation = next_piece.get_flip_orientation()
	
	
	func get_config() -> Dictionary:
		var result := {}
		match rotate_dir:
			Rotation.NONE: result["0"] = "none"
			Rotation.CW: result["0"] = "cw"
			Rotation.CCW: result["0"] = "ccw"
			Rotation.FLIP: result["0"] = "180"
		if next_piece_from_index != 0:
			result["1"] = str(next_piece_from_index)
		if next_piece_to_index != 999999:
			# we also populate result["1"] if it wasn't already populated
			result["1"] = str(next_piece_from_index)
			result["2"] = str(next_piece_to_index)
		
		return result


## Inserts a new line.
class InsertLineEffect extends LevelTriggerEffect:
	## (Optional) target row
	var y: int = PuzzleTileMap.ROW_COUNT - 1
	
	## (Optional) number of lines to insert
	var count: int = 1
	
	## (Optional) keys corresponding to sets of tiles in LevelTiles for the tiles to insert
	var tiles_keys: Array = []
	
	## Updates the effect's configuration.
	##
	## This effect's configuration accepts the following parameters:
	##
	## [count]: (Optional) Number of lines to insert. Defaults to 1.
	## [tiles_key]: (Optional) Key corresponding to a set of tiles in LevelTiles for the tiles to insert.
	## [tiles_keys]: (Optional) Key corresponding to sets of tiles in LevelTiles for the tiles to insert.
	## [y]: (Optional) Target row to insert. '0' corresponds to the bottom row. Defaults to 0.
	##
	## Example: ["insert_line tiles_keys=0,1"]
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("tiles_key"):
			tiles_keys = [new_config["tiles_key"]]
		if new_config.has("tiles_keys"):
			tiles_keys = new_config["tiles_keys"].split(",")
		if new_config.has("y"):
			y = ConfigStringUtils.invert_puzzle_row_index(int(new_config["y"]))
		if new_config.has("count"):
			count = new_config["count"].to_int()
	
	
	func run() -> void:
		for _i in range(count):
			CurrentLevel.puzzle.get_playfield().line_inserter.insert_line(tiles_keys, y)
	
	
	func get_config() -> Dictionary:
		var result := {}
		match tiles_keys.size():
			0:
				pass
			1:
				result["tiles_key"] = tiles_keys[0]
			_:
				result["tiles_keys"] = PoolStringArray(tiles_keys).join(",")
		if y != PuzzleTileMap.ROW_COUNT - 1:
			result["y"] = str(ConfigStringUtils.invert_puzzle_row_index(y))
		if count != 1:
			result["count"] = str(count)
		return result


var effects_by_string := {
	"add_carrots": AddCarrotsEffect,
	"add_moles": AddMolesEffect,
	"add_onion": AddOnionEffect,
	"add_sharks": AddSharksEffect,
	"add_spears": AddSpearsEffect,
	"advance_moles": AdvanceMolesEffect,
	"advance_onion": AdvanceOnionEffect,
	"advance_sharks": AdvanceSharksEffect,
	"advance_spears": AdvanceSpearsEffect,
	"clear_filled_lines": ClearFilledLinesEffect,
	"remove_carrots": RemoveCarrotsEffect,
	"remove_onion": RemoveOnionEffect,
	"remove_spears": RemoveSpearsEffect,
	"rotate_next_pieces": RotateNextPiecesEffect,
	"insert_line": InsertLineEffect,
}


## Creates a new LevelTriggerEffect instance.
##
## Parameters:
## 	'effect_key': A string key corresponding to the level trigger effect, such as 'insert_line'.
##
## 	'effect_config': (Optional) Array of strings defining the effect's behavior.
func create(effect_key: String, effect_config: Dictionary = {}) -> LevelTriggerEffect:
	if not effects_by_string.has(effect_key):
		push_warning("Unrecognized effect: %s" % [effect_key])
	var effect_script: GDScript = effects_by_string.get(effect_key)
	var effect: LevelTriggerEffect = effect_script.new()
	if effect_config:
		effect.set_config(effect_config)
	return effect


func effect_key(effect: LevelTriggerEffect) -> String:
	return effects_by_string.keys()[effects_by_string.values().find(effect.get_script())]
