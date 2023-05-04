class_name SaveSlotControl
extends HBoxContainer
## UI component for a changing the current save slot or deleting save slots

signal delete_pressed

@onready var _option_button := $HBoxContainer/OptionButton
@onready var _delete_button := $HBoxContainer/Delete

func _ready() -> void:
	SystemSave.save_slot_deleted.connect(_on_SystemSave_save_slot_deleted)
	
	_refresh_save_slots()


func get_selected_save_slot() -> int:
	return _option_button.get_selected_id()


func revert_save_slot() -> void:
	_option_button.select(SystemData.misc_settings.save_slot)


func _refresh_save_slots() -> void:
	_option_button.clear()
	for save_slot_index in MiscSettings.SaveSlot.values():
		var save_slot_name: String = SystemSave.get_save_slot_name(save_slot_index)
		_option_button.add_item(tr(save_slot_name), save_slot_index)
	_option_button.select(SystemData.misc_settings.save_slot)


func _on_Delete_pressed() -> void:
	emit_signal("delete_pressed")


func _on_SystemSave_save_slot_deleted() -> void:
	_refresh_save_slots()
