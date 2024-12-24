class_name MutateUi
extends Panel
## Provides buttons/sliders for the player to control how the creatures mutate.

## Returns a list of alleles which are neither locked nor unlocked.
##
## These alleles might change when the creature mutates, it's up to chance.
func get_flexible_alleles() -> Array:
	if not is_inside_tree():
		return []
	var alleles := []
	for button_obj in get_tree().get_nodes_in_group("lock_allele_buttons"):
		var button: LockAlleleButton = button_obj
		if not (button.is_locked() or button.is_unlocked()):
			alleles.append(button.allele)
	return alleles


## Returns a list of alleles which are unlocked.
##
## These alleles always change when the creature mutates.
func get_unlocked_alleles() -> Array:
	if not is_inside_tree():
		return []
	var alleles := []
	for button_obj in get_tree().get_nodes_in_group("lock_allele_buttons"):
		var button: LockAlleleButton = button_obj
		if button.is_unlocked():
			alleles.append(button.allele)
	return alleles


## Returns a list of alleles which are locked.
##
## These alleles never change when the creature mutates.
func get_locked_alleles() -> Array:
	if not is_inside_tree():
		return []
	var alleles := []
	for button_obj in get_tree().get_nodes_in_group("lock_allele_buttons"):
		var button: LockAlleleButton = button_obj
		if button.is_locked():
			alleles.append(button.allele)
	return alleles
