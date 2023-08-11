class_name ChatFrame
extends Control
## Window which displays a chat line.
##
## The chat window is decorated with objects in the background called 'accents'. These accents can be injected with the
## chat_event.chat_theme property to configure the chat window's appearance.

signal pop_out_completed

## emitted after the full chat line is typed out onscreen
signal all_text_shown

## 'true' after pop_in is called, and 'false' after pop_out is called
var _popped_in := false
var _squished := false

onready var _chat_line_label := $ChatLineLabel
onready var _chat_line_panel := $ChatLinePanel
onready var _nametag_panel := $ChatLinePanel/NametagPanel
onready var _pop_in_sound := $PopInSound
onready var _pop_out_sound := $PopOutSound
onready var _pop_tween_manager := $PopTweenManager
onready var _squish_tween_manager := $SquishTweenManager

func _ready() -> void:
	_chat_line_label.hide_message()
	_nametag_panel.hide_labels()


## Makes the chat window appear.
func pop_in() -> void:
	if _popped_in:
		# chat window is already popped in
		return
	_popped_in = true
	_chat_line_label.hide_message()
	_nametag_panel.hide_labels()
	_pop_tween_manager.pop_in()
	_pop_in_sound.play()


## Makes the chat window disappear.
func pop_out() -> void:
	if not _popped_in:
		# chat window is already popped out
		return
	_popped_in = false
	_pop_tween_manager.pop_out()
	_pop_out_sound.play()


## Animates the chat UI to gradually reveal the specified text, mimicking speech.
##
## Also updates the chat UI's appearance based on the amount of text being displayed and the specified color and
## background texture.
func play_chat_event(chat_event: ChatEvent, squished: bool) -> void:
	if not _chat_line_label.visible:
		# Ensure the chat window is showing before we start changing its text and playing sounds
		pop_in()
	
	if squished != _squished:
		if squished:
			# Squish the chat window to the side
			_squish_tween_manager.squish()
		else:
			# Unsquish the chat window
			_squish_tween_manager.unsquish()
		_squished = squished
	
	# substitute variables and add lull characters
	var text_to_show := chat_event.text
	text_to_show = PlayerData.creature_library.substitute_variables(text_to_show)
	text_to_show = ChatLibrary.add_lull_characters(text_to_show)
	
	# set the text and calculate how big of a frame we need
	var chat_line_size: int = _chat_line_label.show_message(text_to_show, 0.5)
	
	# calculate the nametag text
	var nametag_text := ""
	var nametag_text_meta := _get_nametag_text_meta(chat_event)
	if not nametag_text and nametag_text_meta:
		# the 'nametag_text' meta item has priority, and overrides the creature's name
		nametag_text = nametag_text_meta
	if not nametag_text and chat_event.who:
		var creature_def := PlayerData.creature_library.get_creature_def(chat_event.who)
		if not creature_def:
			push_error("creature_def not found with id '%s'" % [chat_event.who])
		nametag_text = creature_def.creature_name
	_nametag_panel.set_nametag_text(nametag_text)
	
	# update the UI's appearance
	_chat_line_label.update_appearance(chat_event.chat_theme)
	_chat_line_panel.update_appearance(chat_event.chat_theme, chat_line_size)
	var nametag_right: bool = chat_event.nametag_side == ChatEvent.NametagSide.RIGHT
	_nametag_panel.show_label(chat_event.chat_theme, nametag_right)


func is_chat_window_showing() -> bool:
	return _chat_line_label.visible


func is_all_text_visible() -> bool:
	return _chat_line_label.is_all_text_visible()


func make_all_text_visible() -> void:
	_chat_line_label.make_all_text_visible()


## Returns the size of the chat line window needed to display the chat line text.
func get_chat_line_size() -> int:
	return _chat_line_label.chosen_size_index


## Returns the value of the 'nametag_text' meta item.
func _get_nametag_text_meta(chat_event: ChatEvent) -> String:
	var nametag_text: String
	for meta_item_obj in chat_event.meta:
		var meta_item: String = meta_item_obj
		if meta_item.begins_with("nametag_text "):
			nametag_text = meta_item.trim_prefix("nametag_text ")
			break
	return nametag_text


func _on_Tween_pop_out_completed() -> void:
	# Hide label to prevent sounds from playing
	_chat_line_label.hide_message()
	_nametag_panel.hide_labels()
	emit_signal("pop_out_completed")


func _on_ChatLineLabel_all_text_shown() -> void:
	emit_signal("all_text_shown")


func _on_ChatAdvancer_chat_finished() -> void:
	pop_out()
