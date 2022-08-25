class_name ChatAdvancer
extends Node
## Allows the player to advance through a chat tree, and rewind through past chat events.

## tree of chat events the player can page through
var chat_tree: ChatTree

## historical array of ChatEvents the player can rewind through
var _prev_chat_events := []
var _prev_chat_event_index := 0

## 'true' if the player is currently rewinding through the chat history
var rewinding_text := false

## emitted when a chat event (new or historical) is shown to the player
signal chat_event_shown(chat_event)

## emitted when the chat sequence ends, and the window should close
signal chat_finished

func play_chat_tree(new_chat_tree: ChatTree) -> void:
	rewinding_text = false
	chat_tree = new_chat_tree
	chat_tree.prepare_first_chat_event()
	emit_signal("chat_event_shown", current_chat_event())


## Rewind to a previously shown chat line.
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


## Advance to the next chat line.
##
## This is most likely the next spoken chat line if the player is advancing chat normally. However, it can also be a
## historical chat line if the player was rewinding chat.
func advance() -> void:
	var did_increment := false
	if rewinding_text:
		if _prev_chat_event_index + 1 < _prev_chat_events.size():
			# continue forward through rewound events
			_prev_chat_event_index += 1
			did_increment = true
		else:
			# done rewinding; back to current chat
			rewinding_text = false
	
	if not rewinding_text:
		var link_index := -1
		var enabled_link_indexes := chat_tree.get_event().enabled_link_indexes()
		if enabled_link_indexes:
			# select the earliest unlocked link index
			link_index = enabled_link_indexes[0]
		did_increment = chat_tree.advance(link_index)
	
	if did_increment:
		emit_signal("chat_event_shown", current_chat_event())
	else:
		chat_tree = null
		emit_signal("chat_finished")


## The current chat event being shown to the player.
##
## This could either be the newest chat event, or a historical one they're rewinding through.
func current_chat_event() -> ChatEvent:
	var chat_event: ChatEvent
	if rewinding_text:
		chat_event = _prev_chat_events[_prev_chat_event_index]
	elif chat_tree:
		chat_event = chat_tree.get_event()
	return chat_event


## Returns 'true' if we're at a chat branch and should prompt the player.
func should_prompt() -> bool:
	var result := true
	var chat_event:ChatEvent = current_chat_event()
	if not chat_event:
		result = false
	if rewinding_text and _prev_chat_event_index < _prev_chat_events.size() - 1:
		# don't prompt for questions the player has already answered
		result = false
	elif chat_event.enabled_link_indexes().size() < 2:
		# one or zero links, the player has no choice to make
		result = false
	return result


## Record the last 100 chat events so the player can review them later.
func _on_ChatUi_chat_event_played(chat_event: ChatEvent) -> void:
	_prev_chat_events.append(chat_event)
	while _prev_chat_events.size() > 100:
		_prev_chat_events.remove(0)


func _on_ChatChoices_chat_choice_chosen(choice_index: int) -> void:
	if rewinding_text:
		# The player rewound, advanced to a chat choice and chose a response. Remove them from the rewind state.
		rewinding_text = false
	var link_index: int = chat_tree.get_event().enabled_link_indexes()[choice_index]
	var did_increment := chat_tree.advance(link_index)
	if did_increment:
		# show the next chat line to the player
		emit_signal("chat_event_shown", current_chat_event())
	else:
		emit_signal("chat_finished")
