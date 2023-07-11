extends HBoxContainer
## UI input for specifying the cutscene to open

## Emitted when the player toggles between picking a valid/invalid chat path.
signal valid_changed

## Possible chat key root paths to toggle between based on the chosen cutscene.
const CHAT_KEY_ROOT_PATHS := [
	"res://assets/demo",
	"res://assets/main",
	"res://assets/test",
]

## Cutscene to open
## Virtual property; value is only exposed through getters/setters
var value: String setget set_value, get_value

## False if the player selects an invalid chat path.
##
## Invalid chat path could be a file which doesn't exist, doesn't have the correct suffix, or isn't in the
## expected location.
var valid: bool setget ,is_valid

onready var _line_edit := $LineEdit

func is_valid() -> bool:
	return valid


func set_value(new_value: String) -> void:
	_line_edit.text = new_value
	_validate()


func get_value() -> String:
	return _line_edit.text


## Validates that our LineEdit text corresponds to a valid chat path.
func _validate() -> void:
	var old_valid := valid
	valid = true
	
	# validate that the file exists
	if not FileUtils.file_exists(_line_edit.text):
		valid = false
	
	# validate that the file has the correct suffix
	if not _line_edit.text.ends_with(ChatLibrary.CHAT_EXTENSION):
		valid = false
	
	# validate that the file is in a predefined chat key root path
	if valid:
		var chat_key_root_path: String
		for potential_chat_key_root_path in CHAT_KEY_ROOT_PATHS:
			if _line_edit.text.begins_with(potential_chat_key_root_path):
				chat_key_root_path = potential_chat_key_root_path
				break
		
		if chat_key_root_path:
			ChatLibrary.chat_key_root_path = chat_key_root_path
		else:
			valid = false
	
	if valid != old_valid:
		emit_signal("valid_changed")
