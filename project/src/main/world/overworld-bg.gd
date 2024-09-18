tool
class_name OverworldBg
extends CanvasLayer
## Draws the background behind overworld scenes.

## If 'true', the background shows a scrolling outer space texture. If 'false', the background is blank.
export (bool) var outer_space_visible: bool = false setget set_outer_space_visible

onready var _outer_space := $OuterSpace

func _ready() -> void:
	_refresh_outer_space_visible()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_outer_space = $OuterSpace


func set_outer_space_visible(new_outer_space_visible: bool) -> void:
	outer_space_visible = new_outer_space_visible
	_refresh_outer_space_visible()


func _refresh_outer_space_visible() -> void:
	if not is_inside_tree():
		return
	
	_outer_space.visible = outer_space_visible
