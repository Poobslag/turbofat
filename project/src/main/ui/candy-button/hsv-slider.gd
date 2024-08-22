tool
class_name HsvSlider
extends HBoxContainer
## A slider within the candy color picker which adjusts either the hue, saturation or value

signal value_changed(value)

## Text shown to the left of the slider, such as 'H' for hue
export (String) var text: String setget set_text

export (int, 0, 255) var value: int setget set_value

onready var _text_label := $TextLabel
onready var _slider := $HSlider
onready var _value_label := $ValueLabel

func _ready() -> void:
	_refresh()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_text_label = $TextLabel
	_slider = $HSlider
	_value_label = $ValueLabel


func set_text(new_text: String) -> void:
	text = new_text
	_refresh()


func set_value(new_value: int) -> void:
	value = new_value
	_refresh()


## Updates the labels and slider based on our properties.
func _refresh() -> void:
	if not is_inside_tree():
		return
	
	_text_label.text = text
	_slider.value = value
	_value_label.text = str(value)


func _on_HSlider_value_changed(new_value: float) -> void:
	if value == new_value:
		return
	
	value = int(new_value)
	_refresh()
	emit_signal("value_changed", value)
