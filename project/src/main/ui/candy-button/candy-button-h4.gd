tool
extends TextureButton
## An eye-catching button with customizable colors and textures.

signal color_changed

signal disabled_changed

signal hovered_changed

## Textures for the various ButtonShape presets.
##
## key: (int) Enum from ButtonShape
## value: (Array, Texture) Array with two entries for the textures for the specified shape:
## 	value[0]: (Texture) texture to use when the button is not pressed.
## 	value[1]: (Texture) texture to use when the button is pressed.
const TEXTURES_BY_SHAPE := {
	CandyButtons.ButtonShape.NONE: [
		preload("res://assets/main/ui/candy-button/h4-blank.png"),
		preload("res://assets/main/ui/candy-button/h4-blank-pressed.png")],
	CandyButtons.ButtonShape.PIECE_J: [
		preload("res://assets/main/ui/candy-button/h4-j.png"),
		preload("res://assets/main/ui/candy-button/h4-j-pressed.png")],
	CandyButtons.ButtonShape.PIECE_L: [
		preload("res://assets/main/ui/candy-button/h4-l.png"),
		preload("res://assets/main/ui/candy-button/h4-l-pressed.png")],
	CandyButtons.ButtonShape.PIECE_O: [
		preload("res://assets/main/ui/candy-button/h4-o.png"),
		preload("res://assets/main/ui/candy-button/h4-o-pressed.png")],
	CandyButtons.ButtonShape.PIECE_P: [
		preload("res://assets/main/ui/candy-button/h4-p.png"),
		preload("res://assets/main/ui/candy-button/h4-p-pressed.png")],
	CandyButtons.ButtonShape.PIECE_Q: [
		preload("res://assets/main/ui/candy-button/h4-q.png"),
		preload("res://assets/main/ui/candy-button/h4-q-pressed.png")],
	CandyButtons.ButtonShape.PIECE_T: [
		preload("res://assets/main/ui/candy-button/h4-t.png"),
		preload("res://assets/main/ui/candy-button/h4-t-pressed.png")],
	CandyButtons.ButtonShape.PIECE_U: [
		preload("res://assets/main/ui/candy-button/h4-u.png"),
		preload("res://assets/main/ui/candy-button/h4-u-pressed.png")],
	CandyButtons.ButtonShape.PIECE_V: [
		preload("res://assets/main/ui/candy-button/h4-v.png"),
		preload("res://assets/main/ui/candy-button/h4-v-pressed.png")],
}

export (String) var text setget set_text

export (CandyButtons.ButtonColor) var color setget set_color

## Repeating piece shapes which decorate the button.
export (CandyButtons.ButtonShape) var shape setget set_shape

## Different fonts to try. Should be ordered from largest to smallest.
export (Array, Font) var fonts := [
	preload("res://src/main/ui/candy-button/candy-h4-font.tres"),
	preload("res://src/main/ui/candy-button/candy-h5-font.tres"),
	preload("res://src/main/ui/candy-button/candy-h6-font.tres"),
]

onready var _click_sound := $ClickSound
onready var _hover_sound := $HoverSound

## Label containing the button's text
onready var _label := $Label

onready var _gradient_helper: GradientHelper = $GradientHelper

func _ready() -> void:
	# Connect signals in code to prevent them from showing up in the Godot editor.
	#
	# This is a generic button used in many places, we want to be able to quickly see the unique signals connected to
	# each button instance, not the generic signals connected to all button instances.
	connect("focus_entered", self, "_on_focus_entered")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	_gradient_helper.connect("gradient_changed", self, "_on_GradientHelper_gradient_changed")
	
	_refresh_font_size()
	_refresh_text()
	_refresh_shape()
	_refresh_color()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


func _pressed() -> void:
	_click_sound.pitch_scale = rand_range(0.95, 1.05)
	SfxKeeper.copy(_click_sound).play()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()
	_refresh_font_size()


