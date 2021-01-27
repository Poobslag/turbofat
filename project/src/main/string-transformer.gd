class_name StringTransformer
"""
Applies a series of regex transformations.
"""

# the transformed string
var transformed: String

# the regex instance which performs the transformations
var _regex := RegEx.new()

"""
Parameters:
	's': The string to be transformed.
"""
func _init(s: String) -> void:
	transformed = s

"""
Apply a regex transformation.
"""
func sub(pattern: String, replacement: String) -> void:
	_regex.compile(pattern)
	transformed = _regex.sub(transformed, replacement, true)
