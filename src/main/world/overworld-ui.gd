extends Control
"""
UI elements for the overworld.

This includes chats, buttons and debug messages.
"""

var spira: Spira setget set_spira

var _show_version := true setget set_show_version, is_show_version

func _ready() -> void:
	_update_visible()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_menu"):
		$SettingsMenu.show()
		get_tree().set_input_as_handled()


func set_show_version(show_version: bool) -> void:
	_show_version = show_version
	_update_visible()


func is_show_version() -> bool:
	return _show_version


func set_spira(new_spira: Spira) -> void:
	spira = new_spira
	emit_signal("spira_changed", spira)


"""
Updates the different UI components to be visible/invisible based on the UI's current state.
"""
func _update_visible() -> void:
	$Labels/SoutheastLabels/VersionLabel.visible = _show_version


func _on_SettingsMenu_quit_pressed() -> void:
	ChattableManager3D.clear()
	Breadcrumb.pop_trail()