func set_color(new_color: int) -> void:
	color = new_color
	_refresh_color()
	emit_signal("color_changed")


func set_shape(new_shape: int) -> void:
	shape = new_shape
	_refresh_shape()


func set_disabled(new_disabled: bool) -> void:
	if disabled == new_disabled:
		return
	
	disabled = new_disabled
	_refresh_color()
	emit_signal("disabled_changed")


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_label = $Label
	_gradient_helper = $GradientHelper


func _apply_mouse_entered_effects() -> void:
	# disconnect our one-shot method
	if get_tree().is_connected("idle_frame", self, "_apply_mouse_entered_effects"):
		get_tree().disconnect("idle_frame", self, "_apply_mouse_entered_effects")
	emit_signal("hovered_changed")
	_hover_sound.pitch_scale = rand_range(0.95, 1.05)
	SfxKeeper.copy(_hover_sound).play()


func _apply_mouse_exited_effects() -> void:
	if get_tree().is_connected("idle_frame", self, "_apply_mouse_exited_effects"):
		get_tree().disconnect("idle_frame", self, "_apply_mouse_exited_effects")
	emit_signal("hovered_changed")


## Reapplies the colors for our texture, text and icons.
func _refresh_color() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	material.get_shader_param("gradient").gradient = _gradient_helper.gradient
	_refresh_label_color()


## Sets the button's font to the largest font which will accommodate its text.
func _refresh_font_size() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	# our shown text is translated; the translated text needs to fit in the button
	var shown_text := tr(text)
	
	var available_size := 110
	
	var chosen_font: Font
	for next_font in fonts:
		# start with the largest font, and try smaller and smaller fonts
		chosen_font = next_font
		var string_width := chosen_font.get_string_size(shown_text).x
		if string_width < available_size:
			# this font is small enough to accommodate all of the text
			break
	
	# duplicate the font so that each instance can have its own outline color
	_label.set("custom_fonts/font", chosen_font.duplicate())
	_refresh_label_color()


## Reapplies the colors for our label.
func _refresh_label_color() -> void:
	_label.get_font("font").outline_color = _gradient_helper.gradient.interpolate(
				0.25 if has_focus() else 0.15)


## Reapplies the various textures for our button.
func _refresh_shape() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	var textures: Array = TEXTURES_BY_SHAPE[shape]
	texture_normal = textures[0]
	texture_pressed = textures[1]
	texture_hover = textures[0]


## Updates our label's text.
func _refresh_text() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_label.text = text


## When we gain focus, we reapply a bright cyan color for our texture, text and icons.
func _on_focus_entered() -> void:
	_hover_sound.pitch_scale = rand_range(0.95, 1.05)
	SfxKeeper.copy(_hover_sound).play()


## When the player hovers over us, we reapply a brighter color for our texture, text and icons.
func _on_mouse_entered() -> void:
	if disabled:
		return
	
	if is_inside_tree():
		# Wait a frame before applying mouse entered effects. We use a one-shot listener method instead of a yield
		# statement to avoid 'class instance is gone' errors.
		if not get_tree().is_connected("idle_frame", self, "_apply_mouse_entered_effects"):
			get_tree().connect("idle_frame", self, "_apply_mouse_entered_effects")
	else:
		_apply_mouse_entered_effects()


## When the player hovers away from us, we reapply the normal color for our texture, text and icons.
func _on_mouse_exited() -> void:
	if disabled:
		return
	
	if is_inside_tree():
		# Wait a frame before applying mouse exited effects. We use a one-shot listener method instead of a yield
		# statement to avoid 'class instance is gone' errors.
		if not get_tree().is_connected("idle_frame", self, "_apply_mouse_exited_effects"):
			get_tree().connect("idle_frame", self, "_apply_mouse_exited_effects")
	else:
		_apply_mouse_exited_effects()


func _on_GradientHelper_gradient_changed() -> void:
	_refresh_color()
