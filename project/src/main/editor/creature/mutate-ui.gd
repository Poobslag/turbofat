class_name MutateUi
extends Panel
"""
Provides buttons/sliders for the player to control how the creatures mutate.
"""

# A higher mutagen level means more alleles will be mutated.
# Virtual property; value is only exposed through getters/setters
var mutagen: float setget set_mutagen, get_mutagen

onready var _mutagen_slider := $ScrollContainer/MarginContainer/VBoxContainer/Mutagen/HBoxContainer/HSlider

func get_mutagen() -> float:
	return _mutagen_slider.value


func set_mutagen(new_mutagen: float) -> void:
	_mutagen_slider.value = new_mutagen


"""
Returns a list of alleles which are neither locked nor unlocked.

These alleles might change when the creature mutates, it's up to chance.
"""
func get_flexible_alleles() -> Array:
	var alleles := []
	for button_obj in get_tree().get_nodes_in_group("lock_allele_buttons"):
		var button: LockAlleleButton = button_obj
		if not (button.is_locked() or button.is_unlocked()):
			alleles.append(button.allele)
	return alleles


"""
Returns a list of alleles which are unlocked.

These alleles always change when the creature mutates.
"""
func get_unlocked_alleles() -> Array:
	var alleles := []
	for button_obj in get_tree().get_nodes_in_group("lock_allele_buttons"):
		var button: LockAlleleButton = button_obj
		if button.is_unlocked():
			alleles.append(button.allele)
	return alleles


"""
Returns a list of alleles which are locked.

These alleles never change when the creature mutates.
"""
func get_locked_alleles() -> Array:
	var alleles := []
	for button_obj in get_tree().get_nodes_in_group("lock_allele_buttons"):
		var button: LockAlleleButton = button_obj
		if button.is_locked():
			alleles.append(button.allele)
	return alleles
