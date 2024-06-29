extends HBoxContainer
## UI control for editing a creature's name.

export (NodePath) var creature_editor_path: NodePath

onready var _creature_editor: CreatureEditorOld = get_node(creature_editor_path)

func _ready() -> void:
	_creature_editor.connect("center_creature_changed", self, "_on_CreatureEditor_center_creature_changed")
	$Edit/Name.max_length = NameUtils.MAX_CREATURE_NAME_LENGTH
	$Edit/ShortName.max_length = NameUtils.MAX_CREATURE_SHORT_NAME_LENGTH


## Steals the focus from another control and becomes the focused control.
##
## This control itself doesn't have focus, so we delegate to a child control.
func grab_focus() -> void:
	$Edit/Name.grab_focus()


## Update the creature's name and short name.
func _finish_name_edit(text: String) -> void:
	var new_name: String = NameUtils.sanitize_name(text)
	_creature_editor.center_creature.rename(new_name)
	_creature_editor.center_creature.creature_id \
		= NameUtils.short_name_to_id(_creature_editor.center_creature.creature_short_name)
	_refresh_name_ui()


## Update the creature's short name.
func _finish_short_name_edit(text: String) -> void:
	var new_name: String = NameUtils.sanitize_short_name(text)
	var creature: Creature = _creature_editor.center_creature
	creature.creature_short_name = new_name
	creature.creature_id = NameUtils.short_name_to_id(creature.creature_short_name)
	_refresh_name_ui()


## Update the name text boxes with the creature's name.
##
## The short name is only shown if it differs from the creature's name.
func _refresh_name_ui() -> void:
	var creature := _creature_editor.center_creature
	if $Edit/Name.text != creature.creature_name:
		$Edit/Name.text = creature.creature_name
	if $Edit/ShortName.text != creature.creature_short_name:
		$Edit/ShortName.text = creature.creature_short_name
	$Edit/ShortName.visible = creature.creature_short_name != creature.creature_name


## If the player's typed a valid name, we update the name immediately.
##
## We don't update if the player's typed an invalid name (e.g 'Tom ') because otherwise it's aggravating erasing the
## name or appending punctuation/spaces, as the text box is constantly updated.
func _on_Edit_text_changed(text: String) -> void:
	if text == NameUtils.sanitize_name(text):
		_finish_name_edit(text)


func _on_Edit_text_entered(text: String) -> void:
	_finish_name_edit(text)


func _on_Edit_focus_exited() -> void:
	_finish_name_edit($Edit/Name.text)


## If the player's typed a valid short name, we update the name immediately.
##
## We don't update if the player's typed an invalid name (e.g 'Tom ') because otherwise it's aggravating erasing the
## name or appending punctuation/spaces, as the text box is constantly updated.
func _on_ShortName_text_changed(text: String) -> void:
	if text == NameUtils.sanitize_short_name(text):
		_finish_short_name_edit(text)


func _on_ShortName_text_entered(text: String) -> void:
	_finish_short_name_edit(text)


func _on_ShortName_focus_exited() -> void:
	_finish_short_name_edit($Edit/ShortName.text)


func _on_Dna_pressed() -> void:
	_creature_editor.tweak_all_creatures("name")


func _on_CreatureEditor_center_creature_changed() -> void:
	_refresh_name_ui()
