extends CanvasLayer
## Level select menu which appears when the player clicks the 'phone' button.

signal show
signal hide

func _ready() -> void:
	SystemData.touch_settings.connect("settings_changed", self, "_on_TouchSettings_settings_changed")
	for button in [$Buttons/Northeast/BackButton, $Buttons/Northeast/Spacer]:
		button.connect("resized", self, "_on_Button_resized", [button])
	yield(get_tree(), "idle_frame")
	_resize_container($Buttons/Northeast)


## Shows the menu and pauses the scene tree.
func show() -> void:
	$Bg.show()
	$LevelSelect.show()
	$Buttons.show()
	emit_signal("show")


## Hides the menu and unpauses the scene tree.
func hide() -> void:
	$Bg.hide()
	$LevelSelect.hide()
	$Buttons.hide()
	emit_signal("hide")


## Resizes a button container based on the player's touch settings.
func _resize_container(container: Control) -> void:
	if container.rect_min_size.y != 96 * SystemData.touch_settings.size:
		container.rect_min_size.y = 96 * SystemData.touch_settings.size
	container.rect_size.y = 0


func _on_BackButton_pressed() -> void:
	hide()


func _on_Button_resized(button: Button) -> void:
	_resize_container(button.get_parent())
