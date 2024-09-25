extends Node
## Demonstrates the 'squeak theme', a simpler compact UI used in the settings menu.
##
## Keys:
## 	[Q]: Show confirmation dialog
## 	[W]: Show file dialog

onready var _panel := $Panel

func _ready() -> void:
	_initialize_option_button()
	_initialize_tab_container()
	_initialize_tree()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q:
			$Panel/ConfirmationDialog.popup_centered()
		KEY_W:
			$Panel/FileDialog.popup_centered()


func _initialize_option_button() -> void:
	var _option_button: OptionButton = $Panel/OptionButton
	_option_button.add_item("OptionButton")
	_option_button.add_item("PoptionButton")
	_option_button.add_item("QuoptionButton")
	_option_button.add_separator()
	_option_button.add_item("RoptionButton")
	_option_button.add_item("SoptionButton")
	_option_button.add_separator()
	_option_button.add_item("ToptionButton")


func _initialize_tab_container() -> void:
	var _tab_container: TabContainer = $Panel/TabContainer
	_tab_container.set_tab_disabled(2, true)


func _initialize_tree() -> void:
	var tree: Tree = $Panel/Tree
	var root := tree.create_item()
	root.set_text(0, "Tree")
	var child1 := tree.create_item(root)
	child1.set_text(0, "Item")
	child1.set_editable(0, false)
	var child2 := tree.create_item(root)
	child2.set_text(0, "Editable Item")
	child2.set_editable(0, true)
	var child3 := tree.create_item(root)
	child3.set_text(0, "Subtree")
	child3.set_editable(0, false)
	var child4 := tree.create_item(child3)
	child4.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	child4.set_text(0, "Check Item")
	child4.set_editable(0, true)
	var child5 := tree.create_item(child3)
	child5.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	child5.set_range(0, 10.4)
	child5.set_range_config(0, 0, 20, 0.1)
	child5.set_editable(0, true)
	var child6 := tree.create_item(child3)
	child6.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	child6.set_text(0, "Has,Many,Options")
	child6.set_editable(0, true)
