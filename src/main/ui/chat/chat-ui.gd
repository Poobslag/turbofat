extends Control
"""
Displays UI elements for chatting.

The chat window is decorated with objects in the background called 'accents'. These accents can be injected with the
set_accent_def function to configure the chat window's appearance.
"""

signal pop_out_completed

func _ready() -> void:
	$ChatFrame/SentenceManager.hide_labels()
	$ChatFrame/SentenceSprite/NametagManager.hide_labels()


"""
Makes the chat window appear.
"""
func pop_in() -> void:
	if $ChatFrame/SentenceManager.label_showing():
		# chat window is already visible
		return
	
	$ChatFrame/SentenceManager.hide_labels()
	$ChatFrame/SentenceSprite/NametagManager.hide_labels()
	$ChatFrame/Tween.pop_in()
	$PopInSound.play()


"""
Makes the chat window disappear.
"""
func pop_out() -> void:
	if not $ChatFrame/SentenceManager.label_showing():
		# chat window is already invisible
		return
	
	$ChatFrame/Tween.pop_out()
	$PopOutSound.play()


"""
Animates the chat UI to gradually reveal the specified text, mimicking speech.

Also updates the chat UI's appearance based on the amount of text being displayed and the specified color and
background texture.
"""
func play_text(name: String, text: String, accent_def: Dictionary) -> void:
	if not $ChatFrame/SentenceManager.label_showing():
		# Ensure the chat window is showing before we start changing its text and playing sounds
		pop_in()
	
	# set the text and update the stored size fields
	$ChatFrame/SentenceManager.set_text(text)
	$ChatFrame/SentenceSprite/NametagManager.set_nametag_text(name)
	
	# update the UI's appearance
	var chat_appearance: ChatAppearance = ChatAppearance.new(accent_def)
	$ChatFrame/SentenceManager.hide_labels()
	$ChatFrame/SentenceSprite/NametagManager.hide_labels()
	$ChatFrame/SentenceManager.show_label(chat_appearance, 0.5)
	$ChatFrame/SentenceSprite/NametagManager.show_label(chat_appearance, $ChatFrame/SentenceManager.sentence_size)
	$ChatFrame/SentenceSprite.update_appearance(chat_appearance, $ChatFrame/SentenceManager.sentence_size)


func chat_window_showing() -> bool:
	return $ChatFrame/SentenceManager.label_showing()


func _on_Tween_pop_out_completed() -> void:
	# Call sentenceManager.hide_labels() to prevent sounds from playing
	$ChatFrame/SentenceManager.hide_labels()
	$ChatFrame/SentenceSprite/NametagManager.hide_labels()
	emit_signal("pop_out_completed")
