extends VBoxContainer
"""
Navigational buttons which occur on most menu screens.
"""

signal quit_pressed

func _on_Quit_pressed() -> void:
	emit_signal("quit_pressed")
	Breadcrumb.pop_trail()
