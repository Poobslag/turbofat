extends Control
"""
Displays UI elements for a dialog sequence.
"""

signal pop_out_completed

# array of ChatEvents the player is currently paging through
var _chat_events: Array

# index of the current ChatEvent being shown
var _current_line := 0

func play_dialog_sequence(chat_events: Array) -> void:
	_chat_events = chat_events
	_play_text(chat_events[0])
	_current_line = 0


func _play_text(chat_event: ChatEvent) -> void:
	$ChatFrame.play_text(chat_event.name, chat_event.text, chat_event.accent_def)


func _input(event: InputEvent) -> void:
	if $ChatFrame.chat_window_showing() and event.is_action_pressed("interact"):
		get_tree().set_input_as_handled()
		if _current_line + 1 < _chat_events.size():
			_current_line += 1
			_play_text(_chat_events[_current_line])
		else:
			$ChatFrame.pop_out()


func _on_ChatFrame_pop_out_completed():
	emit_signal("pop_out_completed")
