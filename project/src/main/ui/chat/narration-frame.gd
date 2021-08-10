class_name NarrationFrame
extends Control
"""
Window which displays a narration line.
"""

signal pop_out_completed

# emitted after the full chat line is typed out onscreen
signal all_text_shown

# 'true' after pop_in is called, and 'false' after pop_out is called
var _popped_in := false

"""
Makes the chat window appear.
"""
func pop_in() -> void:
	if _popped_in:
		# chat window is already popped in
		return
	_popped_in = true
	$PopTween.pop_in()
	$PopInSound.play()


"""
Makes the chat window disappear.
"""
func pop_out() -> void:
	if not _popped_in:
		# chat window is already popped out
		return
	_popped_in = false
	$PopTween.pop_out()
	$PopOutSound.play()


"""
Animates the narration UI to gradually reveal the specified text, mimicking speech.
"""
func play_chat_event(chat_event: ChatEvent) -> void:
	if not $NarrationPanel.visible:
		# Ensure the chat window is showing before we start changing its text and playing sounds
		pop_in()
	
	# add lull characters
	var text_with_lulls := ChatLibrary.add_lull_characters(chat_event.text)
	
	# set the text
	$NarrationPanel.show_message(text_with_lulls, 0.5)


func is_narration_window_showing() -> bool:
	return $NarrationPanel.visible


func is_all_text_visible() -> bool:
	return $NarrationPanel.is_all_text_visible()


func make_all_text_visible() -> void:
	$NarrationPanel.make_all_text_visible()


func _on_Tween_pop_out_completed() -> void:
	# Hide label to prevent sounds from playing
	$NarrationPanel.hide_message()
	emit_signal("pop_out_completed")


func _on_NarrationPanel_all_text_shown() -> void:
	emit_signal("all_text_shown")


func _on_ChatAdvancer_chat_finished() -> void:
	pop_out()
