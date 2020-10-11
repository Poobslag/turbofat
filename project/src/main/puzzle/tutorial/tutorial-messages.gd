class_name TutorialMessages
extends Control
"""
Shows the instructor's dialog during tutorials.
"""

# emitted after the full dialog chat line is typed out onscreen, and no messages remain in the queue
signal all_messages_shown

# huge font used for easter eggs
var _huge_font := preload("res://src/main/ui/blogger-sans-bold-72.tres")

# normal font used for regular dialog
var _normal_font := preload("res://src/main/ui/blogger-sans-medium-30.tres")

# Queue of instructor messages which will be shown one at a time after a delay. This can also include empty strings
# which hide the current message.
var _message_queue := []

# theme which affects the color and texture of chat messages
var _instructor_chat_theme: ChatTheme

# 'true' after pop_in is called, and 'false' after pop_out is called
var _popped_in: bool

func _ready() -> void:
	var _instructor_creature_def := CreatureLoader.load_creature_def(CreatureLoader.INSTRUCTOR_PATH)
	_instructor_chat_theme = ChatTheme.new(_instructor_creature_def.chat_theme_def)
	_hide_message()


"""
Returns 'true' if the full dialog chat line is typed out onscreen, and no messages remain in the queue
"""
func is_all_messages_visible() -> bool:
	return _message_queue.empty() and $Label.is_all_text_visible()


"""
Displays a sequence of messages from the tutorial's instructor.
"""
func set_messages(messages: Array) -> void:
	set_message(messages[0] if messages else "")
	for i in range(1, messages.size()):
		enqueue_message(messages[i])


"""
Displays a message from the tutorial's instructor.
"""
func set_message(message: String) -> void:
	_clear_message_queue()
	_show_or_hide_message(message)


"""
Displays a BIG message from the tutorial's instructor, for use in easter eggs.
"""
func set_big_message(message: String) -> void:
	_clear_message_queue()
	_show_or_hide_message(message, _huge_font)


"""
Displays a message after a short delay.

If other messages are already in the queue, this message will be appended to the queue.
"""
func enqueue_message(message: String) -> void:
	_message_queue.push_back(message)
	if not _popped_in or $Label.is_all_text_visible():
		_refresh_queue_timer()


"""
Hides the currently shown message after a short delay.

If other messages are already in the queue, this operation will be appended to the queue.
"""
func enqueue_pop_out() -> void:
	enqueue_message("")


func _clear_message_queue() -> void:
	_message_queue.clear()
	$QueueTimer.stop()


func _show_or_hide_message(message: String, font: Font = _normal_font) -> void:
	if message:
		_show_message(message, font)
	else:
		_hide_message()


"""
Updates the message text and panel size to display the specified message.

If no message is currently shown, we also play a sound effect and a 'pop in' animation.
"""
func _show_message(message: String, font: Font = _normal_font) -> void:
	if not _popped_in:
		# play a sound effect and 'pop in' animation
		_popped_in = true
		$Tween.pop_in()
		$PopInSound.play()
	
	$Panel.show()
	$Label.set("custom_fonts/font", font)
	var chosen_size_index: int = $Label.show_message(message)
	$Label.update_appearance(_instructor_chat_theme)
	$Panel.update_appearance(_instructor_chat_theme, chosen_size_index)


"""
Updates the message text and panel size to display the specified message.

If a message is currently shown, we also play a sound effect and a 'pop out' animation.
"""
func _hide_message() -> void:
	if _popped_in:
		# play a sound effect and 'pop out' animation
		_popped_in = false
		$Tween.pop_out()
		$PopOutSound.play()
	
	_refresh_queue_timer()


"""
If any messages are in the queue, this launches the timer so they'll be shown soon.
"""
func _refresh_queue_timer() -> void:
	if _message_queue and $QueueTimer.is_stopped():
		$QueueTimer.start()


"""
When the queue timer times out, we show the next message in the queue.
"""
func _on_QueueTimer_timeout() -> void:
	# pop and show the next message in the queue
	if _message_queue:
		var message: String = _message_queue.pop_front()
		_show_or_hide_message(message)
	
	# if the queue is now empty, stop the queue timer
	if not _message_queue:
		$QueueTimer.stop()


"""
When the message is entirely visible, we pause for a moment and show the next message in the queue.
"""
func _on_Label_all_text_shown() -> void:
	_refresh_queue_timer()
	if not _message_queue:
		emit_signal("all_messages_shown")


"""
After the message pops out, we hide the panel.

This prevents sounds playing from a mostly-invisible panel, or other weird side effects.
"""
func _on_Tween_pop_out_completed() -> void:
	$Label.hide_message()
	$Panel.hide()
