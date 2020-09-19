extends Control
"""
Keeps children controls positioned correctly.

A more versatile version of Godot's 'CenterContainer' class. CenterContainer keeps children controls centered, but
this container keeps aligns children controls in several possible layouts.
"""

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

# The position to apply to the children controls
export (Layout) var layout := Layout.CENTER_TOP

func _ready() -> void:
	for child_obj in get_children():
		var child: Control = child_obj
		child.connect("resized", self, "_on_Child_Control_resized", [child])


"""
Realigns child controls when they are resized.
"""
func _on_Child_Control_resized(child: Node) -> void:
	# align child vertically
	match layout:
		Layout.TOP_LEFT, Layout.TOP_RIGHT, Layout.CENTER_TOP:
			child.rect_position.y = 0
		Layout.CENTER_LEFT, Layout.CENTER_RIGHT, Layout.CENTER:
			child.rect_position.y = 0.5 * (rect_size.y - child.rect_size.y)
		Layout.BOTTOM_RIGHT, Layout.BOTTOM_LEFT, Layout.CENTER_BOTTOM:
			child.rect_position.y = rect_size.y - child.rect_size.y
	
	# align child horizontally
	match layout:
		Layout.TOP_LEFT, Layout.BOTTOM_LEFT, Layout.CENTER_LEFT:
			child.rect_position.x = 0
		Layout.CENTER_TOP, Layout.CENTER_BOTTOM, Layout.CENTER:
			child.rect_position.x = 0.5 * (rect_size.x - child.rect_size.x)
		Layout.TOP_RIGHT, Layout.BOTTOM_RIGHT, Layout.CENTER_RIGHT:
			child.rect_position.x = rect_size.x - child.rect_size.x
