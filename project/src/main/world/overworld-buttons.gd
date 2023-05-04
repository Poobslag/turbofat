extends Control
## Manages the buttons for the overworld.

func _ready() -> void:
	var overworld_ui: OverworldUi = Global.get_overworld_ui()
	overworld_ui.chat_started.connect(_on_OverworldUi_chat_started)
	overworld_ui.chat_ended.connect(_on_OverworldUi_chat_ended)
	for button in [$Northeast/SettingsButton]:
		button.resized.connect(_on_Button_resized.bind(button))
	await get_tree().idle_frame
	_resize_container($Northeast)


## Resizes a button container based on the player's touch settings.
func _resize_container(container: Control) -> void:
	if container.custom_minimum_size.y != 96 * SystemData.touch_settings.size:
		container.custom_minimum_size.y = 96 * SystemData.touch_settings.size
	container.size.y = 0


func _on_Menu_shown() -> void:
	hide()


func _on_Menu_hidden() -> void:
	show()


func _on_OverworldUi_chat_started() -> void:
	hide()


func _on_OverworldUi_chat_ended() -> void:
	show()


func _on_Button_resized(button: Button) -> void:
	_resize_container(button.get_parent())
