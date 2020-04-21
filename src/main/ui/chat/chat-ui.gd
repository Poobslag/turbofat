extends Control
"""
Displays UI elements for a dialog sequence.
"""

signal chat_event_played

signal pop_out_completed

# array of ChatEvents the player is currently paging through
var _chat_events: Array

# index of the current ChatEvent being shown
var _current_line := 0

func play_dialog_sequence(chat_events: Array) -> void:
	_chat_events = chat_events
	_current_line = 0
	_play_text()


func _play_text() -> void:
	var chat_event: ChatEvent = _chat_events[_current_line]
	var interactable: Spatial = InteractableManager.get_chatter(chat_event["name"])
	var nametag_right: bool = false
	if interactable and interactable.has_method("get_orientation"):
		var orientation: int = interactable.get_orientation()
		if orientation in [Customer.Orientation.NORTHEAST, Customer.Orientation.SOUTHEAST]:
			# If we're facing right, we're on the left side. Put the nametag on the left.
			nametag_right = false
		elif orientation in [Customer.Orientation.NORTHWEST, Customer.Orientation.SOUTHWEST]:
			# If we're facing left, we're on the right side. Put the nametag on the right.
			nametag_right = true
	$ChatFrame.play_text(chat_event.name, chat_event.text, chat_event.accent_def, nametag_right)
	emit_signal("chat_event_played", chat_event)


func _input(event: InputEvent) -> void:
	if $ChatFrame.chat_window_showing() and event.is_action_pressed("interact"):
		get_tree().set_input_as_handled()
		if _current_line + 1 < _chat_events.size():
			_current_line += 1
			_play_text()
		else:
			$ChatFrame.pop_out()


func _on_ChatFrame_pop_out_completed():
	emit_signal("pop_out_completed")
