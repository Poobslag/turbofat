class_name ConfigStringUtils
## Utilities for level config strings.

## Converts a series of ints like [2, 3, 4, 5, 7] into a config string like '2-5,7'.
##
## config_string_from_ints([2, 3, 4])       = '2-4'
## config_string_from_ints([3, 5, 7])       = '3,5,7'
## config_string_from_ints([2, 3, 4, 5, 7]) = '2-5,7'
## config_string_from_ints([7, 2, 4, 3, 5]) = '2-5,7'
## config_string_from_ints([])              = ''
##
## Parameters:
## 	'ints': A series of ints like [2, 3, 4, 5, 7].
##
## Returns:
## 	A config string like '2-5,7'
static func config_string_from_ints(ints: Array) -> String:
	if not ints:
		return ""
	
	var config_string := ""
	ints = ints.duplicate()
	ints.sort()
	
	var range_start: int = ints[0]
	for i in range(ints.size()):
		var include_next: bool = i < ints.size() - 1 and ints[i + 1] == ints[i] + 1
		
		if not include_next:
			var range_end: int = ints[i]
			if config_string:
				config_string += ","
			if range_start == range_end:
				# isolated values are output as "1,3,5"
				config_string += str(range_start)
			else:
				# adjacent values are hyphenated as "1-3, 5-9"
				config_string += "%s-%s" % [range_start, range_end]
			
			if i < ints.size() - 1:
				range_start = ints[i + 1]
	
	return config_string


## Converts a config string like '2-5,7' into a series of ints like [2, 3, 4, 5, 7].
##
## ints_from_config_string('2-4')   = [2, 3, 4]
## ints_from_config_string('3,5,7') = [3, 5, 7]
## ints_from_config_string('2-5,7') = [2, 3, 4, 5, 7]
## ints_from_config_string('7,2-5') = [2, 3, 4, 5, 7]
## ints_from_config_string('')      = []
##
## Parameters:
## 	'config_string': A config string like '2-5,7'
##
## Returns:
## 	A series of ints like [2, 3, 4, 5, 7]
static func ints_from_config_string(config_string: String) -> Array:
	if not config_string:
		return []
	
	var ints := {}
	
	for sub_expression in config_string.split(","):
		var lo: int
		var hi: int
		if "-" in sub_expression:
			lo = int(StringUtils.substring_before(sub_expression, "-"))
			hi = int(StringUtils.substring_after(sub_expression, "-")) + 1
		else:
			lo = int(sub_expression)
			hi = int(sub_expression) + 1
		for y in range(lo, hi):
			ints[y] = true
	
	var result := ints.keys()
	result.sort()
	return result


## Converts an array of user-friendly puzzle row indexes like [0, 1] into row numbers like [19, 18] or vice-versa.
##
## Our config files use coordinates where '0' is the bottom row of the playfield and '16' is the top. But our tilemap
## represents '19' as the bottom row of the playfield and '3' as the highest visible row. (There are three additional
## rows above it.)
##
## Parameters:
## 	'lines': A list of puzzle row indexes -- either indexes where '0' is the bottom row, or indexes where '19' is
## 		the bottom row.
##
## Returns:
## 	The opposite type of puzzle row indexes to the ones passed in.
static func invert_puzzle_row_indexes(lines: Array) -> Array:
	var new_lines := []
	for line in lines:
		new_lines.append(invert_puzzle_row_index(line))
	return new_lines


## Converts a user-friendly puzzle row index like 0 into row numbers like 19 or vice-versa.
##
## Our config files use coordinates where '0' is the bottom row of the playfield and '16' is the top. But our tilemap
## represents '19' as the bottom row of the playfield and '3' as the highest visible row. (There are three additional
## rows above it.)
static func invert_puzzle_row_index(line: int) -> int:
	return PuzzleTileMap.ROW_COUNT - line - 1
