tool
extends TextureButton
## An eye-catching button with customizable colors and textures.

export (String) var text setget set_text

## Icon shown to the left of the button's text.
export (Texture) var icon_left setget set_icon_left

## Icon shown to the right of the button's text.
export (Texture) var icon_right setget set_icon_right

export (CandyButtons.ButtonColor) var color setget set_color

## Repeating piece shapes which decorate the button.
export (CandyButtons.ButtonShape) var shape setget set_shape

## Different fonts to try. Should be ordered from largest to smallest.
export (Array, Font) var fonts := [
	preload("res://src/main/ui/candy-button/candy-h3-font.tres"),
	preload("res://src/main/ui/candy-button/candy-h4-font.tres"),
	preload("res://src/main/ui/candy-button/candy-h5-font.tres"),
]

## Gradient which colors the button bright cyan when the button is focused.
var _gradient_focused: Gradient = preload("res://src/main/ui/candy-button/gradient-focused.tres")

## Gradient which colors the button bright cyan when the button is focused and hovered.
var _gradient_focused_hover: Gradient = preload("res://src/main/ui/candy-button/gradient-focused-hover.tres")

## Bright shiny reflection texture which overlays the button and text when the button is not pressed.
var _shine_texture_normal: Texture = preload("res://assets/main/ui/candy-button/h3-shine.png")

## Less shiny reflection texture which overlays the button and text when the button is pressed.
var _shine_texture_pressed: Texture = preload("res://assets/main/ui/candy-button/h3-shine-pressed.png")

## Gradients for the various ButtonColor presets.
##
## key: (int) Enum from ButtonColor
## value: (Array) Array with two entries for the gradients for the specified color:
## 	value[0]: (Gradient) Gradient to use when the button is not hovered.
## 	value[1]: (Gradient) Gradient to use when the button is hovered.
var _gradients_by_button_color := {
	CandyButtons.ButtonColor.NONE: [
		preload("res://src/main/ui/candy-button/gradient-none.tres"),
		preload("res://src/main/ui/candy-button/gradient-none-hover.tres")]
	CandyButtons.ButtonColor.RED: [
		preload("res://src/main/ui/candy-button/gradient-red-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-red-hover.tres")],
	CandyButtons.ButtonColor.ORANGE: [
		preload("res://src/main/ui/candy-button/gradient-orange-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-orange-hover.tres")],
	CandyButtons.ButtonColor.YELLOW: [
		preload("res://src/main/ui/candy-button/gradient-yellow-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-yellow-hover.tres")],
	CandyButtons.ButtonColor.GREEN: [
		preload("res://src/main/ui/candy-button/gradient-green-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-green-hover.tres")],
	CandyButtons.ButtonColor.BLUE: [
		preload("res://src/main/ui/candy-button/gradient-blue-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-blue-hover.tres")],
	CandyButtons.ButtonColor.INDIGO: [
		preload("res://src/main/ui/candy-button/gradient-indigo-normal.tres"),
		preload("res://src/main/ui/candy-button/gradient-indigo-hover.tres")],
	CandyButtons.ButtonColor.VIOLET: [
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
	CandyButtons.ButtonShape.NONE: [
		preload("res://assets/main/ui/candy-button/h3-blank.png"),
		preload("res://assets/main/ui/candy-button/h3-blank-pressed.png")],
	CandyButtons.ButtonShape.PIECE_J: [
		preload("res://assets/main/ui/candy-button/h3-j.png"),
		preload("res://assets/main/ui/candy-button/h3-j-pressed.png")],
	CandyButtons.ButtonShape.PIECE_L: [
		preload("res://assets/main/ui/candy-button/h3-l.png"),
		preload("res://assets/main/ui/candy-button/h3-l-pressed.png")],
	CandyButtons.ButtonShape.PIECE_O: [
		preload("res://assets/main/ui/candy-button/h3-o.png"),
		preload("res://assets/main/ui/candy-button/h3-o-pressed.png")],
	CandyButtons.ButtonShape.PIECE_P: [
		preload("res://assets/main/ui/candy-button/h3-p.png"),
		preload("res://assets/main/ui/candy-button/h3-p-pressed.png")],
	CandyButtons.ButtonShape.PIECE_Q: [
		preload("res://assets/main/ui/candy-button/h3-q.png"),
		preload("res://assets/main/ui/candy-button/h3-q-pressed.png")],
	CandyButtons.ButtonShape.PIECE_T: [
		preload("res://assets/main/ui/candy-button/h3-t.png"),
		preload("res://assets/main/ui/candy-button/h3-t-pressed.png")],
	CandyButtons.ButtonShape.PIECE_U: [
		preload("res://assets/main/ui/candy-button/h3-u.png"),
		preload("res://assets/main/ui/candy-button/h3-u-pressed.png")],
	CandyButtons.ButtonShape.PIECE_V: [
		preload("res://assets/main/ui/candy-button/h3-v.png"),
		preload("res://assets/main/ui/candy-button/h3-v-pressed.png")],
}


onready var _click_sound := $ClickSound
onready var _hover_sound := $HoverSound

## Icon shown to the left of the button's text
onready var _icon_node_left := $HBoxContainer/IconLeft

## Icon shown to the right of the button's text
onready var _icon_node_right := $HBoxContainer/IconRight

## Label containing the button's text
onready var _label := $HBoxContainer/Label

## Shiny reflection effect which overlays the button and text
onready var _shine := $Shine

func _ready() -> void:
	# Connect signals in code to prevent them from showing up in the Godot editor.
	#
	# This is a generic button used in many places, we want to be able to quickly see the unique signals connected to
	# each button instance, not the generic signals connected to all button instances.
	connect("button_down", self, "_on_button_down")
	connect("button_up", self, "_on_button_up")
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	
	_refresh_icons()
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


func set_icon_left(new_icon_left: Texture) -> void:
	icon_left = new_icon_left
	_refresh_icons()
	_refresh_font_size()


func set_icon_right(new_icon_right: Texture) -> void:
	icon_right = new_icon_right
	_refresh_icons()
	_refresh_font_size()


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
	_label = $HBoxContainer/Label
	_icon_node_left = $HBoxContainer/IconLeft
	_icon_node_right = $HBoxContainer/IconRight
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
	_refresh_icon_color()
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
	
	var available_size := 190
	if icon_left:
		available_size -= 35
	if icon_right:
		available_size -= 35
	
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


## Reapplies the colors for our icons.
func _refresh_icon_color() -> void:
	# both icons use the same material; setting one sets the other
	_icon_node_left.material.set_shader_param("black", _gradient().interpolate(0.15))


## Toggles the visibility of the left and right icons and updates their properties.
func _refresh_icons() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _label:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_icon_node_left.visible = true if icon_left else false
	_icon_node_left.texture = icon_left
	_icon_node_right.visible = true if icon_right else false
	_icon_node_right.texture = icon_right
	
	_refresh_icon_color()


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
