extends Control
"""
Scene which lets the player launch tutorials.
"""

func _ready() -> void:
	ResourceCache.substitute_singletons(self)


func _exit_tree() -> void:
	ResourceCache.remove_singletons(self)


func _on_BackButton_pressed() -> void:
	Breadcrumb.pop_trail()
