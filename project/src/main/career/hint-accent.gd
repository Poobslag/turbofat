tool
extends Panel
## Brown accent which appears behind the career hint label.
##
## This node's parent should always be a Label instance.

export (bool) var _refresh: bool setget refresh

onready var _parent: Label = get_parent()

func _ready() -> void:
	refresh()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_parent = get_parent()


## Updates our texture and appearance from our label's font and text.
##
## Parameters:
## 	'_value': Ignored
func refresh(_value: bool = false) -> void:
	if not _parent:
		_initialize_onready_variables()
	
	if not _parent:
		return
	
	_refresh_accent()


## Recalculates the '_accent_width' property from our label's font and text.
func _refresh_accent() -> void:
	var shown_text := tr(_parent.text)
	var string_width := _parent.get_font("font").get_string_size(shown_text).x
	rect_size.x = string_width + 30
	rect_position.x = _parent.rect_size.x / 2 - rect_size.x / 2
