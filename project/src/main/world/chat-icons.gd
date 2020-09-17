class_name ChatIcons
extends Node2D
"""
Creates and initializes chat icons for all chattables in the scene tree.
"""

export (PackedScene) var ChatIconScene: PackedScene

func _ready() -> void:
	for chattable in get_tree().get_nodes_in_group("chattables"):
		create_icon(chattable)


func create_icon(chattable: Node) -> void:
	var chat_icon: ChatIcon = ChatIconScene.instance()
	add_child(chat_icon)
	chat_icon.initialize(chattable)
	chattable.connect("tree_exited", self, "_on_Chattable_tree_exited", [chat_icon])


func _on_Chattable_tree_exited(chat_icon: ChatIcon) -> void:
	chat_icon.queue_free()
