extends Button
## Button which resets the gameplay settings to their default values.
##
## This button provides an easy way to disable all cheats.

func _ready() -> void:
	connect("pressed", self, "_on_pressed")


func _on_pressed() -> void:
	SystemData.gameplay_settings.reset()
