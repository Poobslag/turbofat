extends LineEdit
## LineEdit for editing the creature's name.
##
## Blocks other input while the player is typing the creature's name.

func _gui_input(event: InputEvent) -> void:
	if has_focus():
		if event is InputEventKey \
				and not event.is_action_pressed("ui_cancel") \
				and not event.is_action_pressed("ui_accept"):
			
			# Swallow keyboard events when typing a name to ensure the UI doesn't change tabs
			accept_event()
