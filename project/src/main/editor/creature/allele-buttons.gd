extends Control
## Manages allele buttons and other buttons for the Creature Editor.
##
## Manages the buttons which appear and disappear in the middle of the Creature Editor. These buttons usually let the
## player choose things like "poofy hair" but also let the player save or rename the creature.

signal operation_button_pressed(operation_id)

## Emitted after the allele buttons are regenerated, either when the Creature Editor first appears or in response to a
## category selection.
signal allele_buttons_refreshed

## Grid size for the allele buttons. This is the size of a CandyButtonC3 plus some extra padding.
const CELL_SIZE := Vector2(92, 76)

export (PackedScene) var AlleleButtonScene: PackedScene
export (PackedScene) var CreatureColorButtonScene: PackedScene
export (PackedScene) var CreatureNameButtonScene: PackedScene
export (PackedScene) var OperationButtonScene: PackedScene

export (NodePath) var category_selector_path: NodePath
export (NodePath) var creature_saver_path: NodePath
export (NodePath) var overworld_environment_path: NodePath
export (NodePath) var top_system_button_path: NodePath

## Grid coordinates for where allele buttons should be placed on the left side. These are not arranged row by row, but
## rather they wind their way out from the corner to maintain a compact arrangement.
var _grid_coordinates_by_allele_index := [
	Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(2, 0), Vector2(1, 1),
	Vector2(3, 0), Vector2(2, 1), Vector2(0, 2), Vector2(1, 2), Vector2(0, 3),
	Vector2(0, 4), Vector2(1, 3), Vector2(2, 2), Vector2(3, 1), Vector2(1, 4),
	Vector2(2, 3), Vector2(3, 2), Vector2(2, 4), Vector2(3, 4), Vector2(4, 4),
]

## Grid coordinates for where color buttons should be placed on the right side. These are not arranged row by row, but
## rather they wind their way out from the corner to maintain a compact arrangement.
var _grid_coordinates_by_color_index := [
	Vector2( 0, 0), Vector2(-1, 0), Vector2( 0, 1), Vector2(-2, 0), Vector2(-1, 1),
	Vector2(-3, 0), Vector2(-2, 1), Vector2( 0, 2), Vector2(-1, 2), Vector2( 0, 3),
	Vector2( 0, 4), Vector2(-1, 3), Vector2(-2, 2), Vector2(-3, 1), Vector2(-1, 4),
	Vector2(-2, 3), Vector2(-3, 2), Vector2(-2, 4), Vector2(-3, 4), Vector2(-4, 4),
]

## The control which will grab focus after the allele buttons are refreshed.
var _new_focus_target: Control = null

onready var _category_selector: CategorySelector = get_node(category_selector_path)
onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)
onready var _creature_saver: CreatureSaver = get_node(creature_saver_path)
onready var _creature_editor_library := Global.get_creature_editor_library()

func _ready() -> void:
	for creature in [_player(), _player_swap()]:
		# Disable physics processing for both the player and their doppelganger. Creatures are KinematicBody2D
		# instances, and their physics interferes with the swapping process.
		creature.set_physics_process(false)
		
		creature.connect("dna_loaded", self, "_on_Creature_dna_loaded", [creature])


## Deletes and recreates all buttons for the specified category.
func _refresh_allele_buttons(category: int) -> void:
	# calculate whether to grab focus
	var should_grab_focus := false
	if get_focus_owner() in get_children() or get_focus_owner() == null:
		should_grab_focus = true
	_new_focus_target = null
	
	# delete all buttons
	for child in get_children():
		child.queue_free()
	
	# recreate all buttons based on the selected category
	_add_allele_buttons(category)
	_add_color_buttons(category)
	_add_operation_buttons(category)
	_assign_focus_neighbours(category)
	_refresh_color_buttons()
	
	# grab focus
	if should_grab_focus:
		if not _new_focus_target:
			_new_focus_target = find_next_valid_focus()
		if _new_focus_target:
			_new_focus_target.grab_focus()
	
	# notify listeners
	emit_signal("allele_buttons_refreshed")


