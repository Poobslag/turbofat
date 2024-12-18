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

export (NodePath) var overworld_environment_path: NodePath setget set_overworld_environment_path

## how long the player has been holding the 'interact' button
var _accept_action_duration := 0.0

## how long the player has been holding the 'rewind' button
var _rewind_action_duration := 0.0

## chat tree currently being played.
var _chat_tree: ChatTree

## true if the player has advanced past the last line in the chat tree
var _chat_finished := false

var _overworld_environment: OverworldEnvironment

onready var _chat_advancer: ChatAdvancer = $ChatAdvancer
onready var _chat_choices: ChatChoices = $ChatChoices
onready var _chat_frame: ChatFrame = $ChatFrame
onready var _narration_frame: NarrationFrame = $NarrationFrame

func _ready() -> void:
	_refresh_overworld_environment_path()
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("visible_chatters_changed", self, "_on_OverworldUi_visible_chatters_changed")


func _process(delta: float) -> void:
	_rewind_action_duration = _rewind_action_duration + delta if Input.is_action_pressed("rewind_text") else 0.0
	_accept_action_duration = _accept_action_duration + delta if Input.is_action_pressed("ui_accept") else 0.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		return
	if not _chat_frame.is_chat_window_showing() and not _narration_frame.is_narration_window_showing():
		return
	
	if event.is_action_pressed("rewind_text", true):
		_handle_rewind_action(event)
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_accept", true):
		if not _chat_choices.is_showing_choices() \
				or _chat_choices.is_showing_choices() and event.is_echo():
			_handle_advance_action(event)
			get_tree().set_input_as_handled()


func set_overworld_environment_path(new_overworld_environment_path: NodePath) -> void:
	overworld_environment_path = new_overworld_environment_path
	_refresh_overworld_environment_path()


func play_chat_tree(chat_tree: ChatTree) -> void:
	_chat_tree = chat_tree
	_chat_finished = false
	_assign_nametag_sides()
	_chat_advancer.play_chat_tree(chat_tree)
	emit_signal("popped_in")


## Steals the focus from another control and becomes the focused control.
##
## This control itself doesn't have focus, so we delegate to a child control.
func grab_focus() -> void:
	if _chat_choices.is_showing_choices():
		_chat_choices.grab_focus()


func _refresh_overworld_environment_path() -> void:
	if not is_inside_tree():
		return
	
	_overworld_environment = get_node(overworld_environment_path) if overworld_environment_path else null


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
	if not _chat_tree:
		return
	
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
		elif _chat_tree.events.has(link):
			# chat link did not specify a mood; use the mood from the branch's first event
			var first_event: ChatEvent = _chat_tree.events[link][0]
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
			var first_event: ChatEvent = _chat_tree.events[link][0]
			text = first_event.text
		texts.append(text)
	return texts


## Assign nametag sides for each chat line.
##
## We calculate the midpoint of the chatters. Creatures to the right of the midpoint have their nametags on the right.
## Creatures to the left have their nametags on the left.
##
## This information is stored back into the chat tree so that it can be utilized by the chat ui.
func _assign_nametag_sides() -> void:
	if not _chat_tree:
		return
	
	if not Global.get_overworld_ui():
		return
	
	var chatter_bounding_box := Global.get_overworld_ui().get_chatter_bounding_box([], [])
	var center_of_chatters: Vector2 = chatter_bounding_box.position + chatter_bounding_box.size * 0.5
	
	for chat_events_obj in _chat_tree.events.values():
		var chat_events: Array = chat_events_obj
		for chat_event_obj in chat_events:
			var chat_event: ChatEvent = chat_event_obj
			if not chat_event.who:
				continue
			var chatter: Creature = _overworld_environment.get_creature_by_id(chat_event.who)
			if not chatter:
				continue
			if chatter.position.x > center_of_chatters.x:
				chat_event.nametag_side = ChatEvent.NametagSide.RIGHT
			else:
				chat_event.nametag_side = ChatEvent.NametagSide.LEFT


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
	_chat_tree = null


func _on_OverworldUi_visible_chatters_changed() -> void:
	_assign_nametag_sides()
