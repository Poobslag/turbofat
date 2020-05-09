class_name Connect
"""
Map integers such as '14' to autotile coordinates such as 'LEFT | RIGHT | DOWN'
"""

# constants used when drawing tiles which are connected to other tiles
const UP := 1
const DOWN := 2
const LEFT := 4
const RIGHT := 8

# functions which return true if a specific directional bitmask is set
static func is_u(input: int) -> bool: return input & UP > 0
static func is_d(input: int) -> bool: return input & DOWN > 0
static func is_l(input: int) -> bool: return input & LEFT > 0
static func is_r(input: int) -> bool: return input & RIGHT > 0

# functions which enable a specific directional bitmask
static func set_u(input: int) -> int: return input | UP
static func set_d(input: int) -> int: return input | DOWN
static func set_l(input: int) -> int: return input | LEFT
static func set_r(input: int) -> int: return input | RIGHT

# functions which disable a specific directional bitmask
static func unset_u(input: int) -> int: return input & ~UP
static func unset_d(input: int) -> int: return input & ~DOWN
static func unset_l(input: int) -> int: return input & ~LEFT
static func unset_r(input: int) -> int: return input & ~RIGHT
