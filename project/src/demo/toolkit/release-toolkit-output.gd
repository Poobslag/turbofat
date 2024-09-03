class_name ReleaseToolkitOutput
extends Label
## Shows the result of various release toolkit operations.

func clear() -> void:
	text = ""


## Appends text to this label on a new line.
func add_line(line: String) -> void:
	if text:
		text += "\n"
	text += line
