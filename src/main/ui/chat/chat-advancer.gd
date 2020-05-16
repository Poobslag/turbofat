class_name ChatAdvancer
extends Node
"""
Allows the player to advance through a chat tree, and rewind through past chat events.
"""

# tree of chat events the player can page through
var chat_tree: ChatTree

# historical array of ChatEvents the player can rewind through
var _prev_chat_events := []
var _prev_chat_event_index := 0

# 'true' if the player is currently rewinding through the chat history
var rewinding_text := false

# signal emitted when a chat event (new or historical) is shown to the player
signal chat_event_shown(chat_event)

# signal emitted when the chat sequence ends, and the window should close
signal chat_finished

func play_chat_tree(new_chat_tree: ChatTree) -> void:
	rewinding_text = false
	chat_tree = new_chat_tree
	emit_signal("chat_event_shown", current_chat_event())


"""
Rewind to a previously shown dialog line.
"""
func rewind() -> void:
	var did_decrement := false
	if _prev_chat_events.size() < 2:
		# no events to rewind to
		pass
	elif not rewinding_text:
		# begin rewinding
		rewinding_text = true
		_prev_chat_event_index = _prev_chat_events.size() - 2
		did_decrement = true
	elif _prev_chat_event_index > 0:
		# continue rewinding further back
		_prev_chat_event_index -= 1
		did_decrement = true
	
	if did_decrement:
		emit_signal("chat_event_shown", current_chat_event())


"""
Advance to the next dialog line.

This is most likely the next spoken dialog line if the player is advancing dialog normally. However, it can also be a
historical dialog line if the player was rewinding dialog.
"""
func advance() -> void:
	var did_increment := false
	if rewinding_text:
		if _prev_chat_event_index + 1 < _prev_chat_events.size():
			# continue forward through rewound events
			_prev_chat_event_index += 1
			did_increment = true
		else:
			# done rewinding; back to current dialog
			rewinding_text = false
	
	if not rewinding_text:
		did_increment = chat_tree.advance(0)
	
	if did_increment:
		emit_signal("chat_event_shown", current_chat_event())
	else:
		emit_signal("chat_finished")


"""
The current chat event being shown to the player.

This could either be the newest chat event, or a historical one they're rewinding through.
"""
func current_chat_event() -> ChatEvent:
	var chat_event: ChatEvent
	if rewinding_text:
		chat_event = _prev_chat_events[_prev_chat_event_index]
	elif chat_tree:
		chat_event = chat_tree.get_event()
	return chat_event


"""
Returns 'true' if we're at a dialog branch and should prompt the player.
"""
func should_prompt() -> bool:
	var result := true
	var chat_event:ChatEvent = current_chat_event()
	if not chat_event:
		result = false
	if rewinding_text and _prev_chat_event_index < _prev_chat_events.size() - 1:
		# don't prompt for questions the player has already answered
		result = false
	elif chat_event.links.size() < 2:
		# one or zero links, the player has no choice to make
		result = false
	return result


"""
Record the last 100 chat events so the player can review them later.
"""
func _on_ChatUi_chat_event_played(chat_event: ChatEvent) -> void:
	_prev_chat_events.append(chat_event)
	while _prev_chat_events.size() > 100:
		_prev_chat_events.remove(0)


func _on_ChatChoices_chat_choice_chosen(choice_index: int) -> void:
	if rewinding_text:
		# The player rewound, advanced to a dialog prompt and chose an answer. Remove them from the rewind state.
		rewinding_text = false
	chat_tree.advance(choice_index)
	# show the next dialog line to the player
	emit_signal("chat_event_shown", current_chat_event())
