class_name ReleaseToolButton
extends Button
## Performs tasks and checks for the ReleaseToolkit.
##
## Children can override the 'run()' method to define the behavior of the release tool.

export (NodePath) var output_label_path: NodePath

## label for outputting messages to the user
onready var _output: ReleaseToolkitOutput = get_node(output_label_path)

func _ready() -> void:
	add_to_group("release_tool_buttons")


func _pressed() -> void:
	run()


## Extracts localizable strings from levels and chats and writes them to a file.
func run() -> void:
	pass
