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
	rect_position.y = 2 - rect_size.y
	if nametag_right:
		rect_position.x = get_parent().rect_size.x - rect_size.x - 12
	else:
		rect_position.x = 12
