extends Node

signal popup_hide

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().visibility_changed.connect(_on_Dialog_visibility_changed)


func _on_Dialog_visibility_changed() -> void:
	if not get_parent().visible:
		emit_signal("popup_hide")
