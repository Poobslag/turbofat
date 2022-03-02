extends Control
## Manages the buttons for the overworld.

func _ready() -> void:
	var overworld_ui: OverworldUi = Global.get_overworld_ui()
	overworld_ui.connect("chat_started", self, "_on_OverworldUi_chat_started")
	overworld_ui.connect("chat_ended", self, "_on_OverworldUi_chat_ended")
	for button in [$Northeast/SettingsButton, $Northeast/PhoneButton, $Southeast/TalkButton]:
		button.connect("resized", self, "_on_Button_resized", [button])
	yield(get_tree(), "idle_frame")
	for container in [$Northeast, $Southeast]:
		_resize_container(container)


## Resizes a button container based on the player's touch settings.
func _resize_container(container: Control) -> void:
	if container.rect_min_size.y != 96 * SystemData.touch_settings.size:
		container.rect_min_size.y = 96 * SystemData.touch_settings.size
	container.rect_size.y = 0
	if container == $Southeast:
		container.rect_position.y = 600 - 60 - container.rect_size.y


func _on_Menu_show() -> void:
	hide()


func _on_Menu_hide() -> void:
	show()


func _on_OverworldUi_chat_started() -> void:
	hide()


func _on_OverworldUi_chat_ended() -> void:
	show()


func _on_Button_resized(button: Button) -> void:
	_resize_container(button.get_parent())
