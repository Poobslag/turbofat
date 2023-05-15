class_name NarrationLinePanel
extends Panel
## Displays a panel containing lines of narration for cutscenes.

## emitted after the full chat line is typed out onscreen
signal all_text_shown

@onready var _label: Label = $NarrationLabel
@onready var _label_typer: LabelTyper = $NarrationLabel/LabelTyper

func _ready() -> void:
	# hidden by default to avoid firing signals and playing sounds
	hide_message()


## Animates the label to gradually reveal the current text, mimicking speech.
##
## This function also calculates the duration to pause for each character. All visible characters cause a short pause.
## Newlines cause a long pause. Slashes cause a medium pause and are hidden from the player.
func show_message(text_with_lulls: String, initial_pause: float = 0.0) -> void:
	visible = true
	_label_typer.show_message(text_with_lulls, initial_pause)


func hide_message() -> void:
	visible = false
	_label_typer.hide_message()


## Returns 'true' if the label's visible_characters value is large enough to show all characters.
func is_all_text_visible() -> bool:
	return _label.visible_characters >= _label.get_total_character_count()


## Increases the label's visible_characters value to to show all characters.
func make_all_text_visible() -> void:
	_label_typer.make_all_text_visible()


func _on_LabelTyper_all_text_shown() -> void:
	emit_signal("all_text_shown")
