class_name PuzzleConnect
## Map integers such as '14' to puzzle autotile coordinates such as 'LEFT | RIGHT | DOWN'
##
## This is useful for tiles which are arranged so that the X coordinates of the tiles correspond to the directions
## they're connected. This type of tilemap is used for puzzle pieces.

## Constants used when drawing tiles which are connected to other tiles. These serve a similar purpose to the
## TileSet.BIND_TOP constants, but with smaller values.
const UP := 1
const DOWN := 2
const LEFT := 4
const RIGHT := 8

## functions which return true if a specific directional bitmask is set
static func is_u(input: int) -> bool: return input & UP > 0
static func is_d(input: int) -> bool: return input & DOWN > 0
static func is_l(input: int) -> bool: return input & LEFT > 0
static func is_r(input: int) -> bool: return input & RIGHT > 0

## functions which enable a specific directional bitmask
static func set_u(input: int) -> int: return input | UP
static func set_d(input: int) -> int: return input | DOWN
static func set_l(input: int) -> int: return input | LEFT
static func set_r(input: int) -> int: return input | RIGHT
static func set_dirs(input: int, bitmask: int) -> int: return input | bitmask

## functions which disable a specific directional bitmask
static func unset_u(input: int) -> int: return input & ~UP
static func unset_d(input: int) -> int: return input & ~DOWN
static func unset_l(input: int) -> int: return input & ~LEFT
static func unset_r(input: int) -> int: return input & ~RIGHT
static func unset_dirs(input: int, bitmask: int) -> int: return input & ~bitmask
