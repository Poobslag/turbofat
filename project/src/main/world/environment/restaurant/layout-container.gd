extends Control
## Keeps children controls positioned correctly.
##
## More versatile version of Godot's 'CenterContainer' class. CenterContainer keeps children controls centered, but
## this container keeps aligns children controls in several possible layouts.

enum Layout {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
	
	CENTER_LEFT,
	CENTER_TOP,
	CENTER_RIGHT,
	CENTER_BOTTOM,
	
	CENTER,
}

## Position to apply to the children controls
@export var layout := Layout.CENTER_TOP

func _ready() -> void:
	for child_obj in get_children():
		var child: Control = child_obj
		child.resized.connect(_on_Child_Control_resized.bind(child))


## Realigns child controls when they are resized.
func _on_Child_Control_resized(child: Node) -> void:
	# align child vertically
	match layout:
		Layout.TOP_LEFT, Layout.TOP_RIGHT, Layout.CENTER_TOP:
			child.position.y = 0
		Layout.CENTER_LEFT, Layout.CENTER_RIGHT, Layout.CENTER:
			child.position.y = 0.5 * (size.y - child.size.y)
		Layout.BOTTOM_RIGHT, Layout.BOTTOM_LEFT, Layout.CENTER_BOTTOM:
			child.position.y = size.y - child.size.y
	
	# align child horizontally
	match layout:
		Layout.TOP_LEFT, Layout.BOTTOM_LEFT, Layout.CENTER_LEFT:
			child.position.x = 0
		Layout.CENTER_TOP, Layout.CENTER_BOTTOM, Layout.CENTER:
			child.position.x = 0.5 * (size.x - child.size.x)
		Layout.TOP_RIGHT, Layout.BOTTOM_RIGHT, Layout.CENTER_RIGHT:
			child.position.x = size.x - child.size.x
