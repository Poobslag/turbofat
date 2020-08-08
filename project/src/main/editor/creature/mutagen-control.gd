extends Control
"""
UI control for adjusting the mutagen level.

A higher mutagen level means more alleles will be mutated.
"""

# emitted when the slider value changes
signal mutagen_changed(value)

# default mutagen level when launching the scene
const DEFAULT_MUTAGEN := 1.00

func _ready() -> void:
	$HBoxContainer/HSlider.value = DEFAULT_MUTAGEN
	_refresh_percent_label()


func _refresh_percent_label() -> void:
	$HBoxContainer/Percent.text = "%d%%" % int($HBoxContainer/HSlider.value * 100)


func _on_HSlider_value_changed(value: float) -> void:
	_refresh_percent_label()
	emit_signal("mutagen_changed", value)
