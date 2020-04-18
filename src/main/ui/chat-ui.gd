extends Control
"""
Displays UI elements for chatting.

The chat window is decorated with objects in the background called 'accents'. These accents can be injected with the
set_accent_def function to configure the chat window's appearance.
"""

func _ready() -> void:
	$Holder/SentenceManager.hide_labels()
	$Holder/SentenceSprite/NametagManager.hide_labels()


"""
Animates the chat UI to gradually reveal the specified text, mimicking speech.

Also updates the chat UI's appearance based on the amount of text being displayed and the specified color and
background texture.
"""
func play_text(name: String, text: String, accent_def: Dictionary) -> void:
	# set the text and update the stored size fields
	$Holder/SentenceManager.set_text(text)
	$Holder/SentenceSprite/NametagManager.set_nametag_text(name)
	
	# update the UI's appearance
	var chat_appearance: ChatAppearance = ChatAppearance.new(accent_def)
	$Holder/SentenceManager.hide_labels()
	$Holder/SentenceSprite/NametagManager.hide_labels()
	$Holder/SentenceManager.show_label(chat_appearance)
	$Holder/SentenceSprite/NametagManager.show_label(chat_appearance, $Holder/SentenceManager.sentence_size)
	$Holder/SentenceSprite.update_appearance(chat_appearance, $Holder/SentenceManager.sentence_size)
