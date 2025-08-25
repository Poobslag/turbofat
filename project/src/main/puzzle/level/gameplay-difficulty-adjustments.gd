class_name GameplayDifficultyAdjustments
## Adjusts piece speeds and level durations based on the player's gameplay speed settings.
##
## This is specifically used for cheats where the player can make the pieces fall slower or faster. To speed up and
## slow down pieces, we adjust all drop speeds by a fixed percent. This doesn't have a significant effect on instant
## gravity levels however (50% of 20G is still 10G which is way too fast for a novice) so this script defines mappings
## to adjust piece speeds based on the player's gameplay speed settings.

## key: (int) enum from DifficultyData.Speed
## value: (float) multiplier for score milestones. 0.5 = level is twice as short, 2.0 = level is twice as long
const SCORE_MILESTONE_FACTOR_BY_GAMEPLAY_SPEED := {
	DifficultyData.Speed.SLOW: 0.70,
	DifficultyData.Speed.SLOWER: 0.40,
	DifficultyData.Speed.SLOWEST: 0.20,
	DifficultyData.Speed.SLOWESTEST: 0.10,
}

## key: (int) enum from DifficultyData.Speed
## value: (float) multiplier for line milestones. 0.5 = level is twice as short, 2.0 = level is twice as long
const LINE_MILESTONE_FACTOR_BY_GAMEPLAY_SPEED := {
	DifficultyData.Speed.SLOW: 0.85,
	DifficultyData.Speed.SLOWER: 0.70,
	DifficultyData.Speed.SLOWEST: 0.40,
	DifficultyData.Speed.SLOWESTEST: 0.20,
}

## key: (int) enum from DifficultyData.Speed
## value: (float) multiplier for duration milestones. 0.5 = level is twice as short, 2.0 = level is twice as long
const TIME_OVER_MILESTONE_FACTOR_BY_GAMEPLAY_SPEED := {
	DifficultyData.Speed.SLOW: 1.00,
	DifficultyData.Speed.SLOWER: 0.90,
	DifficultyData.Speed.SLOWEST: 0.70,
	DifficultyData.Speed.SLOWESTEST: 0.40,
}

## key: (int) enum from DifficultyData.Speed
## value: (float) multiplier for duration milestones. 0.5 = level is twice as short, 2.0 = level is twice as long
const TIME_UNDER_MILESTONE_FACTOR_BY_GAMEPLAY_SPEED := {
	DifficultyData.Speed.SLOW: 1.00,
	DifficultyData.Speed.SLOWER: 1.11,
	DifficultyData.Speed.SLOWEST: 1.43,
	DifficultyData.Speed.SLOWESTEST: 2.50,
}

