tool
class_name CreatureColorButton
extends TextureButton
## A button which pops up a ColorPicker, similar to ColorPickerButton.
##
## ColorPickerButton's UI is not sufficiently customizable, so we created our own version.

signal color_changed(color)

signal about_to_show

## Repeating piece shapes which decorate the button.
export (CandyButtons.ButtonShape) var shape setget set_shape

var creature_color: Color setget set_creature_color

## Virtual property; value is only exposed through getters/setters
var color_presets := [] setget set_color_presets

## List of String allele combos for which this button should be enabled. If unset, the button is always enabled.
var enabled_if := []

onready var _click_sound := $ClickSound
onready var _hover_sound := $HoverSound

## Icon showing a color swatch
onready var _icon := $Icon

onready var _popup := $Popup

func _ready() -> void:
	# Connect signals in code to prevent them from showing up in the Godot editor.
	#
	# This is a generic button used in many places, we want to be able to quickly see the unique signals connected to
	# each button instance, not the generic signals connected to all button instances.
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")

	_refresh_shape()
	_refresh_color()
	_refresh_creature_color()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


func _pressed() -> void:
	_click_sound.pitch_scale = rand_range(0.95, 1.05)
	SfxKeeper.copy(_click_sound).play()
	
	_popup.set_selected_color(creature_color)
	# calculate the popup position; it appears to the left of the button, but stays within the viewport
	var popup_position := get_global_transform().origin
	popup_position += Vector2(-_popup.rect_size.x, 0)
	var screen_size := get_viewport_rect().size
	popup_position.x = clamp(popup_position.x, 0, screen_size.x - _popup.rect_size.x)
	popup_position.y = clamp(popup_position.y, 0, screen_size.y - _popup.rect_size.y)
	
	_popup.popup(Rect2(popup_position, _popup.rect_size))


func set_color_presets(new_color_presets: Array) -> void:
	_popup.color_presets = new_color_presets


func set_disabled(new_disabled: bool) -> void:
	if disabled != new_disabled:
		disabled = new_disabled
		_refresh_color()
		_refresh_creature_color()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_click_sound = $ClickSound
	_hover_sound = $HoverSound
	_icon = $Icon
	_popup = $Popup


## Calculates the gradient which should color the button based on its color and state.
func _gradient() -> Gradient:
	var result: Gradient
	if has_focus():
		# if the button is focused, we use a bright cyan color
		result = CandyButtons.GRADIENT_FOCUSED_HOVER if is_hovered() else CandyButtons.GRADIENT_FOCUSED
	elif disabled:
		result = CandyButtons.GRADIENT_DISABLED_HOVER if is_hovered() else CandyButtons.GRADIENT_DISABLED
	else:
		# if the button is not focused, we use the default color
		var gradients: Array = CandyButtons.GRADIENTS_BY_COLOR[CandyButtons.ButtonColor.NONE]
		result = gradients[1] if is_hovered() else gradients[0]
	return result


func set_creature_color(new_creature_color: Color) -> void:
	creature_color = new_creature_color
	_refresh_creature_color()


func set_shape(new_shape: int) -> void:
	shape = new_shape
	_refresh_shape()


## Reapplies the colors for our texture, text and icons.
func _refresh_color() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _icon:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	material.get_shader_param("gradient").gradient = _gradient()


## Updates the button's apperance based on the creature's color.
func _refresh_creature_color() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _icon:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_icon.modulate = _gradient().interpolate(0.3) if disabled else creature_color


## Reapplies the various textures for our button.
func _refresh_shape() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _icon:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	var textures: Array = CandyButtons.C3_TEXTURES_BY_SHAPE[shape]
	texture_normal = textures[0]
	texture_pressed = textures[1]
	texture_hover = textures[0]


## When we gain focus, we reapply a bright cyan color for our texture, text and icons.
func _on_focus_entered() -> void:
	_refresh_color()
	_hover_sound.pitch_scale = rand_range(0.95, 1.05)
	SfxKeeper.copy(_hover_sound).play()


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


func _on_Popup_color_changed(color: Color) -> void:
	set_creature_color(color)
	emit_signal("color_changed", color)


func _on_Popup_about_to_show() -> void:
	emit_signal("about_to_show")


func _on_Popup_popup_hide() -> void:
	# If any CandyColorPickerButtons grab focus, focus is permanently lost unless we grab it back.
	grab_focus()
