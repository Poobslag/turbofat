class_name StringTransformer
## Applies a series of regex transformations.

var transformed: String

## regex instance which performs the transformations
var _regex := RegEx.new()

## Parameters:
## 	's': The string to be transformed.
func _init(s: String) -> void:
	transformed = s

## Apply a regex transformation.
func sub(pattern: String, replacement: String) -> void:
	_regex.compile(pattern)
	transformed = _regex.sub(transformed, replacement, true)


## Perform a regex search.
func search(pattern: String) -> RegExMatch:
	_regex.compile(pattern)
	return _regex.search(transformed)
