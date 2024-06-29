class_name CategorySelector
extends HBoxContainer
## Rolodex-style group of horizontal category buttons which lets the player select a Creature Editor category.
##
## The player can cycle through categories with the mouse, the next tab/prev tab keys (Z, X) or by arrowing up to
## them.

signal category_selected(category)

export (NodePath) var allele_buttons_path: NodePath
export (NodePath) var system_buttons_path: NodePath

onready var allele_buttons: Control = get_node(allele_buttons_path)
onready var system_buttons: Control = get_node(system_buttons_path)

func _ready() -> void:
	for child in get_children():
		if child is CandyButtonCollapsible:
			child.connect("focus_entered", self, "_on_CandyButtonCollapsible_focus_entered", [child])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_tab") and not event.is_action_pressed("prev_tab"):
		set_selected_category_index(_get_selected_category_index() + 1)
	if event.is_action_pressed("prev_tab") and not event.is_action_pressed("next_tab"):
		set_selected_category_index(_get_selected_category_index() - 1)


func get_category_button(idx: int) -> CandyButtonCollapsible:
	return get_child(idx) as CandyButtonCollapsible


func get_selected_category_button() -> CandyButtonCollapsible:
	var result: CandyButtonCollapsible
	for category_button in _get_category_buttons():
		if not category_button.collapsed:
			result = category_button
	return result


func set_selected_category_index(new_selected_index: int) -> void:
	if new_selected_index < 0 or new_selected_index >= _get_category_buttons().size():
		return
	
	_select_category_button(_get_category_buttons()[new_selected_index])
	
	# Maintain focus if a category button is focused. Or, steal focus if no allele buttons were focused. This is an
	# edge case which could occur if no allele buttons are shown, or if the creature's current allele isn't in the
	# panel.
	if get_focus_owner() in _get_category_buttons() \
			or not is_instance_valid(get_focus_owner()) \
			or get_focus_owner().is_queued_for_deletion():
		get_category_button(new_selected_index).grab_focus()


func _get_selected_category_index() -> int:
	return _get_category_buttons().find(get_selected_category_button())


func _get_category_buttons() -> Array:
	return Utils.get_child_members(self, "candy_button_collapsibles")


func _select_category_button(button: CandyButtonCollapsible) -> void:
	if not button.collapsed:
		emit_signal("category_selected", get_children().find(button))
		return

	# if any other buttons are animating, immediately collapse them and cancel any animations
	for child in get_children():
		if child is CandyButtonCollapsible and child.collapsed and child.get_current_animation():
			child.collapse(false)

	# if any other buttons are expanded, animate and collapse them
	for child in get_children():
		if child is CandyButtonCollapsible and not child.collapsed:
			child.collapse(true)

	# animate and uncollapse this button
	button.uncollapse(true)
	
	emit_signal("category_selected", get_children().find(button))


func _on_CandyButtonCollapsible_focus_entered(button: CandyButtonCollapsible) -> void:
	_select_category_button(button)


## When allele buttons are regenerated, we assign our focus neighbors so the player can arrow down to them.
func _on_AlleleButtons_allele_buttons_refreshed() -> void:
	var coordinator := FocusCoordinator.new(Utils.find_focusable_nodes(allele_buttons))
	
	for button in _get_category_buttons():
		var neighbour: Control = null
		if not neighbour:
			neighbour = coordinator.find_nearest_precise(button, Vector2.DOWN)
		if not neighbour:
			neighbour = coordinator.find_nearest_approximate(button, Vector2.DOWN)
		if not neighbour:
			neighbour = system_buttons.settings_button
		button.focus_neighbour_bottom = button.get_path_to(neighbour)
