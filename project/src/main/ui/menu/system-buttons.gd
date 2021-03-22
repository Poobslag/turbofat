extends VBoxContainer
"""
Navigational buttons which occur on most menu screens.
"""

# If true, the `ui_cancel` action will activate the quit button. This should be unset in contexts where the 'quit'
# button does something destructive such as quitting the game or abandoning an editor.
export (bool) var quit_on_cancel: bool = true setget set_quit_on_cancel

onready var _ui_cancel_shortcut := preload("res://src/main/ui/UiCancelShortcut.tres")

signal settings_pressed

signal quit_pressed

func _ready() -> void:
	refresh()


func set_quit_on_cancel(new_quit_on_cancel: bool) -> void:
	quit_on_cancel = new_quit_on_cancel
	refresh()


func refresh() -> void:
	if not is_inside_tree():
		return

	if quit_on_cancel:
		$Quit.shortcut = _ui_cancel_shortcut
		$Settings/ShortcutHelper.overridden_action = "ui_menu"
	else:
		$Quit.shortcut = null
		$Settings/ShortcutHelper.overridden_action = ""


func _on_Quit_pressed() -> void:
	emit_signal("quit_pressed")
	SceneTransition.pop_trail(true)


func _on_Settings_pressed() -> void:
	emit_signal("settings_pressed")
