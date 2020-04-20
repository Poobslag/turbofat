class_name ChatEvent
"""
Contains details for a line of spoken text shown to the player.
"""

# The name of the person speaking, or blank if nobody is speaking
var name: String

# The text being spoken
var text: String

"""
The chat window changes its appearance based on who's talking. For example, one character's speech might be blue with
a black background, and giant blue soccer balls in the background. The 'accent_def' property defines the chat window's
appearance, such as 'blue', 'soccer balls' and 'giant'.

'accent_def/accent_scale': The scale of the accent's background texture
'accent_def/accent_swapped': If 'true', the accent's foreground/background colors will be swapped
'accent_def/accent_texture': A number in the range [0, 15] referring to a background texture
'accent_def/color': The color of the chat window
'accent_def/dark': True/false for whether the sentence window's background should be black/white
'accent_def/nametag_right': True/false for whether the nametag should be shown on the right/left side
"""
var accent_def: Dictionary
