extends Node2D
"""
Creates and initializes chat icons for all chattables in the scene tree.
"""

export (PackedScene) var ChatIconScene: PackedScene

func _ready() -> void:
	for chattable in get_tree().get_nodes_in_group("chattables"):
		var chat_icon: ChatIcon = ChatIconScene.instance()
		add_child(chat_icon)
		chat_icon.initialize(chattable)
