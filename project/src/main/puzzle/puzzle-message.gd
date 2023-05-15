class_name PuzzleMessage
extends Control
## Shows a stylized message during puzzles like "You Win!"
##
## These messages come in multiple varieties, but include elaborate outlines, colors and decorations to give them a
## fun look.

enum MessageType {
	NEUTRAL,
	GOOD,
	BAD,
}

const NEUTRAL := MessageType.NEUTRAL
const GOOD := MessageType.GOOD
const BAD := MessageType.BAD

## dark font outline colors for different types of messages
const OUTLINE_COLOR_BY_TYPE := {
	MessageType.NEUTRAL: Color("2b2b81"),
	MessageType.GOOD: Color("7f6316"),
	MessageType.BAD: Color("6937b3"),
}

## font colors for different types of messages
const FONT_COLOR_BY_TYPE := {
	MessageType.NEUTRAL: Color("c8ebfc"),
	MessageType.GOOD: Color("ffee85"),
	MessageType.BAD: Color("e7d6ff"),
}

## accent textures for different types of messages
var _word_accent_bad := preload("res://assets/main/puzzle/word-accent-bad.png")
var _word_accent_bad_wide := preload("res://assets/main/puzzle/word-accent-bad-wide.png")
var _word_accent_good := preload("res://assets/main/puzzle/word-accent-good.png")
var _word_accent_good_wide := preload("res://assets/main/puzzle/word-accent-good-wide.png")
var _word_accent_neutral := preload("res://assets/main/puzzle/word-accent-neutral.png")
var _word_accent_neutral_wide := preload("res://assets/main/puzzle/word-accent-neutral-wide.png")

## Godot cannot vertically align text (!?) or render text with multiple outlines, so we use 3 different controls to
## align and render it
##
## https://github.com/godotengine/godot-proposals/issues/4458
onready var _text_holder := $TextHolder
onready var _label := $TextHolder/Label
onready var _outline_label := $TextHolder/OutlineLabel

## accent sprite which appears as a shadow or backdrop behind the text
onready var _accent := $Accent

## animates the text popping in/out
onready var _animation_player := $AnimationPlayer

## Raw message text currently shown on the label. Empty if the label is invisible or turning invisible.
var shown_message_text := ""

func _ready() -> void:
	_text_holder.visible = false


## Shows the specified message, popping it in with an animation.
##
## Parameters:
## 	'message_type': Enum from MessageType describing whether the message is good or bad.
##
## 	'text': The message text.
func show_message(message_type: int, text: String) -> void:
	shown_message_text = text
	
	_assign_label_text(message_type, text)
	_assign_accent_texture(message_type, text)
	_assign_boundaries(message_type, text)
	_assign_colors(message_type, text)
	
	_animation_player.stop()
	_animation_player.play("pop-in")


## Hides the message, popping it out with an animation.
func hide_message() -> void:
	shown_message_text = ""
	
	if _text_holder.visible:
		_animation_player.stop()
		_animation_player.play("pop-out")


## Decorates the specified text in bbcode and assigns it to the label.
func _assign_label_text(message_type: int, text: String) -> void:
	var bbcode_text := text
	
	match message_type:
		GOOD:
			bbcode_text = "[wave amp=40 freq=8]%s[/wave]" % [bbcode_text]
		NEUTRAL:
			bbcode_text = "[wave amp=0 freq=0]%s[/wave]" % [bbcode_text]
		BAD:
			bbcode_text = "[tornado radius=2 freq=4]%s[/tornado]" % [bbcode_text]
	bbcode_text = "[center]%s[/center]" % [bbcode_text]
	
	_label.bbcode_text = bbcode_text
	_label.bbcode_enabled = true
	_outline_label.bbcode_text = bbcode_text
	_outline_label.bbcode_enabled = true


## Updates the accent texture based on the message type.
##
## Good messages get more uplifting, bubbly accents. Wide messages get wider accents.
func _assign_accent_texture(message_type: int, text: String) -> void:
	# check if any lines is more than 200 pixels wide
	var wide_message: bool = false
	for line in text.split("\n"):
		if _label.get("custom_fonts/normal_font").get_string_size(line).x > 200:
			wide_message = true
			break
	
	match message_type:
		GOOD:
			_accent.texture = _word_accent_good_wide if wide_message else _word_accent_good
		NEUTRAL:
			_accent.texture = _word_accent_neutral_wide if wide_message else _word_accent_neutral
		BAD:
			_accent.texture = _word_accent_bad_wide if wide_message else _word_accent_bad


## Moves the labels and accent sprite based on the message size.
##
## For multiline messages, we rearrange the labels and accent sprite to stay vertically centered.
func _assign_boundaries(_message_type: int, text: String) -> void:
	_label.rect_size.y = 150 if "\n" in text else 60
	_label.margin_top = 22 if "\n" in text else 45
	_label.margin_bottom = 22 if "\n" in text else 45
	
	_outline_label.rect_size.y = _label.rect_size.y
	_outline_label.margin_top = _label.margin_top
	_outline_label.margin_bottom = _label.margin_bottom
	
	_accent.margin_top = -277 if "\n" in text else -300
	_accent.margin_bottom = 323 if "\n" in text else 300


## Updates the color for the labels and accent sprite.
func _assign_colors(message_type: int, _text: String) -> void:
	var label_font: DynamicFont = _label.get("custom_fonts/normal_font")
	label_font.outline_color = OUTLINE_COLOR_BY_TYPE[message_type]
	_label.set("custom_colors/default_color", FONT_COLOR_BY_TYPE[message_type])
	
	var outline_label_font: DynamicFont = _outline_label.get("custom_fonts/normal_font")
	outline_label_font.outline_color = Utils.to_transparent(FONT_COLOR_BY_TYPE[message_type], 0.75)
	
	# the 'modulate' property is used by the pop in/pop out animations to make the accent transparent, so we use the
	# self_modulate property to assign a color
	_accent.self_modulate = OUTLINE_COLOR_BY_TYPE[message_type]
