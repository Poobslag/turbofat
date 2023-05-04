class_name TutorialDiagram
extends Control
## Displays a diagram during a tutorial.
##
## These diagrams obstruct the playfield. They're textures which appear in a window, and the player has ok/help buttons
## to ensure they understand the diagram.

## Emitted when the player clicks a button indicating they understand the diagram
signal ok_chosen

## Emitted when the player clicks a button indicating they don't understand the diagram
signal help_chosen

## Number of times the diagram has been shown. We cycle through different chat choices each time.
var _show_diagram_count := 0

@onready var _hud: Node = get_parent()
@onready var _chat_choices: ChatChoices = $VBoxContainer/ChatChoices

func _ready() -> void:
	PuzzleState.game_ended.connect(_on_PuzzleState_game_ended)
	PuzzleState.game_prepared.connect(_on_PuzzleState_game_prepared)
	hide()


## Cleanup any temporary timers and listeners.
##
## This prevents the tutorial from behaving unexpectedly if the player restarts at an unusual time.
func cleanup_listeners() -> void:
	if _hud.messages.all_messages_shown.is_connected(_on_TutorialMessages_all_messages_shown_show_choices):
		_hud.messages.all_messages_shown.disconnect(_on_TutorialMessages_all_messages_shown_show_choices)


func show_diagram(texture: Texture2D, show_choices: bool = false) -> void:
	show()
	$VBoxContainer/TextureMarginContainer/TexturePanel/TextureRect.texture = texture
	
	# shift the diagram up to make room for chat choices
	if show_choices:
		$VBoxContainer/TextureMarginContainer.set("theme_override_constants/margin_top", 10)
		$VBoxContainer/TextureMarginContainer.set("theme_override_constants/margin_bottom", 10)
		_chat_choices.visible = true
	else:
		$VBoxContainer/TextureMarginContainer.set("theme_override_constants/margin_top", 85)
		$VBoxContainer/TextureMarginContainer.set("theme_override_constants/margin_bottom", 85)
		_chat_choices.visible = false
	
	if show_choices:
		if not _hud.messages.is_all_messages_visible():
			_hud.messages.all_messages_shown.connect(_on_TutorialMessages_all_messages_shown_show_choices)
		else:
			_show_choices()


func _show_choices() -> void:
	var choices: Array
	match _show_diagram_count % 3:
		0: choices = [tr("Okay, I get it!"), tr("...Can you go into more detail?")]
		1: choices = [tr("Yes, I see!"), tr("What do you mean by that?")]
		2: choices = [tr("Oh! That's easy."), tr("Hmm, maybe one more time?")]
	_show_diagram_count += 1
	var moods := [Creatures.Mood.SMILE0, Creatures.Mood.THINK0]
	_chat_choices.show_choices(choices, moods, 2)


func _on_TutorialMessages_all_messages_shown_show_choices() -> void:
	_hud.messages.all_messages_shown.disconnect(_on_TutorialMessages_all_messages_shown_show_choices)
	_show_choices()


func _on_ChatChoices_chat_choice_chosen(choice_index: int) -> void:
	match choice_index:
		0: emit_signal("ok_chosen")
		1: emit_signal("help_chosen")


func _on_PuzzleState_game_ended() -> void:
	cleanup_listeners()
	_chat_choices.hide_choices()


func _on_PuzzleState_game_prepared() -> void:
	cleanup_listeners()
