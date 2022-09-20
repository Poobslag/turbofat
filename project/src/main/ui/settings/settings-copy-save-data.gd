extends HBoxContainer
## UI component for a copying the selected save data to the clipboard

export var save_slot_control_path: NodePath

## UI component for a changing the current save slot or deleting save slots
onready var _save_slot_control: SaveSlotControl = get_node(save_slot_control_path)

onready var _copied_label: Label = $HBoxContainer/Copied
var _copied_tween: SceneTreeTween

func _ready() -> void:
	# hide the 'Copied!' message until we need to display it
	_copied_label.modulate = Color.transparent


func _on_Button_pressed() -> void:
	# copy the contents of the selected save file to the clipboard
	var save_filename: String = SystemSave.FILENAMES_BY_SAVE_SLOT[_save_slot_control.get_selected_save_slot()]
	var save_text := FileUtils.get_file_as_text(save_filename)
	OS.set_clipboard(save_text)
	
	# display the 'Copied!' message, and gradually fade it out
	_copied_label.modulate = Color.white
	_copied_tween = Utils.recreate_tween(self, _copied_tween)
	_copied_tween.tween_property(_copied_label, "modulate", Color.transparent, 3.0)
