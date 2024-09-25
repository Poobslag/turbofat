class_name BarGraphBar
extends Control
## Bar shown in the results screen's bar graph.
##
## The bar graph includes several of these bar nodes stacked on top of each other.

func _ready() -> void:
	connect("resized", self, "_on_resized")
	_refresh_node_size()


## When the node is resized, we update the shader so that textures are scaled appropriately.
func _refresh_node_size() -> void:
	material.set_shader_param("node_size", rect_size)


func _on_resized() -> void:
	_refresh_node_size()
