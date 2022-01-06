extends Control
## Displays UI elements for a chat sequence.

signal popped_in
signal chat_event_played(chat_event)

## emitted when we present the player with a chat choice
signal showed_choices
signal chat_choice_chosen(choice_index)

## emitted when the chat window pops out after a finished chat
signal chat_finished

## how long the player needs to hold the button to skip all chat lines
const HOLD_TO_SKIP_DURATION := 0.6

## how long the player has been holding the 'interact' button
var _accept_action_duration := 0.0

## how long the player has been holding the 'rewind' button
var _rewind_action_duration := 0.0

onready var _chat_advancer: ChatAdvancer = $ChatAdvancer
onready var _chat_choices: ChatChoices = $ChatChoices
onready var _chat_frame: ChatFrame = $ChatFrame
onready var _narration_frame: NarrationFrame = $NarrationFrame

## true if the player has advanced past the last line in the chat tree
var _chat_finished := false

func _process(delta: float) -> void:
	_rewind_action_duration = _rewind_action_duration + delta if Input.is_action_pressed("rewind_text") else 0.0
	_accept_action_duration = _accept_action_duration + delta if Input.is_action_pressed("ui_accept") else 0.0


func _input(event: InputEvent) -> void:
	if not _chat_frame.is_chat_window_showing() and not _narration_frame.is_narration_window_showing():
		return
	
	if event.is_action_pressed("rewind_text", true):
		_handle_rewind_action(event)
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_accept", true):
		if not _chat_choices.is_showing_choices():
			_handle_advance_action(event)
			get_tree().set_input_as_handled()


func play_chat_tree(chat_tree: ChatTree) -> void:
	_chat_finished = false
	_chat_advancer.play_chat_tree(chat_tree)
	emit_signal("popped_in")


## Process the result of the player pressing the 'rewind' button.
##
## The player can tap the rewind button to view the previous line, or hold the button to rewind continuously.
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


## Process the result of the player pressing the 'advance' button.
##
## The player can tap the advance button to make chat lines appear faster or advance to the next line. They can hold
## the advance button to continuously advance the text.
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
		if _chat_frame.is_chat_window_showing() and not _chat_frame.is_all_text_visible():
			# text is still being slowly typed out, make it all visible
			_chat_frame.make_all_text_visible()
		elif _narration_frame.is_narration_window_showing() and not _narration_frame.is_all_text_visible():
			# text is still being slowly typed out, make it all visible
			_narration_frame.make_all_text_visible()
		else:
			_chat_advancer.advance()


## Displays the current chat event to the player.
func _on_ChatAdvancer_chat_event_shown(chat_event: ChatEvent) -> void:
	if _chat_advancer.rewinding_text or _chat_choices.is_showing_choices():
		# if we're asked to rewind or play more chat lines without picking a choice, hide the choices
		_chat_choices.hide_choices()
	
	if chat_event["who"] == CreatureLibrary.NARRATOR_ID:
		_narration_frame.play_chat_event(chat_event)
	else:
		var squished := false
		
		if _chat_advancer.should_prompt():
			# we're going to prompt the player for a response; squish the chat frame to the side
			squished = true
		
		_chat_frame.play_chat_event(chat_event, squished)
	
	if _chat_advancer.rewinding_text:
		# immediately make all text visible when rewinding, so the player can rewind faster
		if _chat_frame.is_chat_window_showing():
			_chat_frame.make_all_text_visible()
		elif _narration_frame.is_narration_window_showing():
			_narration_frame.make_all_text_visible()
	else:
		emit_signal("chat_event_played", chat_event)
	
	if chat_event.who == CreatureLibrary.NARRATOR_ID and _chat_frame.is_chat_window_showing():
		_chat_frame.pop_out()
	if chat_event.who != CreatureLibrary.NARRATOR_ID and _narration_frame.is_narration_window_showing():
		_narration_frame.pop_out()
	
	if _chat_frame.is_chat_window_showing():
		_chat_frame.visible = true if chat_event.text else false
	elif _narration_frame.is_narration_window_showing():
		_narration_frame.visible = true if chat_event.text else false
	
	if not chat_event.text:
		# emitting the 'all_text_shown' signal while other nodes are still receiving the current 'chat_event_shown'
		# signal introduces complications, so we wait until the next frame
		yield(get_tree(), "idle_frame")
		_chat_frame.emit_signal("all_text_shown")
		if not _chat_advancer.should_prompt():
			_chat_advancer.advance()


## Extracts the moods for each available choice of a chat event.
##
## The resulting array excludes any choices whose link_if conditions are unmet.
##
## Returns:
## 	An array of Creatures.Mood instances for each chat branch
func _enabled_link_moods(var chat_event: ChatEvent) -> Array:
	var moods := []
	for i in chat_event.enabled_link_indexes():
		var link: String = chat_event.links[i]
		var mood := -1
		if chat_event.link_moods[i] != -1:
			# use the mood from the chat link
			mood = chat_event.link_moods[i]
		elif _chat_advancer.chat_tree.events.has(link):
			# chat link did not specify a mood; use the mood from the branch's first event
			var first_event: ChatEvent = _chat_advancer.chat_tree.events[link][0]
			if first_event and first_event.mood:
				mood = first_event.mood
		else:
			# branch's first event did not specify a mood; mood remains unset
			pass
		moods.append(mood)
	return moods


## Extracts the strings to show the player for each available choice of a chat event.
##
## The resulting array excludes any choices whose link_if conditions are unmet.
##
## Returns:
## 	An array of string choices for each chat branch
func _enabled_link_texts(var chat_event: ChatEvent) -> Array:
	var texts := []
	for i in chat_event.enabled_link_indexes():
		var link: String = chat_event.links[i]
		var text: String
		if chat_event.link_texts[i]:
			# use the text from the chat link
			text = chat_event.link_texts[i]
		else:
			# chat link did not specify text; use the text from the branch's first event
			var first_event: ChatEvent = _chat_advancer.chat_tree.events[link][0]
			text = first_event.text
		texts.append(text)
	return texts


func _on_ChatFrame_all_text_shown() -> void:
	if _chat_advancer.should_prompt():
		var chat_event: ChatEvent = _chat_advancer.current_chat_event()
		
		_chat_choices.reposition(_chat_frame.get_chat_line_size())
		
		var texts := _enabled_link_texts(chat_event)
		var moods := _enabled_link_moods(chat_event)
		_chat_choices.show_choices(texts, moods)
		
		emit_signal("showed_choices")


func _on_ChatFrame_pop_out_completed() -> void:
	if _chat_finished:
		emit_signal("chat_finished")


func _on_NarrationFrame_pop_out_completed() -> void:
	if _chat_finished:
		emit_signal("chat_finished")


func _on_ChatChoices_chat_choice_chosen(choice_index: int) -> void:
	emit_signal("chat_choice_chosen", choice_index)


func _on_ChatAdvancer_chat_finished() -> void:
	_chat_finished = true