## Adds all operation buttons for the specified category.
func _add_operation_buttons(category: int) -> void:
	var category_button := _category_selector.get_category_button(category)
	var operations := _creature_editor_library.get_operations_by_category_index(category)
	
	for operation_obj in operations:
		var operation: Operation = operation_obj
		
		# instance button scene
		var button: CandyButtonC3
		if operation.id == "name":
			button = CreatureNameButtonScene.instance()
		else:
			button = OperationButtonScene.instance()
		
		# assign color/shape
		match operation.grid_anchor:
			Operation.GridAnchor.LEFT:
				button.rect_position = _left_position_from_grid_cell(operation.grid_position)
			Operation.GridAnchor.RIGHT:
				button.rect_position = _right_position_from_grid_cell(operation.grid_position)
			_:
				push_warning("Unrecognized operation.grid_anchor: %s" % [operation.grid_anchor])
				button.rect_position = _left_position_from_grid_cell(operation.grid_position)
		button.set_color(category_button.color)
		button.set_shape(category_button.shape)
		
		# initialize signals, properties
		if button is CreatureNameButton:
			_initialize_creature_name_button(button)
		if button is OperationButton:
			_initialize_operation_button(button, operation)
		
		add_child(button)


func _initialize_creature_name_button(button: CreatureNameButton) -> void:
	if not _player():
		return
	
	button.creature = _player()
	button.connect("name_changed", self, "_on_CreatureNameButton_name_changed")


func _initialize_operation_button(button: OperationButton, operation: Operation) -> void:
	button.id = operation.id
	if operation.id in ["export", "import"] and (OS.has_feature("web") or OS.has_feature("mobile")):
		# export/import are not available on web
		button.set_disabled(true)
	if operation.id == "save" and not _creature_saver.has_unsaved_changes():
		button.set_disabled(true)
	if operation.id == "save":
		_new_focus_target = button
	button.connect("pressed", self, "_on_OperationButton_pressed", [button])


## Adds all AlleleButtons for the specified category.
##
## These are buttons which let the player choose things like "Poofy Hair".
func _add_allele_buttons(category: int) -> void:
	if not _player():
		return
	
	var category_button := _category_selector.get_category_button(category)
	
	var allele_combos := _creature_editor_library.get_allele_combos_by_category_index(category)
	var allele_buttons := []
	
	# create the correct number of buttons; position appropriately
	for allele_index in range(allele_combos.size()):
		var allele_button: AlleleButton = AlleleButtonScene.instance()
		allele_button.rect_position = _left_position_from_grid_cell(_grid_coordinates_by_allele_index[allele_index])
		allele_button.set_color(category_button.color)
		allele_button.set_shape(category_button.shape)
		allele_buttons.append(allele_button)
		add_child(allele_button)
	
	# sort allele buttons from top to bottom
	allele_buttons.sort_custom(self, "_compare_by_y_then_x")
	
	# assign an allele to each button
	for i in range(allele_combos.size()):
		var allele_combo: String = allele_combos[i]
		var allele_button: AlleleButton = allele_buttons[i]
		allele_button.set_allele_combo(allele_combo)
	
	# press button for the selected combo
	for allele_button in allele_buttons:
		var allele_combo: String = allele_button.allele_combo
		if _is_allele_combo_assigned(allele_combo):
			allele_button.pressed = true
			_new_focus_target = allele_button
	
	# connect listeners
	for allele_button in allele_buttons:
		allele_button.connect("pressed", self, "_on_AlleleButton_pressed", [allele_button])


## Converts a cell coordinate like (1, 2) to a screen coordinate like (60, 120).
##
## Cell coordinate (1, 2) corresponds to button in the second column from the left, and the third row.
func _left_position_from_grid_cell(grid_cell: Vector2) -> Vector2:
	return CELL_SIZE * grid_cell


## Converts a cell coordinate like (-1, 2) to a screen coordinate like (480, 120)
##
## Cell coordinate (-1, 2) corresponds to button in the second column from the right, and the third row.
func _right_position_from_grid_cell(grid_cell: Vector2) -> Vector2:
	return Vector2(864, 0) + CELL_SIZE * grid_cell


## Returns 'true' if the specified allele combo is assigned to the creature.
##
## Parameters:
## 	'allele_combo': An allele or allele combo such as "hair_0" or "body_1 belly_2"
##
## Returns:
## 	'true' if the specified allele combo is assigned to the creature.
func _is_allele_combo_assigned(allele_combo: String) -> bool:
	var result := true
	for allele_string in allele_combo.split(" "):
		if not _is_allele_assigned(allele_string):
			result = false
			break
	
	return result


## Returns 'true' if the specified allele is assigned to the creature.
##
## Parameters:
## 	'allele_combo': An allele such as "hair_0"
##
## Returns:
## 	'true' if the specified allele is assigned to the creature.
func _is_allele_assigned(allele_string: String) -> bool:
	if not _player():
		return false
	
	var allele_id: String = allele_string.split("_")[0]
	var allele_value: String = allele_string.split("_")[1]
	return _player().dna[allele_id] == allele_value


