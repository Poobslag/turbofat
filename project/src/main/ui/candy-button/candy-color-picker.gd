class_name CandyColorPicker
extends Panel
## A widget that provides an interface for selecting or modifying a color.
##
## This serves an identical purpose to Godot's ColorPicker widget, but supports gamepads and keyboards, and matches
## the game's UI.

## Emitted when the color is changed.
signal color_changed(color)

## Saturation threshold below which a palette color is considered grey, and moved to the end.
const SATURATION_THRESHOLD := 0.1

## Value threshold above which a palette color is considered black, and moved to the end.
const VALUE_THRESHOLD := 0.1

export (PackedScene) var CandyColorPickerButtonScene: PackedScene

## The currently selected color.
var color: Color setget set_color

## (Color) Color presets available to the player.
var color_presets: Array setget set_color_presets

## If 'true', the HSV sliders will not respond to value changes. (This is used temporarily to prevent the HSV sliders
## from reacting to themselves.)
var _suppress_hsv_slider_adjustment := false

onready var _presets_container: Container = $VBoxContainer/PresetsContainer

## Separates the presets from the HSV sliders.
onready var _spacer: Control = $VBoxContainer/Spacer

onready var _hue_slider: HsvSlider = $VBoxContainer/HsvContainer/HueSlider
onready var _saturation_slider: HsvSlider = $VBoxContainer/HsvContainer/SaturationSlider
onready var _value_slider: HsvSlider = $VBoxContainer/HsvContainer/ValueSlider
onready var _vbox_container := $VBoxContainer


func _ready() -> void:
	_refresh_color()
	_refresh_color_presets()
	_refresh_size()


## Steals the focus from another control and becomes the focused control.
##
## This control itself doesn't have focus, so we delegate to a child control.
func grab_focus() -> void:
	var focusable_nodes := Utils.find_focusable_nodes(self)
	if focusable_nodes:
		focusable_nodes[0].grab_focus()


func set_color(new_color: Color) -> void:
	if color == new_color:
		return
	
	color = new_color
	_refresh_color()


func set_color_presets(new_color_presets: Array) -> void:
	color_presets = new_color_presets
	
	_refresh_color_presets()
	_refresh_size()


## Updates the currently displayed color, moving the HSV sliders.
func _refresh_color() -> void:
	if not is_inside_tree():
		return
	
	if _suppress_hsv_slider_adjustment:
		# avoid recursively changing the sliders in response to sliders changing
		pass
	else:
		_hue_slider.value = lerp(0, 255, color.h)
		_saturation_slider.value = lerp(0, 255, color.s)
		_value_slider.value = lerp(0, 255, color.v)


## Recreates our CandyColorPickerButton instances based on our color_presets field.
func _refresh_color_presets() -> void:
	if not is_inside_tree():
		return
	
	for child in _presets_container.get_children():
		child.queue_free()
	
	var sorted_color_presets := _sort_color_presets()
	
	for color_preset in sorted_color_presets:
		var candy_color_picker_button: CandyColorPickerButton = CandyColorPickerButtonScene.instance()
		candy_color_picker_button.color = color_preset
		_presets_container.add_child(candy_color_picker_button)
		
		candy_color_picker_button.connect("pressed", self, "_on_CandyColorPickerButton_pressed", [color_preset])
	
	_presets_container.visible = true if color_presets else false
	_spacer.visible = true if _presets_container.visible else false


## Returns a sorted copy of our color_presets field.
##
## The color presets are arranged by color from left-to-right, and by brightness from top-to-bottom. Grey colors are
## sorted to the bottom right.
func _sort_color_presets() -> Array:
	var result := []
	var colors_by_hue := color_presets.duplicate()
	colors_by_hue.sort_custom(self, "_compare_by_hue")
	
	var buckets := []
	
	while not colors_by_hue.empty():
		var end := ceil(colors_by_hue.size() / float(8 - buckets.size())) - 1
		buckets.append(colors_by_hue.slice(0, end))
		colors_by_hue = colors_by_hue.slice(end + 1, colors_by_hue.size())
	
	for i in range(buckets.size()):
		buckets[i].sort_custom(self, "_compare_by_brightness")
	
	for i in range(color_presets.size()):
		# warning-ignore:integer_division
		result.append(buckets[i % 8][int(i / 8)])
	
	return result


func _compare_by_hue(a: Color, b: Color) -> bool:
	return fmod(a.h + 0.05, 1.0) + (10 if a.s < SATURATION_THRESHOLD or a.v < VALUE_THRESHOLD else 0) \
			< fmod(b.h + 0.05, 1.0) + (10 if b.s < SATURATION_THRESHOLD or b.v < VALUE_THRESHOLD else 0)


func _compare_by_brightness(a: Color, b: Color) -> bool:
	return Utils.brightness(a) + (-10 if a.s < SATURATION_THRESHOLD or a.v < VALUE_THRESHOLD else 0) \
			> Utils.brightness(b) + (-10 if b.s < SATURATION_THRESHOLD or b.v < VALUE_THRESHOLD else 0)


## Resize the color picker based on the size of its children.
func _refresh_size() -> void:
	if not is_inside_tree():
		return
	
	if not _vbox_container:
		return
	
	var new_rect_size: Vector2 = _vbox_container.rect_size
	
	# Godot's Containers such as VBoxContainer and GridContainer visibly collapse invisible elements, so intuitively,
	# you might expect this to affect their rect_size attributes as well. However, the behavior of containers is
	# incredibly erratic in this regard.
	#
	# This clumsy behavior with a magic value of "22" works, I'm not entirely sure why.
	if not _presets_container.visible:
		new_rect_size.y -= 22
		new_rect_size.y -= _presets_container.get_constant("separation", "VBoxContainer")
	
	rect_min_size = new_rect_size + Vector2(12, 12)
	rect_size = rect_min_size


func _on_CandyColorPickerButton_pressed(new_color: Color) -> void:
	if color == new_color:
		return
	
	set_color(new_color)
	emit_signal("color_changed", color)


func _on_HsvSlider_value_changed(_value: int) -> void:
	# temporarily prevent the HSV sliders from reacting to themselves
	_suppress_hsv_slider_adjustment = true
	
	var hue := inverse_lerp(0, 255, _hue_slider.value)
	var saturation := inverse_lerp(0, 255, _saturation_slider.value)
	var value := inverse_lerp(0, 255, _value_slider.value)
	var new_color: Color = Color.from_hsv(hue, saturation, value)
	
	set_color(new_color)
	emit_signal("color_changed", color)
	
	_suppress_hsv_slider_adjustment = false


func _on_VBoxContainer_resized() -> void:
	if not _vbox_container:
		# avoid resizing the parent component before its children are initialized
		return
	
	_refresh_size()
