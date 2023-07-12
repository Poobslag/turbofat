class_name PracticeSpeedSelector
extends VBoxContainer
## UI control for selecting piece speed in practice mode.

## Emitted when the player selects a new piece speed
signal speed_changed(speed)

## speeds which appear as tick mark labels
var speed_names: Array setget set_speed_names

## If true, the slider can be interacted with. If false, the value can be changed only by code.
var editable: bool = false setget set_editable

onready var _slider := $Slider
onready var _labels := $Labels

func set_editable(new_editable: bool) -> void:
	editable = new_editable
	_slider.editable = editable
	_refresh_labels()


## Sets the currently selected speed string such as '3' or 'A2'
func set_selected_speed(new_speed: String) -> void:
	_slider.value = speed_names.find(new_speed)


## Sets the speed names which appear as tick mark labels.
func set_speed_names(new_names: Array) -> void:
	speed_names = new_names
	
	if speed_names.size() == 1:
		# adjust the slider with a range of [0, 2] so it draws a tick at the center
		_slider.max_value = 2
		_slider.value = 1
		_slider.tick_count = 3
	else:
		# adjust the slider to allow a full range of values with ticks on each
		_slider.max_value = speed_names.size() - 1
		_slider.tick_count = speed_names.size()
	
	_refresh_labels()


## Updates the label text and color.
##
## The label text reflects the values in the speed_names array. The color changes to black if the slider is not
## editable.
func _refresh_labels() -> void:
	# clear out the old labels
	for child in _labels.get_children():
		# remove_child to ensure old labels don't affect lowlight calculations
		_labels.remove_child(child)
	
	# add the new labels
	var label_values := speed_names
	if label_values.size() == 1:
		# if there is only one label, we still add two outer labels to avoid alignment issues
		label_values = ["", label_values[0], ""]
	for name_obj in label_values:
		var name: String = name_obj
		var label := Label.new()
		label.text = name
		label.align = Label.ALIGN_CENTER
		label.size_flags_horizontal = Label.SIZE_EXPAND_FILL
		_labels.add_child(label)
	
	# toggle color based on editable property
	for i in range(_labels.get_child_count()):
		var label: Label = _labels.get_child(i)
		label.set("custom_colors/font_color", Color.white if editable else Color.black)
	
	# outermost labels take up less space; this helps the ticks align better
	if _labels.get_child_count() > 0:
		_labels.get_child(0).align = Label.ALIGN_LEFT
		_labels.get_child(_labels.get_child_count() - 1).align = Label.ALIGN_RIGHT
		
		_labels.get_child(0).size_flags_stretch_ratio = 0.5
		_labels.get_child(_labels.get_child_count() - 1).size_flags_stretch_ratio = 0.5


func _on_Slider_value_changed(value: float) -> void:
	if speed_names.size() == 1:
		# When there is only one choice, the slider has a range of [0, 2] for cosmetic reasons and its value is
		# nonsense. We center it back to a value of '1' and suppress any signals -- its value can not change.
		
		if value == 1:
			# do not emit a signal, the slider's value can not change.
			pass
		else:
			# center the slider value back to a value of '1'
			_slider.value = 1
	else:
		emit_signal("speed_changed", speed_names[int(value)])
