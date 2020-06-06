class_name ChatFrame
extends Control
"""
Window which displays a line of dialog.

The chat window is decorated with objects in the background called 'accents'. These accents can be injected with the
set_chat_theme_def function to configure the chat window's appearance.
"""

signal pop_out_completed

# emitted after the full dialog chat line is typed out onscreen
signal all_text_shown

# 'true' after pop_in is called, and 'false' after pop_out is called
var _popped_in := false
var _squished := false

func _ready() -> void:
	$ChatLineLabel.hide_message()
	$ChatLineSprite/NametagManager.hide_labels()


"""
Makes the chat window appear.
"""
func pop_in() -> void:
	if _popped_in:
		# chat window is already popped in
		return
	_popped_in = true
	$ChatLineLabel.hide_message()
	$ChatLineSprite/NametagManager.hide_labels()
	$Tween.pop_in()
	$PopInSound.play()


"""
Makes the chat window disappear.
"""
func pop_out() -> void:
	if not _popped_in:
		# chat window is already popped out
		return
	_popped_in = false
	$Tween.pop_out()
	$PopOutSound.play()


"""
Animates the chat UI to gradually reveal the specified text, mimicking speech.

Also updates the chat UI's appearance based on the amount of text being displayed and the specified color and
background texture.
"""
func play_chat_event(chat_event: ChatEvent, nametag_right: bool, squished: bool) -> void:
	if not $ChatLineLabel.visible:
		# Ensure the chat window is showing before we start changing its text and playing sounds
		pop_in()
	
	if squished != _squished:
		if squished:
			# Squish the chat window to the side
			$Tween.squish()
		else:
			# Unsquish the chat window
			$Tween.unsquish()
		_squished = squished
	
	var chat_theme := ChatTheme.new(chat_event.chat_theme_def)
	
	# set the text and calculate how big of a frame we need
	var chat_line_size: int = $ChatLineLabel.show_message(chat_event.text, 0.5)
	$ChatLineSprite/NametagManager.set_nametag_text(chat_event.who)
	
	# update the UI's appearance
	$ChatLineSprite/NametagManager.show_label(chat_theme, nametag_right, chat_line_size)
	$ChatLineLabel.update_appearance(chat_theme)
	$ChatLineSprite.update_appearance(chat_theme, chat_line_size)


func chat_window_showing() -> bool:
	return $ChatLineLabel.visible


func is_all_text_visible() -> bool:
	return $ChatLineLabel.is_all_text_visible()


func make_all_text_visible() -> void:
	$ChatLineLabel.make_all_text_visible()


"""
Returns the size of the chat line window needed to display the chat line text.
"""
func get_chat_line_size() -> int:
	return $ChatLineLabel.chosen_size_index


func _on_Tween_pop_out_completed() -> void:
	# Hide label to prevent sounds from playing
	$ChatLineLabel.hide_message()
	$ChatLineSprite/NametagManager.hide_labels()
	emit_signal("pop_out_completed")


func _on_ChatLineLabel_all_text_shown() -> void:
	emit_signal("all_text_shown")


func _on_ChatAdvancer_chat_finished() -> void:
	pop_out()
