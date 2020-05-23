class_name ScenarioSettings
"""
Contains settings for a 'scenario', such as trying to survive until level 100, or getting the highest score you can
get in 90 seconds.
"""

class BlocksStart:
	"""
	Blocks/boxes which begin on the playfield.
	"""
	
	var used_cells := []
	var tiles := {}
	var autotile_coords := {}
	
	"""
	Populates this object from a json dictionary.
	"""
	func from_dict(dict: Dictionary) -> void:
		if dict.has("tiles"):
			for json_tile in dict["tiles"]:
				var json_pos_arr: PoolStringArray = json_tile["pos"].split(" ")
				var json_tile_arr: PoolStringArray = json_tile["tile"].split(" ")
				var pos := Vector2(int(json_pos_arr[0]), int(json_pos_arr[1]))
				var tile := int(json_tile_arr[0])
				var autotile_coord := Vector2(int(json_tile_arr[1]), int(json_tile_arr[2]))
				set_block(pos, tile, autotile_coord)
	
	
	func set_block(pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
		used_cells.append(pos)
		tiles[pos] = tile
		autotile_coords[pos] = autotile_coord


class ComboBreakConditions:
	"""
	Things that disrupt the player's combo.
	"""
	
	var veg_row := false
	
	# unless overridden, dropping 2 pieces breaks the player's combo
	var pieces := 2
	
	"""
	Populates this object from a string array. Used for loading json data.
	"""
	func from_string_array(string_array: Array) -> void:
		for string_obj in string_array:
			var string: String = string_obj
			if string == "veg-row":
				veg_row = true
			if string.begins_with("pieces-"):
				pieces = int(StringUtils.substring_after(string, "pieces-"))


class Rank:
	"""
	Tweaks to rank calculation.
	"""
	
	var box_factor := 1.0
	var combo_factor := 1.0
	
	"""
	Populates this object from a string array. Used for loading json data.
	"""
	func from_string_array(string_array: Array) -> void:
		for string_obj in string_array:
			var string: String = string_obj
			if string.begins_with("combo-factor-"):
				var combo_factor_int := int(StringUtils.substring_after(string, "combo-factor-"))
				combo_factor = combo_factor_int * 0.01
			if string.begins_with("box-factor-"):
				var box_factor_int := int(StringUtils.substring_after(string, "box-factor-"))
				box_factor = box_factor_int * 0.01


class ScenarioPieceTypes:
	"""
	Pieces the player is given.
	"""
	
	var start_types: Array = []
	var types: Array = []
	
	func from_string_array(string_array: Array) -> void:
		var json_types: Dictionary = {
			"piece-j": PieceTypes.piece_j,
			"piece-l": PieceTypes.piece_l,
			"piece-o": PieceTypes.piece_o,
			"piece-p": PieceTypes.piece_p,
			"piece-q": PieceTypes.piece_q,
			"piece-t": PieceTypes.piece_t,
			"piece-u": PieceTypes.piece_u,
			"piece-v": PieceTypes.piece_v,
		}
		
		for string_obj in string_array:
			var string: String = string_obj
			if json_types.has(string):
				types.append(json_types[string])
			if string.begins_with("start-") and json_types.has(StringUtils.substring_after(string, "start-")):
				start_types.append(json_types[StringUtils.substring_after(string, "start-")])


class ScenarioScore:
	"""
	Rules for scoring points.
	"""
	
	var veg_points := 0
	var snack_points := 5
	var cake_points := 10
	
	func from_string_array(string_array: Array) -> void:
		for string_obj in string_array:
			var string: String = string_obj
			if string.begins_with("veg-row-"):
				veg_points = int(StringUtils.substring_after(string, "veg-row-"))
			if string.begins_with("snack-all-"):
				snack_points = int(StringUtils.substring_after(string, "snack-all-"))
			if string.begins_with("cake-all-"):
				cake_points = int(StringUtils.substring_after(string, "cake-all-"))


# Blocks/boxes which begin on the playfield.
var blocks_start := BlocksStart.new()

# Things that disrupt the player's combo.
var combo_break_conditions := ComboBreakConditions.new()

# How the player finishes. When the player finishes, they can't play anymore, and the level just ends. It should be
# used for limits such as serving 5 customers or clearing 10 lines. 
var finish_condition := Milestone.new()

# The requirements to level up and make the game harder. This mostly applies to 'Marathon Mode' where clearing lines
# makes you level up.
var level_ups := []

# The scenario name, used internally for saving/loading data.
var name := ""

# Rules which are unique enough that it doesn't make sense to put them in their own groups.
var other := []

# The selection of pieces provided to the player.
var piece_types := ScenarioPieceTypes.new()

# Tweaks to rank calculation.
var rank := Rank.new()

# Rules for scoring points.
var score_rules := ScenarioScore.new()

# How the player wins. When the player wins, there's a big fanfare and celebration, it should be used for
# accomplishments such as surviving 10 minutes or getting 1,000 points. 
var win_condition := Milestone.new()

"""
Adds criteria for leveling up, such as a time, score, or line limit.
"""
func add_level_up(type: int, value: int, level: String) -> void:
	var level_up := Milestone.new()
	level_up.type = type
	level_up.value = value
	level_up.set_meta("level", level)
	level_ups.append(level_up)


func reset() -> void:
	level_ups.clear()
	win_condition = Milestone.new()
	finish_condition = Milestone.new()
	name = ""


func set_start_level(level: String) -> void:
	level_ups.clear()
	add_level_up(Milestone.LINES, 0, level)


"""
Sets the criteria for finishing the scenario, such as a time, score, or line goal.
"""
func set_finish_condition(type: int, value: int) -> void:
	finish_condition = Milestone.new()
	finish_condition.type = type
	finish_condition.value = value


"""
Sets the criteria for winning the scenario, such as a time, score, or line goal.
"""
func set_win_condition(type: int, value: int, lenient_value: int = -1) -> void:
	win_condition = Milestone.new()
	win_condition.type = type
	win_condition.value = value
	if lenient_value > -1:
		win_condition.set_meta("lenient_value", lenient_value)


"""
Returns either the win or finish condition, whichever is defined.

If both are defined, the win condition takes precedence.
"""
func get_winish_condition() -> Milestone:
	return win_condition if win_condition.type != Milestone.NONE else finish_condition


"""
Populates this object from a dictionary. Used for loading json data.

Parameters:
	'new_name': The scenario name used for saving statistics.
"""
func from_dict(new_name: String, json: Dictionary) -> void:
	name = new_name
	set_start_level(json["start-level"])
	if json.has("blocks-start"):
		blocks_start.from_dict(json["blocks-start"])
	if json.has("combo-break"):
		combo_break_conditions.from_string_array(json["combo-break"])
	if json.has("finish-condition"):
		finish_condition.from_dict(json["finish-condition"])
	if json.has("level-ups"):
		for json_level_up in json["level-ups"]:
			var level_up := Milestone.new()
			level_up.from_dict(json_level_up)
			level_ups.append(level_up)
	if json.has("other"):
		other = json.get("other")
	if json.has("piece-types"):
		piece_types.from_string_array(json["piece-types"])
	if json.has("rank"):
		rank.from_string_array(json["rank"])
	if json.has("score"):
		score_rules.from_string_array(json["score"])
	if json.has("win-condition"):
		win_condition.from_dict(json["win-condition"])
	
