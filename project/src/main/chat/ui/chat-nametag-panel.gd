extends NametagPanel
## Repositions and shows nametag labels for chat windows.

## Recolors and repositions the nametag based on the current accent definition.
##
## Parameters:
## 	'chat_theme': metadata about the chat window's appearance.
##
## 	'nametag_right': true/false if the nametag should be drawn on the right/left side of the frame.
func show_label(chat_theme: ChatTheme, nametag_right: bool) -> void:
	if nametag_size == ChatTheme.NAMETAG_OFF:
		return
	
	refresh_chat_theme(chat_theme)
	position.y = 2 - size.y
	if nametag_right:
		position.x = get_parent().size.x - size.x - 12
	else:
		position.x = 12
