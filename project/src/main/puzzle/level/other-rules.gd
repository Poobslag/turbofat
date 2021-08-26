class_name OtherRules
"""
Rules which are unique enough that it doesn't make sense to put them in their own groups.
"""

enum SuppressPieceRotation {
	NONE, # piece rotation is not suppressed
	ROTATION, # piece rotation is suppressed, but rotation signals still fire for things like sfx
	ROTATION_AND_SIGNALS # piece rotation is suppressed, no rotation signals fire for things like sfx
}

# 'true' for levels which follow tutorial levels
var after_tutorial := false

# When the player finishes the level, all lines are cleared
var clear_on_finish := true

# 'true' to make the visual combo indicators easier to see
var enhance_combo_fx := false

# 'true' for non-interactive tutorial levels which don't let the player do anything
var non_interactive := false

# an enum from SuppressPieceRotation for whether pieces can rotate
var suppress_piece_rotation: int = SuppressPieceRotation.NONE

# an enum from SuppressPieceRotation for whether pieces can be initially rotated by holding a rotate key
var suppress_piece_initial_rotation: int = SuppressPieceRotation.NONE

# When the player first launches the game and does the tutorial, we skip the start button and countdown.
var skip_intro := false

# If the player restarts, they restart from this level (used for tutorials)
var start_level: String

# an enum from PuzzleTileMap.TileSetType which affects the blocks' appearance (and sometimes behavior)
var tile_set: int = PuzzleTileMap.TileSetType.DEFAULT

# 'true' for tutorial levels which are led by Turbo
var tutorial := false

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("after_tutorial"): after_tutorial = true
	if rules.has("enhance_combo_fx"): enhance_combo_fx = true
	if rules.has("no_clear_on_finish"): clear_on_finish = false
	if rules.has("non_interactive"): non_interactive = true
	if rules.has("suppress_piece_rotation"):
		match rules.string_value():
			# rules.string_value() returns '1' if there are no parameters specified
			"1", "rotation": suppress_piece_rotation = SuppressPieceRotation.ROTATION
			"rotation_and_signals": suppress_piece_rotation = SuppressPieceRotation.ROTATION_AND_SIGNALS
			_: push_warning("Unrecognized suppress_piece_rotation: %s" % [rules.string_value()])
	if rules.has("suppress_piece_initial_rotation"):
		match rules.string_value():
			# rules.string_value() returns '1' if there are no parameters specified
			"1", "rotation": suppress_piece_initial_rotation = SuppressPieceRotation.ROTATION
			"rotation_and_signals": suppress_piece_initial_rotation = SuppressPieceRotation.ROTATION_AND_SIGNALS
			_: push_warning("Unrecognized suppress_piece_initial_rotation: %s" % [rules.string_value()])
	if rules.has("start_level"): start_level = rules.string_value()
	if rules.has("tile_set"):
		match rules.string_value():
			"default": tile_set = PuzzleTileMap.TileSetType.DEFAULT
			"veggie": tile_set = PuzzleTileMap.TileSetType.VEGGIE
			_: push_warning("Unrecognized tile_set: %s" % [rules.string_value()])
	if rules.has("tutorial"): tutorial = true
