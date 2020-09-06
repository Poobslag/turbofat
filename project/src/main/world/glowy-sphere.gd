extends KinematicBody2D
"""
Script for showing a placeholder chattable object in the overworld.
"""

func _ready() -> void:
	set_meta("chat_path", "res://assets/main/dialog/glowy-sphere.json")
	set_meta("chat_bubble_type", ChatIcon.THOUGHT)
