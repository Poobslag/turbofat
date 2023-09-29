class_name SpearConfig
## Rules for spears on a specific level.

## Default value for the 'sizes' parameter. If unspecified, spears appear randomly from the left and right side.
const DEFAULT_SIZES := ["x4"]

## how many spears appear during a single 'add spears' effect
var count: int = 1

## how many turns/seconds/cycles the spears emerge for, or '-1' if they should emerge indefinitely
var duration: int = -1

# how many turns/seconds/cycles the spears wait for, or '0' if they should emerge immediately
var wait: int = 2

## which rows the spears appear on
var lines: Array = []

## List of String sizes, like 'x5', 'l3', 'l2r4' or 'R8'
##
## Examples:
## 	x5: a (5) length spear which comes from a random direction
## 	l3: a (3) length spear which comes from the (l)eft
## 	l2r4: A pair of (2) and (4) length spears which come from the (l)eft and (r)ight
## 	R8: A wide 8-length spear which comes from the right
##
## The letters 'l' and 'r' refer to spears emerging from the left or right sides. Capital letters are used for wide
## spears. The number corresponds to the spear's length in cells.
##
## If multiple sizes are specified, the game will avoid picking the same one twice in a row.
var sizes: Array = DEFAULT_SIZES

## Returns true if the specified size string corresponds to a wide spear.
##
## A size string like 'R8' corresponds to a wide spear because it contains an upper-case letter.
static func is_wide(size_string: String) -> bool:
	return size_string != size_string.to_lower()
