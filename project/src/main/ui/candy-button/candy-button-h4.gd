tool
extends TextureButton
## An eye-catching button with customizable colors and textures.

enum ButtonColor {
	NONE,
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	BLUE,
	INDIGO,
	VIOLET,
}

## Repeating piece shapes which decorate the button.
enum ButtonShape {
	NONE,
	PIECE_J,
	PIECE_L,
	PIECE_O,
	PIECE_P,
	PIECE_Q,
	PIECE_T,
	PIECE_U,
	PIECE_V,
}

export (String) var text setget set_text

export (ButtonColor) var color setget set_color

## Repeating piece shapes which decorate the button.
export (ButtonShape) var shape setget set_shape

## Different fonts to try. Should be ordered from largest to smallest.
export (Array, Font) var fonts := [
	preload("res://src/main/ui/candy-button/candy-h4-font.tres"),
	preload("res://src/main/ui/candy-button/candy-h5-font.tres"),
	preload("res://src/main/ui/candy-button/candy-h6-font.tres"),
]

## Gradient which colors the button bright cyan when the button is focused.
var _gradient_focused: Gradient = preload("res://src/main/ui/candy-button/gradient-focused.tres")

## Gradient which colors the button bright cyan when the button is focused and hovered.
var _gradient_focused_hover: Gradient = preload("res://src/main/ui/candy-button/gradient-focused-hover.tres")

## Bright shiny reflection texture which overlays the button and text when the button is not pressed.
var _shine_texture_normal: Texture = preload("res://assets/main/ui/h4-shine.png")

## Less shiny reflection texture which overlays the button and text when the button is pressed.
var _shine_texture_pressed: Texture = preload("res://assets/main/ui/h4-shine-pressed.png")

## Gradients for the various ButtonColor presets.
##
## key: (int) Enum from ButtonColor
## value: (Array) Array with two entries for the gradients for the specified color:
## 	value[0]: (Gradient) Gradient to use when the button is not hovered.
## 	value[1]: (Gradient) Gradient to use when the button is hovered.
var _gradients_by_button_color := {
	ButtonColor.NONE: [
		preload("res://src/main/ui/candy-button/gradient-none.tres"),
		preload("res://src/main/ui/candy-button/gradient-none.tres")],
	ButtonColor.RED: [
		preload("res://src/main/ui/candy-button/gradient-red-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-red-hover.tres")],
	ButtonColor.ORANGE: [
		preload("res://src/main/ui/candy-button/gradient-orange-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-orange-hover.tres")],
	ButtonColor.YELLOW: [
		preload("res://src/main/ui/candy-button/gradient-yellow-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-yellow-hover.tres")],
	ButtonColor.GREEN: [
		preload("res://src/main/ui/candy-button/gradient-green-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-green-hover.tres")],
	ButtonColor.BLUE: [
		preload("res://src/main/ui/candy-button/gradient-blue-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-blue-hover.tres")],
	ButtonColor.INDIGO: [
		preload("res://src/main/ui/candy-button/gradient-indigo-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-indigo-hover.tres")],
	ButtonColor.VIOLET: [
		preload("res://src/main/ui/candy-button/gradient-violet-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-violet-hover.tres")],
}

## Textures for the various ButtonShape presets.
##
## key: (int) Enum from ButtonShape
## value: (Array) Array with two entries for the textures for the specified shape:
## 	value[0]: (Texture) texture to use when the button is not pressed.
## 	value[1]: (Texture) texture to use when the button is pressed.
var _textures_by_button_shape := {
	ButtonShape.NONE: [
		preload("res://assets/main/ui/h4.png"),
		preload("res://assets/main/ui/h4-pressed.png")],
	ButtonShape.PIECE_J: [
		preload("res://assets/main/ui/h4-j.png"),
		preload("res://assets/main/ui/h4-j-pressed.png")],
	ButtonShape.PIECE_L: [
		preload("res://assets/main/ui/h4-l.png"),
		preload("res://assets/main/ui/h4-l-pressed.png")],
	ButtonShape.PIECE_O: [
		preload("res://assets/main/ui/h4-o.png"),
		preload("res://assets/main/ui/h4-o-pressed.png")],
	ButtonShape.PIECE_P: [
		preload("res://assets/main/ui/h4-p.png"),
		preload("res://assets/main/ui/h4-p-pressed.png")],
	ButtonShape.PIECE_Q: [
		preload("res://assets/main/ui/h4-q.png"),
		preload("res://assets/main/ui/h4-q-pressed.png")],
	ButtonShape.PIECE_T: [
		preload("res://assets/main/ui/h4-t.png"),
		preload("res://assets/main/ui/h4-t-pressed.png")],
	ButtonShape.PIECE_U: [
		preload("res://assets/main/ui/h4-u.png"),
		preload("res://assets/main/ui/h4-u-pressed.png")],
	ButtonShape.PIECE_V: [
		preload("res://assets/main/ui/h4-v.png"),
		preload("res://assets/main/ui/h4-v-pressed.png")],
}

onready var _click_sound := $ClickSound
onready var _hover_sound := $HoverSound

## Label containing the button's text
onready var _label := $Label

## Shiny reflection effect which overlays the button and text
onready var _shine := $Shine

func _ready() -> void:
	_refresh_font_size()
	_refresh_text()
	_refresh_shape()
	_refresh_color()
	_refresh_shine()


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


func set_shape(new_shape: int) -> void:
	shape = new_shape
	_refresh_shape()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_label = $Label
	_shine = $Shine


## Calculates the gradient which should color the button based on its color and state.
func _gradient() -> Gradient:
	var result: Gradient
	if has_focus():
		# if the button is focused, we use a bright cyan color
		result = _gradient_focused_hover if is_hovered() else _gradient_focused
	else:
		# if the button is not focused, we use the user-specified color
		var gradients: Array = _gradients_by_button_color[color]
		result = gradients[1] if is_hovered() else gradients[0]
	return result


## Reapplies the colors for our texture, text and icons.
func _refresh_color() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	material.get_shader_param("gradient").gradient = _gradient()
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
	_label.get_font("font").outline_color = _gradient().interpolate(0.15)


## Reapplies the various textures for our button.
func _refresh_shape() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	var textures: Array = _textures_by_button_shape[shape]
	texture_normal = textures[0]
	texture_pressed = textures[1]
	texture_hover = textures[0]


## Updates the shine texture for our button.
func _refresh_shine() -> void:
	_shine.texture = _shine_texture_pressed if pressed else _shine_texture_normal


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
	_refresh_color()


## When we lose focus, we reapply the normal color for our texture, text and icons.
func _on_focus_exited() -> void:
	_refresh_color()


## When the player hovers over us, we reapply a brighter color for our texture, text and icons.
func _on_mouse_entered() -> void:
	if not disabled:
		yield(get_tree(), "idle_frame")
		_refresh_color()
		_hover_sound.pitch_scale = rand_range(0.95, 1.05)
		SfxKeeper.copy(_hover_sound).play()


## When the player hovers away from us, we reapply the normal color for our texture, text and icons.
func _on_mouse_exited() -> void:
	if not disabled:
		yield(get_tree(), "idle_frame")
		_refresh_color()


func _on_button_down() -> void:
	_refresh_shine()


func _on_button_up() -> void:
	_refresh_shine()