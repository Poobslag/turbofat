extends Button
## Button which resets the gameplay settings to their default values.
##
## This button provides an easy way to disable all cheats.

func _pressed() -> void:
	SystemData.gameplay_settings.ghost_piece = true
	SystemData.gameplay_settings.soft_drop_lock_cancel = false
	SystemData.has_unsaved_changes = true
