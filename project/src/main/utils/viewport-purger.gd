extends Node
## Works around a Godot ViewportTexture bug by removing the textures from the scene tree.
##
## Godot crashes sometimes when freeing a node with a ViewportTexture property. To prevent this, we manually set any
## ViewportTexture properties to null before the node is freed. ViewportPurger accepts a list of viewport path
## properties relative to a particular root node. The string syntax is a NodePath followed by one or more
## colon-delimited properties.
##
## When the ViewportPurger exits the tree, it unassigns all ViewportTexture properties in its viewport_paths list.

## The node from which viewport_path references are resolved.
export (NodePath) var root := NodePath("..")

## ViewportTexture paths to remove from the tree, relative to the specified root. The string syntax is a NodePath
## followed by one or more colon-delimited properties.
##
## Examples:
##
## 	'Background:texture'
## 	'Player/Sprite2D/ShadowTexture:texture'
## 	'Environment/BgSprite:material:shader_param:goop_texture'
export (Array, String) var viewport_paths

## Removes ViewportTextures from all paths in the viewport_paths list to prevent crashes.
func _unassign_viewports() -> void:
	# locate the root_node
	if not has_node(root):
		push_error("Node not found: %s" % [root])
		return
	var root_node := get_node(root)
	
	for viewport_path in viewport_paths:
		var split_path: Array = viewport_path.split(":")
		
		# locate the node containing a ViewportTexture property
		if not root_node.has_node(split_path[0]):
			push_error("Node not found: %s/%s" % [root_node.get_path(), split_path[0]])
			continue
		var node := root_node.get_node(split_path[0])
		
		# unassign the ViewportTexture property
		if split_path.size() == 2:
			# foo/bar:baz
			node.set(split_path[1], null)
		elif split_path.size() == 4 and split_path[2] == "shader_param":
			# foo/bar:material:shader_param:baz
			node.get(split_path[1]).set_shader_param(split_path[3], null)
		else:
			push_error("Invalid viewport syntax: %s" % [viewport_path])


## When the ViewportPurger exits the tree, it unassigns all ViewportTexture properties in its viewport_paths list.
func _exit_tree() -> void:
	if Engine.editor_hint:
		return
	
	_unassign_viewports()
