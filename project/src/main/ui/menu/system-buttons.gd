extends VBoxContainer
## Navigational buttons which occur on most menu screens.

signal settings_pressed

signal credits_pressed

signal quit_pressed

const UI_CANCEL_SHORTCUT := preload("res://src/main/ui/UiCancelShortcut.tres")

## If true, the `ui_cancel` action will activate the quit button. This should be unset in contexts where the 'quit'
## button does something destructive such as quitting the game or abandoning an editor.
export (bool) var quit_on_cancel: bool = true setget set_quit_on_cancel

func _ready() -> void:
	refresh()


func set_quit_on_cancel(new_quit_on_cancel: bool) -> void:
	quit_on_cancel = new_quit_on_cancel
	refresh()


func refresh() -> void:
	if not is_inside_tree():
		return

	if quit_on_cancel:
		$Quit.shortcut = UI_CANCEL_SHORTCUT
		$Settings/ShortcutHelper.overridden_action = "ui_menu"
	else:
		$Quit.shortcut = null
		$Settings/ShortcutHelper.overridden_action = ""


func _on_Quit_pressed() -> void:
	emit_signal("quit_pressed")
	SceneTransition.pop_trail({SceneTransition.FLAG_TYPE: SceneTransition.TYPE_NONE})


func _on_Settings_pressed() -> void:
	emit_signal("settings_pressed")


func _on_Credits_pressed() -> void:
	emit_signal("credits_pressed")
	SceneTransition.push_trail(Global.SCENE_CREDITS)