## key: (int) enum from DifficultyData.Speed
## value: (Dictionary) mapping from piece speed strings to adjusted piece speed strings
const PIECE_SPEED_MAPPING_BY_GAMEPLAY_SPEED := {
	# pieces are literally always at the fastest 20G speed
	DifficultyData.Speed.FASTESTEST: {
		"T": "FFF",

		"0": "FFF",
		"1": "FFF",
		"2": "FFF",
		"3": "FFF",
		"4": "FFF",
		"5": "FFF",
		"6": "FFF",
		"7": "FFF",
		"8": "FFF",
		"9": "FFF",

		"A0": "FFF",
		"A1": "FFF",
		"A2": "FFF",
		"A3": "FFF",
		"A4": "FFF",
		"A5": "FFF",
		"A6": "FFF",
		"A7": "FFF",
		"A8": "FFF",
		"A9": "FFF",

		"AA": "FFF",
		"AB": "FFF",
		"AC": "FFF",
		"AD": "FFF",
		"AE": "FFF",
		"AF": "FFF",

		"F0": "FFF",
		"F1": "FFF",
		"FA": "FFF",
		"FB": "FFF",
		"FC": "FFF",
		"FD": "FFF",
		"FE": "FFF",
		"FF": "FFF",
		"FFF": "FFF",
	},
	
	# pieces fall much much faster (the slowest speed is F1)
	DifficultyData.Speed.FASTEST: {
		"T": "T",

		"0": "F0",
		"1": "F1",
		"2": "F1",
		"3": "F1",
		"4": "F1",
		"5": "F1",
		"6": "F1",
		"7": "F1",
		"8": "F1",
		"9": "F1",

		"A0": "F0",
		"A1": "FA",
		"A2": "FA",
		"A3": "FA",
		"A4": "FB",
		"A5": "FB",
		"A6": "FB",
		"A7": "FC",
		"A8": "FC",
		"A9": "FC",

		"AA": "FD",
		"AB": "FD",
		"AC": "FE",
		"AD": "FE",
		"AE": "FF",
		"AF": "FF",

		"F0": "F0",
		"F1": "FFF",
		"FA": "FFF",
		"FB": "FFF",
		"FC": "FFF",
		"FD": "FFF",
		"FE": "FFF",
		"FF": "FFF",
		"FFF": "FFF",
	},
	
	# pieces fall much faster (the slowest speed is A1)
	DifficultyData.Speed.FASTER: {
		"T": "T",

		"0": "A0",
		"1": "A1",
		"2": "A1",
		"3": "A1",
		"4": "A2",
		"5": "A2",
		"6": "A3",
		"7": "A3",
		"8": "A4",
		"9": "A4",

		"A0": "A0",
		"A1": "A5",
		"A2": "A5",
		"A3": "A6",
		"A4": "A6",
		"A5": "A7",
		"A6": "A7",
		"A7": "A8",
		"A8": "A8",
		"A9": "A9",

		"AA": "AA",
		"AB": "AB",
		"AC": "AC",
		"AD": "AD",
		"AE": "AE",
		"AF": "AF",

		"F0": "F0",
		"F1": "F1",
		"FA": "FA",
		"FB": "FB",
		"FC": "FC",
		"FD": "FD",
		"FE": "FE",
		"FF": "FF",
		"FFF": "FFF",
	},
	
	# pieces fall faster (the slowest speed is 5)
	DifficultyData.Speed.FAST: {
		"T": "T",

		"0": "5",
		"1": "5",
		"2": "6",
		"3": "6",
		"4": "7",
		"5": "7",
		"6": "8",
		"7": "8",
		"8": "9",
		"9": "9",

		"A0": "A0",
		"A1": "A1",
		"A2": "A2",
		"A3": "A3",
		"A4": "A4",
		"A5": "A5",
		"A6": "A6",
		"A7": "A7",
		"A8": "A8",
		"A9": "A9",

		"AA": "AA",
		"AB": "AB",
		"AC": "AC",
		"AD": "AD",
		"AE": "AE",
		"AF": "AF",

		"F0": "F0",
		"F1": "F1",
		"FA": "FA",
		"FB": "FB",
		"FC": "FC",
		"FD": "FD",
		"FE": "FE",
		"FF": "FF",
		"FFF": "FFF",
	},
	
	DifficultyData.Speed.DEFAULT: {
		"T": "T",

		"0": "0",
		"1": "1",
		"2": "2",
		"3": "3",
		"4": "4",
		"5": "5",
		"6": "6",
		"7": "7",
		"8": "8",
		"9": "9",

		"A0": "A0",
		"A1": "A1",
		"A2": "A2",
		"A3": "A3",
		"A4": "A4",
		"A5": "A5",
		"A6": "A6",
		"A7": "A7",
		"A8": "A8",
		"A9": "A9",

		"AA": "AA",
		"AB": "AB",
		"AC": "AC",
		"AD": "AD",
		"AE": "AE",
		"AF": "AF",

		"F0": "F0",
		"F1": "F1",
		"FA": "FA",
		"FB": "FB",
		"FC": "FC",
		"FD": "FD",
		"FE": "FE",
		"FF": "FF",
		"FFF": "FFF",
	},
	
	# pieces fall slower (the fastest speed is AA)
	DifficultyData.Speed.SLOW: {
		"T": "T",

		"0": "0",
		"1": "1",
		"2": "2",
		"3": "3",
		"4": "4",
		"5": "5",
		"6": "6",
		"7": "7",
		"8": "8",
		"9": "9",

		"A0": "A0",
		"A1": "A1",
		"A2": "A2",
		"A3": "A3",
		"A4": "A4",
		"A5": "A5",
		"A6": "A6",
		"A7": "A6",
		"A8": "A7",
		"A9": "A7",

		"AA": "A8",
		"AB": "A8",
		"AC": "A9",
		"AD": "A9",
		"AE": "AA",
		"AF": "AA",

		"F0": "A0",
		"F1": "AA",
		"FA": "AA",
		"FB": "AA",
		"FC": "AA",
		"FD": "AA",
		"FE": "AA",
		"FF": "AA",
		"FFF": "AA",
	},
	
	# pieces fall much slower (the fastest speed is 9)
	DifficultyData.Speed.SLOWER: {
		"T": "T",

		"0": "0",
		"1": "1",
		"2": "2",
		"3": "3",
		"4": "4",
		"5": "5",
		"6": "6",
		"7": "7",
		"8": "8",
		"9": "9",

		"A0": "0",
		"A1": "9",
		"A2": "9",
		"A3": "9",
		"A4": "9",
		"A5": "9",
		"A6": "9",
		"A7": "9",
		"A8": "9",
		"A9": "9",

		"AA": "9",
		"AB": "9",
		"AC": "9",
		"AD": "9",
		"AE": "9",
		"AF": "9",

		"F0": "0",
		"F1": "9",
		"FA": "9",
		"FB": "9",
		"FC": "9",
		"FD": "9",
		"FE": "9",
		"FF": "9",
		"FFF": "9",
	},
	
	# pieces fall much much slower (the fastest speed is 7)
	DifficultyData.Speed.SLOWEST: {
		"T": "T",

		"0": "0",
		"1": "0",
		"2": "1",
		"3": "1",
		"4": "2",
		"5": "3",
		"6": "4",
		"7": "5",
		"8": "6",
		"9": "7",

		"A0": "0",
		"A1": "7",
		"A2": "7",
		"A3": "7",
		"A4": "7",
		"A5": "7",
		"A6": "7",
		"A7": "7",
		"A8": "7",
		"A9": "7",

		"AA": "7",
		"AB": "7",
		"AC": "7",
		"AD": "7",
		"AE": "7",
		"AF": "7",

		"F0": "0",
		"F1": "7",
		"FA": "7",
		"FB": "7",
		"FC": "7",
		"FD": "7",
		"FE": "7",
		"FF": "7",
		"FFF": "7",
	},
	
	# pieces literally don't fall
	DifficultyData.Speed.SLOWESTEST: {
		"T": "T",

		"0": "T",
		"1": "T",
		"2": "T",
		"3": "T",
		"4": "T",
		"5": "T",
		"6": "T",
		"7": "T",
		"8": "T",
		"9": "T",

		"A0": "T",
		"A1": "T",
		"A2": "T",
		"A3": "T",
		"A4": "T",
		"A5": "T",
		"A6": "T",
		"A7": "T",
		"A8": "T",
		"A9": "T",

		"AA": "T",
		"AB": "T",
		"AC": "T",
		"AD": "T",
		"AE": "T",
		"AF": "T",

		"F0": "T",
		"F1": "T",
		"FA": "T",
		"FB": "T",
		"FC": "T",
		"FD": "T",
		"FE": "T",
		"FF": "T",
		"FFF": "T",
	},
}