## Adds all CreatureColorButtons for the specified category.
##
## These are buttons which let the player choose things like hair color.
func _add_color_buttons(category: int) -> void:
	if not _player():
		return
	
	var category_button := _category_selector.get_category_button(category)
	
	var color_properties := _creature_editor_library.get_color_properties_by_category_index(category)
	var color_buttons := []
	
	# create the correct number of buttons; position appropriately
	for color_index in range(color_properties.size()):
		var color_button: CreatureColorButton = CreatureColorButtonScene.instance()
		color_button.rect_position = _right_position_from_grid_cell(_grid_coordinates_by_color_index[color_index])
		color_button.set_shape(category_button.shape)
		color_buttons.append(color_button)
		add_child(color_button)
	
	# sort allele buttons from top to bottom
	color_buttons.sort_custom(self, "_compare_by_y_then_x")
	
	# assign a color to each button
	for i in range(color_properties.size()):
		var color_property: String = color_properties[i]
		var color_button: CreatureColorButton = color_buttons[i]
		var creature_color_html: String = _player().dna[color_property]
		color_button.creature_color = Color(creature_color_html)
		color_button.enabled_if = _creature_editor_library.get_color_property_enabled_if(category, color_property)
		color_button.connect("about_to_show", self, "_on_CreatureColorButton_about_to_show",
				[color_button, color_property])
		color_button.connect("color_changed", self, "_on_CreatureColorButton_color_changed", [color_property])


func _compare_by_y_then_x(a: Control, b: Control) -> bool:
	if b.rect_position.y > a.rect_position.y:
		return true
	if b.rect_position.y < a.rect_position.y:
		return false
	return b.rect_position.x > a.rect_position.x


## Assigns focus neighbours to all children.
##
## This method assigns focus neighbors accordingly:
## 	1. Buttons have their focus_neighbour properties assigned to other buttons in the grid.
## 	2. The highest buttons have their focus_neighbour_top assigned to the category button.
## 	3. The lowest buttons have their focus_neighbour_bottom assigned to the settings button.
func _assign_focus_neighbours(category: int) -> void:
	var focusable_buttons := get_children()
	var button_index := 0
	while button_index < focusable_buttons.size():
		if focusable_buttons[button_index].is_queued_for_deletion():
			focusable_buttons.remove(button_index)
		else:
			button_index += 1
	
	var category_button := _category_selector.get_category_button(category)
	
	FocusCoordinator.new(focusable_buttons).assign_all()
	
	# assign focus_neighbour_top to category button
	for allele_button in focusable_buttons:
		if allele_button.rect_position.y == 0:
			allele_button.focus_neighbour_top = category_button.get_path()
	
	# assign focus_neighbour_bottom to SettingsButton
	for allele_button in focusable_buttons:
		if allele_button.focus_neighbour_bottom == NodePath("."):
			allele_button.focus_neighbour_bottom = allele_button.get_path_to(get_node(top_system_button_path))


func _find_operation_button(id: String) -> OperationButton:
	if not is_inside_tree():
		return null
	var result: OperationButton
	for operation_button in get_tree().get_nodes_in_group("operation_buttons"):
		if operation_button.id == id:
			result = operation_button
			break
	return result


## Refreshes the enabled/disabled state of all CreatureColorButtons based on the creature's properties.
##
## Certain color buttons are disabled if they are not relevant to the creature's appearance. For example, if the
## player has not selected a beak, the beak color button is disabled.
func _refresh_color_buttons() -> void:
	for color_button_obj in Utils.get_child_members(self, "color_buttons"):
		var color_button: CreatureColorButton = color_button_obj
		if not color_button.enabled_if:
			continue
		var color_button_disabled := true
		for allele_string in color_button.enabled_if:
			if _is_allele_assigned(allele_string):
				color_button_disabled = false
				break
		color_button.set_disabled(color_button_disabled)


func _player() -> Creature:
	return _overworld_environment.player


## Returns the player's offscreen doppelganger.
##
## Changing a creature's appearance forces all their textures and shaders to regenerate, making them look strange for
## a moment. We apply these changes to a doppelganger and then swap them in after the changes are applied.
func _player_swap() -> Creature:
	return _overworld_environment.get_creature_by_id(CreatureEditorLibrary.PLAYER_SWAP_ID)


