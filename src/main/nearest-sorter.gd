class_name NearestSorter
"""
Sorts an array's values by proximity to a specified value.
"""

var _target_value

"""
Sorts an array's values by proximity to a specified value.

Example:
	input: [1, 2, 4, 5, 7, 8, 10]
	target_value: [4]
	result: [4, 5, 2, 1, 7, 8, 10]
"""
func sort(values: Array, target_value: float) -> void:
	_target_value = target_value
	values.sort_custom(self, "compare")


func compare(a: float, b: float) -> bool:
	return abs(a - _target_value) < abs(b - _target_value)
