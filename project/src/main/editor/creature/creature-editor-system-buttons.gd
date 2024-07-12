extends VBoxContainer
## Navigational buttons for the creature editor.

export (NodePath) var allele_buttons_path: NodePath
export (NodePath) var category_selector_path: NodePath

onready var allele_buttons: Control = get_node(allele_buttons_path)
onready var category_selector: Control = get_node(category_selector_path)

onready var settings_button := $Settings
onready var quit_button := $Quit

func _assign_focus_neighbour(control: Control, direction: Vector2) -> void:
	var coordinator := FocusCoordinator.new(Utils.find_focusable_nodes(allele_buttons))
	
	var neighbour: Control = null
	if not neighbour:
		neighbour = coordinator.find_nearest_precise(control, direction)
	if not neighbour:
		neighbour = coordinator.find_nearest_approximate(control, direction)
	if not neighbour:
		neighbour = category_selector.get_selected_category_button()
	if not neighbour:
		neighbour = control
	
	var focus_neighbour_property: String = FocusCoordinator.FOCUS_NEIGHBOUR_PROPERTY_BY_DIRECTION[direction]
	control.set(focus_neighbour_property, control.get_path_to(neighbour))


## When allele buttons are regenerated, we assign our focus neighbors so the player can arrow up to them.
func _on_AlleleButtons_allele_buttons_refreshed() -> void:
	_assign_focus_neighbour(settings_button, Vector2.UP)
	_assign_focus_neighbour(settings_button, Vector2.LEFT)
	_assign_focus_neighbour(quit_button, Vector2.LEFT)
