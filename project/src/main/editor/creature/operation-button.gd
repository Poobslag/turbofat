class_name OperationButton
extends CandyButtonC3
## Button which performs a unique function in the creature editor, such as saving.

## key: (String) an operation ID
## value: (Resource) icon for the specified operation
const OPERATION_ICONS_BY_ID := {
	"save": preload("res://assets/main/editor/creature/icon-save.png"),
	"export": preload("res://assets/main/editor/creature/icon-export.png"),
	"import": preload("res://assets/main/editor/creature/icon-import.png"),
	"fatness_down": preload("res://assets/main/editor/creature/icon-fatness-down.png"),
	"fatness_up": preload("res://assets/main/editor/creature/icon-fatness-up.png"),
}

var id: String setget set_id

func set_id(new_id: String) -> void:
	id = new_id
	
	if OPERATION_ICONS_BY_ID.has(id):
		set_icon(OPERATION_ICONS_BY_ID[id])
	else:
		push_warning("operation icon not found for id: '%s'" % [id])
		set_icon(null)
