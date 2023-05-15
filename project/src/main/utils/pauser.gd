extends Node
## Emits signals when the scene tree is paused or unpaused.

## emitted when the scene tree is paused or unpaused
signal paused_changed(value)

var _paused: bool

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if get_tree().paused != _paused:
		_paused = get_tree().paused
		emit_signal("paused_changed", _paused)
