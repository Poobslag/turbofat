extends Label
## Shows a warning if the player changes settings which can't be changed immediately.

func _ready() -> void:
	visible = false
	SystemData.graphics_settings.creature_detail_changed.connect(
			_on_GraphicsSettings_creature_detail_changed)


func _on_GraphicsSettings_creature_detail_changed(_value: GraphicsSettings.CreatureDetail) -> void:
	visible = true
