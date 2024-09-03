class_name ReleaseToolkitOutput
extends TextEdit
## Shows the result of various release toolkit operations.

var MAX_LINE_COUNT := 50

## Appends text on a new line.
func add_line(line: String) -> void:
	if text:
		text += "\n"
	text += line
	
	# enforce MAX_LINE_COUNT
	while get_line_count() > MAX_LINE_COUNT:
		text = text.substr(text.find("\n") + 1)
	
	# scroll to the bottom of the TextEdit
	cursor_set_line(get_line_count())
