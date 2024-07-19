extends Label
## Label which shows the currently selected category, such as "Eyes"
##
## This script shifts the label and refreshes its text as the category changes.

export (NodePath) var category_selector_path: NodePath

var _tween: SceneTreeTween

onready var _category_selector: CategorySelector = get_node(category_selector_path)
onready var _accent := $MenuAccentH3
onready var _creature_editor_library := Global.get_creature_editor_library()

func _ready() -> void:
	# Workaround for Godot #20623 (https://github.com/godotengine/godot/issues/20623)
	#
	# Adjusting a centered label's position dynamically as its text changes can be challenging. The new text may
	# cause the label to widen, but this change can occur over 1 or 2 frames, or sometimes not at all. Waiting for
	# too many frames may cause visual jitter as the label is rendered before it is shifted. Waiting for too few
	# frames can result in the label being positioned incorrectly.
	#
	# To avoid these issues, the label is preemptively widened.
	rect_size.x = 1024


func _on_CategorySelector_category_selected(category: int) -> void:
	# update text
	text = _creature_editor_library.get_name_by_category_index(category, tr("???"))
	
	# update accent
	_accent.refresh()
	
	# tween the x coordinate to its new value
	var category_selector_relative_position: Vector2 = \
			_category_selector.get_global_transform().origin - get_parent().get_global_transform().origin
	var new_x := category_selector_relative_position.x + 212 + 40 * category - rect_size.x * 0.5
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "rect_position:x", new_x, 0.1) \
			.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
