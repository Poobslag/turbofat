extends Control
"""
UI control for rerolling and controlling the mutagen level.

A higher mutagen level means more alleles will be mutated.
"""

# default mutagen level when launching the scene
const DEFAULT_MUTAGEN := 1.00

# A higher mutagen level means more alleles will be mutated.
# Virtual property; value is only exposed through getters/setters
var mutagen: float setget set_mutagen, get_mutagen

func _ready() -> void:
	$HSlider.value = DEFAULT_MUTAGEN
	_refresh_percent_label()


func get_mutagen() -> float:
	return $HSlider.value


func set_mutagen(new_mutagen: float) -> void:
	$HSlider.value = new_mutagen


func _refresh_percent_label() -> void:
	$Button.text = "Reroll (%d%%)" % int($HSlider.value * 100)


func _on_HSlider_value_changed(value: float) -> void:
	_refresh_percent_label()
