extends Control
## Shows popup dialogs for the settings menu.

## emitted when the player is prompted to change their save slot and answers 'yes'
signal change_save_confirmed

## emitted when the player is prompted to change their save slot and answers 'no' or closes the window
signal change_save_cancelled

## emitted when the player is prompted to delete a save slot and answers 'yes'
signal delete_confirmed

## emitted when the player is prompted to delete a save slot and answers 'no' or closes the window
signal delete_cancelled

signal give_up_confirmed

signal give_up_cancelled

## emitted when a dialog becomes visible/invisible
##
## Parameters:
## 	'value': 'true' if any dialog is visible, 'false' if all dialogs are invisible
signal dialog_visibility_changed(value)

export var save_slot_control_path: NodePath

## 'Are you sure you want to change save slots?' confirmation dialog
onready var _change_save_confirmation := $ChangeSaveConfirmation

## 'Delete save data?' confirmation dialog
onready var _delete_confirmation_1 := $DeleteConfirmation1

## 'Are you sure?' confirmation dialog
onready var _delete_confirmation_2 := $DeleteConfirmation2

onready var _give_up_confirmation := $GiveUpConfirmation

onready var _backdrop: ColorRect = $Backdrop

## UI component for a changing the current save slot or deleting save slots
onready var _save_slot_control: SaveSlotControl = get_node(save_slot_control_path)

func _ready() -> void:
	_change_save_confirmation.get_ok().text = tr("Yes")
	_change_save_confirmation.get_cancel().text = tr("No")
	_change_save_confirmation.connect("confirmed", self, "_on_ChangeSaveConfirmation_confirmed")
	_change_save_confirmation.get_cancel().connect("pressed", self, "_on_ChangeSaveConfirmation_cancelled")
	_change_save_confirmation.get_close_button().connect("pressed", self, "_on_ChangeSaveConfirmation_cancelled")
	_assign_dialog_cancel_shortcut(_change_save_confirmation)
	
	_delete_confirmation_1.get_ok().text = tr("Yes")
	_delete_confirmation_1.get_cancel().text = tr("No")
	_delete_confirmation_1.connect("confirmed", self, "_on_DeleteConfirmation1_confirmed")
	_delete_confirmation_1.get_cancel().connect("pressed", self, "_on_DeleteConfirmation_cancelled")
	_delete_confirmation_1.get_close_button().connect("pressed", self, "_on_DeleteConfirmation_cancelled")
	_assign_dialog_cancel_shortcut(_delete_confirmation_1)
	
	_delete_confirmation_2.get_ok().text = tr("Yes")
	_delete_confirmation_2.get_cancel().text = tr("No")
	_delete_confirmation_2.connect("confirmed", self, "_on_DeleteConfirmation2_confirmed")
	_delete_confirmation_2.get_cancel().connect("pressed", self, "_on_DeleteConfirmation_cancelled")
	_delete_confirmation_2.get_close_button().connect("pressed", self, "_on_DeleteConfirmation_cancelled")
	_assign_dialog_cancel_shortcut(_delete_confirmation_2)
	
	_give_up_confirmation.get_ok().text = tr("Yes")
	_give_up_confirmation.get_cancel().text = tr("No")
	_give_up_confirmation.connect("confirmed", self, "_on_GiveUpConfirmation_confirmed")
	_give_up_confirmation.get_cancel().connect("pressed", self, "_on_GiveUpConfirmation_cancelled")
	_give_up_confirmation.get_close_button().connect("pressed", self, "_on_GiveUpConfirmation_cancelled")
	_assign_dialog_cancel_shortcut(_give_up_confirmation)


## Displays a dialog prompting the player if they want to change their save slot
func confirm_new_save_slot() -> void:
	_change_save_confirmation.popup_centered()


func show_give_up_confirmation() -> void:
	_give_up_confirmation.popup_centered()


## Expands a simple delete confirmation message into a more detailed message.
##
## Parameters:
## 	'message': A simple message like 'Are you sure?'
##
## Returns:
## 	A more detailed message like 'Are you sure? B: Gordo (13.5 hours)'
func _delete_confirmation_dialog_text(message: String) -> String:
	var selected_save_slot := _save_slot_control.get_selected_save_slot()
	var playtime_in_seconds: float = SystemSave.get_save_slot_playtime(selected_save_slot)
	var playtime_in_hours := clamp(playtime_in_seconds / 3600, 0, 9999.9)
	var playtime_message := tr("%.1f hours") % [playtime_in_hours]
	var save_slot_name: String = SystemSave.get_save_slot_name(selected_save_slot)
	return "%s\n%s (%s)" % [message, save_slot_name, playtime_message]


## Configures a dialog to be dismissed by the 'ui_cancel' action.
func _assign_dialog_cancel_shortcut(dialog: WindowDialog) -> void:
	var new_shortcut := ShortCut.new()
	var new_input_event_action := InputEventAction.new()
	new_input_event_action.action = "ui_cancel"
	new_shortcut.shortcut = new_input_event_action
	dialog.get_close_button().shortcut = new_shortcut


## Displays a dialog prompting the player if they want to delete a save
func _on_SaveSlot_delete_pressed() -> void:
	_delete_confirmation_1.custom_text = _delete_confirmation_dialog_text(tr("Delete save data?"))
	_delete_confirmation_1.popup_centered()
	_delete_confirmation_1.get_cancel().grab_focus()


## Displays a dialog prompting the player if they're sure want to delete a save
func _on_DeleteConfirmation1_confirmed() -> void:
	_delete_confirmation_2.custom_text = _delete_confirmation_dialog_text(tr("Are you sure?"))
	_delete_confirmation_2.popup_centered()
	_delete_confirmation_2.get_cancel().grab_focus()


func _on_DeleteConfirmation2_confirmed() -> void:
	emit_signal("delete_confirmed")


func _on_DeleteConfirmation_cancelled() -> void:
	emit_signal("delete_cancelled")


func _on_ChangeSaveConfirmation_confirmed() -> void:
	emit_signal("change_save_confirmed")


func _on_ChangeSaveConfirmation_cancelled() -> void:
	emit_signal("change_save_cancelled")


func _on_Backdrop_visibility_changed() -> void:
	emit_signal("dialog_visibility_changed", _backdrop.visible)


func _on_GiveUpConfirmation_confirmed() -> void:
	emit_signal("give_up_confirmed")


func _on_GiveUpConfirmation_cancelled() -> void:
	emit_signal("give_up_cancelled")
