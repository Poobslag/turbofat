extends Control
"""
Displays UI elements for a dialog sequence.
"""

signal popped_in
signal chat_event_played(chat_event)

# emitted when we present the player with a dialog choice
signal showed_choices
signal chat_choice_chosen(choice_index)
signal pop_out_completed

# how long the player needs to hold the button to skip all dialog
const HOLD_TO_SKIP_DURATION := 0.6

# how long the player has been holding the 'interact' button
var _accept_action_duration := 0.0

# how long the player has been holding the 'rewind' button
var _rewind_action_duration := 0.0

onready var _chat_advancer: ChatAdvancer = $ChatAdvancer
onready var _chat_choices: ChatChoices = $ChatChoices
onready var _chat_frame: ChatFrame = $ChatFrame

func _process(delta: float) -> void:
	_rewind_action_duration = _rewind_action_duration + delta if Input.is_action_pressed("rewind_text") else 0.0
	_accept_action_duration = _accept_action_duration + delta if Input.is_action_pressed("ui_accept") else 0.0


func _input(event: InputEvent) -> void:
	if not _chat_frame.chat_window_showing():
		return
	
	if event.is_action_pressed("rewind_text", true):
		_handle_rewind_action(event)
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_accept", true):
		if not _chat_choices.is_showing_choices():
			_handle_advance_action(event)
			get_tree().set_input_as_handled()


func play_chat_tree(chat_tree: ChatTree) -> void:
	_chat_advancer.play_chat_tree(chat_tree)
	emit_signal("popped_in")


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
		_chat_advancer.rewind()


"""
Process the result of the player pressing the 'advance' button.

The player can tap the advance button to make dialog appear faster or advance to the next line. They can hold the
advance button to continuously advance the text.
"""
func _handle_advance_action(event: InputEvent) -> void:
	var advance_action := false
	if event.is_action_pressed("ui_accept"):
		# if the player presses the 'interact' button, advance the text
		advance_action = true
	elif event.is_action_pressed("ui_accept", true) and _accept_action_duration >= HOLD_TO_SKIP_DURATION:
		# if the player holds the 'interact' button, continuously advance the text
		advance_action = true
	
	if advance_action:
		get_tree().set_input_as_handled()
		if not _chat_frame.is_all_text_visible():
			# text is still being slowly typed out, make it all visible
			_chat_frame.make_all_text_visible()
		else:
			_chat_advancer.advance()


"""
Displays the current chat event to the player.
"""
func _on_ChatAdvancer_chat_event_shown(chat_event: ChatEvent) -> void:
	if _chat_advancer.rewinding_text or _chat_choices.is_showing_choices():
		# if we're asked to rewind or play more dialog without picking a choice, hide the choices
		_chat_choices.hide_choices()
	
	# reposition the nametags for whether the characters are on the left or right side
	var creature := ChattableManager.get_creature_by_id(chat_event["who"])
	var nametag_right := false
	var squished := false
	if creature:
		var orientation: int = creature.orientation
		if orientation in [Creature.NORTHEAST, Creature.SOUTHEAST]:
			# If we're facing right, we're on the left side. Put the nametag on the left.
			nametag_right = false
		elif orientation in [Creature.NORTHWEST, Creature.SOUTHWEST]:
			# If we're facing left, we're on the right side. Put the nametag on the right.
			nametag_right = true
	
	if _chat_advancer.should_prompt():
		# we're going to prompt the player for a response; squish the chat frame to the side
		squished = true
	
	_chat_frame.play_chat_event(chat_event, nametag_right, squished)
	
	if _chat_advancer.rewinding_text:
		# immediately make all text visible when rewinding, so the player can rewind faster
		_chat_frame.make_all_text_visible()
	else:
		emit_signal("chat_event_played", chat_event)
	
	_chat_frame.visible = true if chat_event.text else false
	if not chat_event.text:
		# emitting the 'all_text_shown' signal while other nodes are still receiving the current 'chat_event_shown'
		# signal introduces complications, so we wait until the next frame
		yield(get_tree(), "idle_frame")
		_chat_frame.emit_signal("all_text_shown")
		if not _chat_advancer.should_prompt():
			_chat_advancer.advance()


func _on_ChatFrame_all_text_shown() -> void:
	if _chat_advancer.should_prompt():
		var chat_event: ChatEvent = _chat_advancer.current_chat_event()
		var moods: Array = []
		for link in chat_event.links:
			if _chat_advancer.chat_tree.events.has(link):
				var first_event: ChatEvent = _chat_advancer.chat_tree.events[link][0]
				if first_event and first_event.mood:
					moods.append(first_event.mood)
				else: moods.append(-1)
			else:
				moods.append(-1)
		_chat_choices.reposition(_chat_frame.get_chat_line_size())
		_chat_choices.show_choices(chat_event.link_texts, moods)
		emit_signal("showed_choices")


func _on_ChatFrame_pop_out_completed() -> void:
	emit_signal("pop_out_completed")


func _on_ChatChoices_chat_choice_chosen(choice_index: int) -> void:
	emit_signal("chat_choice_chosen", choice_index)
