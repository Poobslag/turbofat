extends Node
## Enables keyboard and controller inputs for a TabContainer.
##
## Workaround for Godot #25877 (https://github.com/godotengine/godot/issues/25877) to implement navigating a
## TabContainer's tabs with keyboard or controller inputs.

## Columns of focusable nodes below our TabContainer.
##
## The first visible node of each of these arrays will have its its focus_neighbor_top assigned our TabContainer, so
## that the player can arrow up into our TabContainer from the nodes below.
export (Array, Array, NodePath) var focusable_nodes_below: Array = []

## 'true' if our TabContainer is focused.
var focused: bool = false setget set_focused

onready var tab_container := get_parent()

func _ready() -> void:
	tab_container.focus_mode = Control.FOCUS_ALL
	tab_container.connect("tab_changed", self, "_on_tab_changed")
	tab_container.get_viewport().connect("gui_focus_changed", self, "_on_Viewport_gui_focus_changed")
	
	_refresh_focused()
	_refresh_focus_neighbours_for_current_tab()


## Handle left/right inputs while the TabContainer is focused.
func _unhandled_input(event: InputEvent) -> void:
	if not focused:
		return
	
	if event.is_action_pressed("ui_left"):
		tab_container.current_tab = clamp(tab_container.current_tab - 1, 0, tab_container.get_child_count())
	
	if event.is_action_pressed("ui_right"):
		tab_container.current_tab = clamp(tab_container.current_tab + 1, 0, tab_container.get_child_count())


## Refreshes our tab's appearance based on whether or not we're currently focused.
##
## If we're currently focused, the current tab is drawn with a cyan highlighted appearance to give feedback to the
## player.
func set_focused(new_focused: bool) -> void:
	if focused == new_focused:
		return
	focused = new_focused
	
	_refresh_focused()


## Updates the focus_neighbor fields for the TabContainer, its children, and its neighbours.
##
## Assigns all of the focus_neighbor fields to accomplish the following:
##
## 	1. Navigating down from the TabContainer focuses the top item within the TabContainer.
##
## 	2. Navigating down from the bottom item within the TabContainer focuses the top item below the TabContainer.
## 	Godot does this for us automatically.
##
## 	3. Navigating up from the top item within the TabContainer focuses the TabContainer.
##
## 	4. Navigating up from the top item below the TabContainer focuses the bottom item in the TabContainer.
func _refresh_focus_neighbours_for_current_tab() -> void:
	if tab_container.current_tab == -1:
		return
	
	var top_focusable_node: Control = _find_control_by_func(
			tab_container.get_child(tab_container.current_tab), self, "_compare_by_min_y")
	
	var bottom_focusable_node: Control = _find_control_by_func(
			tab_container.get_child(tab_container.current_tab), self, "_compare_by_max_y")
	
	## Navigating down from the TabContainer focuses the top item within the TabContainer.
	tab_container.focus_neighbour_bottom = top_focusable_node.get_path()
	
	## Navigating up from the top item within the TabContainer focuses the TabContainer.
	if top_focusable_node:
		top_focusable_node.focus_neighbour_top = tab_container.get_path()
	
	## Navigating up from the top item below the TabContainer focuses the bottom item in the TabContainer.
	for nodes_in_column in focusable_nodes_below:
		var highest_node_in_column: Control
		for node_below_path in nodes_in_column:
			var node_below: Control = get_node(node_below_path)
			if node_below.visible and node_below.focus_mode == Control.FOCUS_ALL:
				highest_node_in_column = node_below
				break
		
		if highest_node_in_column:
			highest_node_in_column.focus_neighbour_top = bottom_focusable_node.get_path()


## Searches through all of a node's descendents for the best visible Control according to a custom method.
##
## We use this method to search for the highest or lowest visible child.
##
## Parameters:
## 	'parent': The parent node to search.
##
## 	'object': The object containing the comparator
##
## 	'method': The method which performs comparisons. The method receives two arguments (a pair of elements from the
## 		array) and must return either true or false. If the given method returns true, element 'a' will be
## 		returned. Otherwise, element 'b' will be returned.
func _find_control_by_func(parent: Node, object: Object, method: String) -> Node:
	# the best match for the specified custom method
	var best_child: Node
	
	# recursively descend through the children and grandchildren
	var node_queue := parent.get_children()
	while not node_queue.empty():
		var node := node_queue.pop_back() as Node
		if node is Control and not node.visible:
			# ignore invisible controls and their children
			continue
		node_queue.append_array(node.get_children())
		if node is Control and object.call(method, node, best_child):
			# update the best match
			best_child = node
	
	return best_child


## Custom comparator method to find the highest focusable control.
func _compare_by_min_y(a: Control, b: Control) -> bool:
	if a == null or b == null:
		return a != null
	if a.focus_mode != Control.FOCUS_ALL or b.focus_mode != Control.FOCUS_ALL:
		return a.focus_mode == Control.FOCUS_ALL
	
	return a.get_global_rect().position.y <= b.get_global_rect().position.y


## Custom comparator method to find the lowest focusable control.
func _compare_by_max_y(a: Control, b: Control) -> bool:
	if a == null or b == null:
		return a != null
	if a.focus_mode != Control.FOCUS_ALL or b.focus_mode != Control.FOCUS_ALL:
		return a.focus_mode == Control.FOCUS_ALL
	
	return a.get_global_rect().position.y >= b.get_global_rect().position.y


## Refreshes our TabContainer's colors based on whether it's focused or not.
func _refresh_focused() -> void:
	if focused:
		tab_container.set("custom_colors/font_color_fg", Color("f0f0f0"))
		tab_container.get("custom_styles/tab_fg").bg_color = Color("2d5e73")
	else:
		tab_container.set("custom_colors/font_color_fg", null)
		tab_container.get("custom_styles/tab_fg").bg_color = Color("332d2d")


func _on_tab_changed(_tab: int) -> void:
	_refresh_focus_neighbours_for_current_tab()


func _on_Viewport_gui_focus_changed(node: Control) -> void:
	set_focused(node == tab_container)
