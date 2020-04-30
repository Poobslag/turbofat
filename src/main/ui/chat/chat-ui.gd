extends Control
"""
Displays UI elements for a dialog sequence.
"""

signal chat_event_played(chat_event)

signal pop_out_completed

# signal emitted when we present the player with a dialog choice
signal showed_choices

# how long the player needs to hold the button to skip all dialog
const HOLD_TO_SKIP_DURATION := 0.6

# tree of chat events the player can page through
var _chat_tree: ChatTree

# historical array of ChatEvents the player can rewind through
var _prev_chat_events := []
var _prev_chat_event_index := 0

# how long the player has been holding the 'interact' button
var _interact_action_duration := 0.0

# how long the player has been holding the 'rewind' button
var _rewind_action_duration := 0.0

# 'true' if the player is currently rewinding through the chat history
var _rewinding_text := false

func _process(delta: float) -> void:
	_interact_action_duration = _interact_action_duration + delta if Input.is_action_pressed("ui_accept") else 0
	_rewind_action_duration = _rewind_action_duration + delta if Input.is_action_pressed("rewind_text") else 0


func _input(event: InputEvent) -> void:
	if not $ChatFrame.chat_window_showing():
		return
	if event.is_action_pressed("rewind_text", true):
		_handle_rewind_action(event)
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_accept", true):
		if not $ChatChoices.is_showing_choices():
			_handle_advance_action(event)
			get_tree().set_input_as_handled()


func play_chat_tree(chat_tree: ChatTree) -> void:
	_rewinding_text = false
	_chat_tree = chat_tree
	_play_chat_event()


"""
Process the result of the player pressing the 'rewind' button.

The player can tap the rewind button to view the previous line, or hold the button to rewind continuously.
"""
func _handle_rewind_action(event: InputEvent) -> void:
	var rewind_action := false
	if event.is_action_pressed("rewind_text"):
		# if the player presses the 'rewind' button, rewind the text
		rewind_action = true
	elif event.is_action_pressed("rewind_text", true) and _rewind_action_duration >= HOLD_TO_SKIP_DURATION:
		# if the player holds the 'rewind' button, continuously rewind the text
		rewind_action = true
	
	if rewind_action:
		get_tree().set_input_as_handled()
		if _decrement_line():
			_play_chat_event()


"""
Process the result of the player pressing the 'advance' button.

The player can tap the advance button to make dialog appear faster or advance to the next line. They can hold the
advance button to continuously advance the text.
"""
func _handle_advance_action(event: InputEvent) -> void:
	var handled_event := false
	var advance_action := false
	if event.is_action_pressed("ui_accept"):
		# if the player presses the 'interact' button, advance the text
		advance_action = true
	elif event.is_action_pressed("ui_accept", true) and _interact_action_duration >= HOLD_TO_SKIP_DURATION:
		# if the player holds the 'interact' button, continuously advance the text
		advance_action = true
	
	if advance_action:
		get_tree().set_input_as_handled()
		if not $ChatFrame.is_all_text_visible():
			# text is still being slowly typed out, make it all visible
			$ChatFrame.make_all_text_visible()
		elif _increment_line():
			# show the next dialog line to the player
			_play_chat_event()
		else:
			# there is no more dialog, close the chat window
			$ChatFrame.pop_out()


"""
Rewind to a previously shown dialog line.

Returns 'true' if the rewind was successful, or 'false' if there were no lines to rewind to.
"""
func _decrement_line() -> bool:
	var did_decrement := false
	if _prev_chat_events.size() < 2:
		# no events to rewind to
		pass
	elif not _rewinding_text:
		# begin rewinding
		_rewinding_text = true
		_prev_chat_event_index = _prev_chat_events.size() - 2
		did_decrement = true
	elif _prev_chat_event_index > 0:
		# continue rewinding further back
		_prev_chat_event_index -= 1
		did_decrement = true
	return did_decrement


