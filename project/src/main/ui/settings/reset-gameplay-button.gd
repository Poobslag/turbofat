extends Button
## Button which resets the gameplay settings to their default values.
##
## This button provides an easy way to disable all cheats.

func _pressed() -> void:
	SystemData.gameplay_settings.reset()
	SystemData.has_unsaved_changes = true