## Adjusts the finish milestone based on the current gameplay settings.
##
## When the player plays at slow speeds, we make milestones easier to reach.
static func adjust_milestones(settings: LevelSettings) -> void:
	if not _is_piece_speed_cheat_enabled(settings):
		# Don't adjust milestones for tutorials. Some tutorials require the player to place 3 pieces, shortening it to
		# 2 pieces would ruin the tutorial
		return
	
	match settings.finish_condition.type:
		Milestone.LINES:
			adjust_line_finish(settings)
		Milestone.PIECES:
			adjust_piece_finish(settings)
		Milestone.SCORE:
			adjust_score_finish(settings)
		Milestone.TIME_OVER:
			adjust_time_over_finish(settings)


## Adjusts a piece speed based on the player's gameplay speed settings.
##
## Parameters:
## 	'piece_speed_string': An unmodified piece speed string such as '0' or 'A9'
##
## Returns:
## 	A modified piece speed string such as '0' or 'A9'
static func adjust_piece_speed(settings: LevelSettings, piece_speed_string: String) -> String:
	if not _is_piece_speed_cheat_enabled(settings):
		return piece_speed_string
	var adjusted_speed_by_piece_speed: Dictionary = \
			PIECE_SPEED_MAPPING_BY_GAMEPLAY_SPEED.get(PlayerData.difficulty.speed, {})
	return adjusted_speed_by_piece_speed.get(piece_speed_string, piece_speed_string)


## Adjusts a score milestone value based on the player's gameplay speed settings.
##
## When the player plays at slow speeds, we make milestones easier to reach.
static func adjust_score_finish(settings: LevelSettings) -> void:
	if not _is_piece_speed_cheat_enabled(settings):
		return
	var score_milestone_factor: float = \
			SCORE_MILESTONE_FACTOR_BY_GAMEPLAY_SPEED.get(PlayerData.difficulty.speed, 1.0)
	settings.finish_condition.value = int(ceil(settings.finish_condition.value * score_milestone_factor))


## Adjusts a line milestone value based on the player's gameplay speed settings.
##
## When the player plays at slow speeds, we make milestones easier to reach.
static func adjust_line_finish(settings: LevelSettings) -> void:
	if not _is_piece_speed_cheat_enabled(settings):
		return
	var line_milestone_factor: float = \
			LINE_MILESTONE_FACTOR_BY_GAMEPLAY_SPEED.get(PlayerData.difficulty.speed, 1.0)
	settings.finish_condition.value = int(ceil(settings.finish_condition.value * line_milestone_factor))


## Adjusts a piece milestone value based on the player's gameplay speed settings.
##
## When the player plays at slow speeds, we make milestones easier to reach.
static func adjust_piece_finish(settings: LevelSettings) -> void:
	if not _is_piece_speed_cheat_enabled(settings):
		return
	var piece_milestone_factor: float = \
			LINE_MILESTONE_FACTOR_BY_GAMEPLAY_SPEED.get(PlayerData.difficulty.speed, 1.0)
	settings.finish_condition.value = int(ceil(settings.finish_condition.value * piece_milestone_factor))


## Adjusts a duration milestone value based on the player's gameplay speed settings.
##
## When the player plays at very slow speeds, we make milestones easier to reach.
static func adjust_time_over_finish(settings: LevelSettings) -> void:
	if not _is_piece_speed_cheat_enabled(settings):
		return
	var time_over_milestone_factor: float = \
			TIME_OVER_MILESTONE_FACTOR_BY_GAMEPLAY_SPEED.get(PlayerData.difficulty.speed, 1.0)
	settings.finish_condition.value = int(ceil(settings.finish_condition.value * time_over_milestone_factor))


static func _is_piece_speed_cheat_enabled(settings: LevelSettings) -> bool:
	return PlayerData.difficulty.speed != DifficultyData.Speed.DEFAULT and not settings.other.tutorial
