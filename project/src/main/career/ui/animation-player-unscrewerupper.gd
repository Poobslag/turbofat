## Prevents Controls used by AnimationPlayers from randomly changing their position and size.
##
## Workaround for Godot #90079 (https://github.com/godotengine/godot/issues/90079). Godot has an exciting feature
## where Controls animated by an AnimationPlayer randomly change their position or size. This only affects the editor,
## and results an exciting and fun surprise for developers. But for developers who don't like excitement or fun, this
## node can be added to an AnimationPlayer to forcibly reset the control to reset its position.
##
## To use this node, add it as the child of an AnimationPlayer.
tool
extends Node

## Manually reset Control nodes affected by our parent AnimationPlayer.
export (bool) var _unscrewup: bool setget unscrewup

onready var animation_player: AnimationPlayer = get_parent()

func _ready() -> void:
	if Engine.editor_hint:
		unscrewup()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	animation_player = get_parent()


func unscrewup(_value: bool = false) -> void:
	if Engine.editor_hint:
		animation_player.play("RESET")
