extends Control
"""
Displays UI elements for having a conversation.
"""

"""
Animates the conversation UI to gradually reveal the specified text, mimicking speech.
"""
func play_text(text_with_pauses: String) -> void:
	$Holder/Panel/Label.play_text(text_with_pauses)