"""
Advance to the next dialog line.

This is most likely the next spoken dialog line if the player is advancing dialog normally. However, it can also be a
historical dialog line if the player was rewinding dialog.

Returns 'true' if the increment was successful, or 'false' if there were no more lines to show.
"""
func _increment_line() -> bool:
	var did_increment := false
	if _rewinding_text:
		if _prev_chat_event_index + 1 < _prev_chat_events.size():
			# continue forward through rewound events
			_prev_chat_event_index += 1
			did_increment = true
		else:
			# done rewinding; back to current dialog
			_rewinding_text = false
	else:
		did_increment = _chat_tree.advance(0)
	return did_increment


"""
Displays the current chat event to the player.
"""
func _play_chat_event() -> void:
	if _rewinding_text or $ChatChoices.is_showing_choices():
		# if we're asked to rewind or play more dialog without picking a choice, hide the choices
		$ChatChoices.hide_choices()
	
	var chat_event := _current_chat_event()
	
	# reposition the nametags for whether the characters are on the left or right side
	var interactable := InteractableManager.get_chatter(chat_event["who"])
	var nametag_right := false
	var squished := false
	if interactable and interactable.has_method("get_orientation"):
		var orientation: int = interactable.get_orientation()
		if orientation in [Customer.Orientation.NORTHEAST, Customer.Orientation.SOUTHEAST]:
			# If we're facing right, we're on the left side. Put the nametag on the left.
			nametag_right = false
		elif orientation in [Customer.Orientation.NORTHWEST, Customer.Orientation.SOUTHWEST]:
			# If we're facing left, we're on the right side. Put the nametag on the right.
			nametag_right = true
	
	if _should_prompt():
		# we're going to prompt the player for a response; squish the chat frame to the side
		squished = true
	
	$ChatFrame.play_chat_event(chat_event, nametag_right, squished)
	
	if _rewinding_text:
		# immediately make all text visible when rewinding, so the player can rewind faster
		$ChatFrame.make_all_text_visible()
	else:
		emit_signal("chat_event_played", chat_event)


func _should_prompt() -> bool:
	var result := true
	var chat_event:ChatEvent = _current_chat_event()
	if not chat_event:
		result = false
	if _rewinding_text and _prev_chat_event_index < _prev_chat_events.size() - 1:
		# don't prompt for questions the player has already answered
		result = false
	elif chat_event.links.size() < 2:
		# one or zero links, the player has no choice to make
		result = false
	return result


func _current_chat_event() -> ChatEvent:
	var chat_event: ChatEvent
	if _rewinding_text:
		chat_event = _prev_chat_events[_prev_chat_event_index]
	elif _chat_tree:
		chat_event = _chat_tree.get_event()
	return chat_event


func _on_chat_event_played(chat_event: ChatEvent) -> void:
	# record the last 100 chat events so the player can review them later
	_prev_chat_events.append(chat_event)
	while _prev_chat_events.size() > 100:
		_prev_chat_events.remove(0)


func _on_ChatChoices_chat_choice_chosen(choice_index: int) -> void:
	_chat_tree.advance(choice_index)
	# show the next dialog line to the player
	_play_chat_event()


func _on_ChatFrame_all_text_shown() -> void:
	if _should_prompt():
		var chat_event := _current_chat_event()
		var moods: Array = []
		for link in chat_event.links:
			if _chat_tree.events[link]:
				var first_event: ChatEvent = _chat_tree.events[link][0]
				if first_event and first_event.mood:
					moods.append(first_event.mood)
				else: moods.append(-1)
			else:
				moods.append(-1)
		$ChatChoices.reposition($ChatFrame.get_sentence_size())
		$ChatChoices.show_choices(chat_event.link_texts, moods)
		emit_signal("showed_choices")


func _on_ChatFrame_pop_out_completed() -> void:
	emit_signal("pop_out_completed")