## When the player chooses an allele, we update the UI and update the creature's appearance.
func _on_AlleleButton_pressed(allele_button: AlleleButton) -> void:
	if not _player():
		return
	
	# update the pressed allele buttons
	allele_button.pressed = true
	for other_allele_button in Utils.get_child_members(self, "allele_buttons"):
		if other_allele_button == allele_button:
			continue
		other_allele_button.pressed = false

	# disable any conflicting alleles
	var allele_combo: String = allele_button.allele_combo
	for allele_string in allele_combo.split(" "):
		var allele_id: String = allele_string.split("_")[0]
		var allele_value: String = allele_string.split("_")[1]
		var invalid_allele_value: String
		
		# attempt to reconcile invalid allele values by setting the conflicting allele to '0'. if this doesn't work,
		# we try a few times and then give up.
		for _i in range(5):
			invalid_allele_value = DnaUtils.invalid_allele_value(_player().dna, allele_id, allele_value)
			if not invalid_allele_value:
				break
			_player().suppress_refresh_dna = true
			_player().dna[invalid_allele_value] = "0"
			_player().suppress_refresh_dna = false
	
	# update the creature's appearance
	for allele_string in allele_button.allele_combo.split(" "):
		var allele_id: String = allele_string.split("_")[0]
		var allele_value: String = allele_string.split("_")[1]
		_player().suppress_refresh_dna = true
		_player().dna[allele_id] = allele_value
		_player().suppress_refresh_dna = false
	_player_swap().dna = _player().dna
	
	# refresh the enabled/disabled state of all CreatureColorButtons
	_refresh_color_buttons()


## When the doppelganger's dna is fully loaded, we swap them in for the main creature.
##
## Changing a creature's appearance forces all their textures and shaders to regenerate, making them look strange for
## a moment. We apply these changes to a doppelganger and then swap them in after the changes are applied.
func _on_Creature_dna_loaded(creature: Creature) -> void:
	if creature != _player_swap():
		## we only run these steps when the doppelganger is loaded; not when the main creature is loaded
		return
	
	var player := _player()
	var player_position := _player().position
	var player_swap := _player_swap()
	var player_swap_position := _player_swap().position
	
	# copy properties from player to their doppelganger
	player_swap.chat_theme = player.chat_theme
	player_swap.creature_name = player.creature_name
	player_swap.creature_short_name = player.creature_short_name
	player_swap.creature_visuals.rescale(0.60 if player_swap.creature_visuals.dna.get("body") == "2" else 1.00)
	player_swap.fatness = player.fatness
	player_swap.min_fatness = player.min_fatness
	player_swap.visual_fatness = player.visual_fatness
	
	# replace player with doppelganger
	player_swap.position = player_position
	player_swap.suppress_refresh_creature_id = true
	player_swap.creature_id = CreatureLibrary.PLAYER_ID
	player_swap.suppress_refresh_creature_id = false

	# replace doppelganger with player
	player.position = player_swap_position
	player.suppress_refresh_creature_id = true
	player.creature_id = CreatureEditorLibrary.PLAYER_SWAP_ID
	player.suppress_refresh_creature_id = false


## When the player uses a CreatureColorButton, we update the creature's appearance
func _on_CreatureColorButton_color_changed(color: Color, color_property: String) -> void:
	if not _player():
		return
	
	_player().suppress_refresh_dna = true
	_player().dna[color_property] = color.to_html(false).to_lower()
	_player().suppress_refresh_dna = false
	_player().chat_theme = CreatureLoader.chat_theme(_player().dna) # generate a new chat theme
	_player_swap().dna = _player().dna
	_player_swap().chat_theme = _player().chat_theme


func _on_CreatureNameButton_name_changed(new_name: String) -> void:
	if not _player():
		return
	
	_player().rename(new_name)
	var save_button := _find_operation_button("save")
	if save_button:
		save_button.set_disabled(not _creature_saver.has_unsaved_changes())


func _on_CategorySelector_category_selected(category: int) -> void:
	_refresh_allele_buttons(category)


func _on_OperationButton_pressed(operation_button: OperationButton) -> void:
	emit_signal("operation_button_pressed", operation_button.id)
	if operation_button.id == "save":
		operation_button.set_disabled(true)


## Before showing the CreatureColorButton popup, populate the list of color presets.
##
## Some of these presets such as for 'line_rgb' change based on the creature's body color.
func _on_CreatureColorButton_about_to_show(color_button: CreatureColorButton, color_property: String) -> void:
	if not _player():
		return
	
	color_button.color_presets = _creature_editor_library.get_color_presets(_player().dna, color_property)
