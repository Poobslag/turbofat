class_name ChatLineLabel
extends RectFitLabel
## Label which animates text in a way that mimics speech.
##
## Text appears a letter at a time at a constant rate. Newlines cause a long pause. Slashes cause a shorter pause and
## are hidden from the player. Slashes are referred to 'lull characters' throughout the code.

## emitted after the full chat line is typed out onscreen
signal all_text_shown

## Amount of empty space between the text borders and panel borders.
@export (Vector2) var panel_padding: Vector2

@export (NodePath) var chat_line_panel_path: NodePath

@onready var chat_line_panel: ChatLinePanel = get_node(chat_line_panel_path)

@onready var _label_typer := $LabelTyper

func _ready() -> void:
	# Populate the chat line sizes based on the chat line panel sizes.
	# They're the same except for a little padding on the outside.
	var new_sizes := []
	for panel_size in chat_line_panel.panel_sizes:
		new_sizes.append(panel_size - panel_padding)
	set_sizes(new_sizes)
	
	# hidden by default to avoid firing signals and playing sounds
	hide_message()


## Animates the label to gradually reveal the current text, mimicking speech.
##
## This function also calculates the duration to pause for each character. All visible characters cause a short pause.
## Newlines cause a long pause. Slashes cause a medium pause and are hidden from the player.
##
## Returns a ChatTheme.ChatLineSize corresponding to the required chat frame size.
func show_message(text_with_lulls: String, initial_pause: float = 0.0) -> int:
	_label_typer.show_message(text_with_lulls, initial_pause)
	pick_smallest_size()
	return chosen_size_index


## Recolors the chat line label based on the specified chat appearance.
func update_appearance(chat_theme: ChatTheme) -> void:
	set("theme_override_colors/font_color", chat_theme.border_color)


func hide_message() -> void:
	_label_typer.hide_message()


## Returns 'true' if the label's visible_characters value is large enough to show all characters.
func is_all_text_visible() -> bool:
	return visible_characters >= get_total_character_count()


## Increases the label's visible_characters value to to show all characters.
func make_all_text_visible() -> void:
	_label_typer.make_all_text_visible()


func _on_LabelTyper_all_text_shown() -> void:
	emit_signal("all_text_shown")
