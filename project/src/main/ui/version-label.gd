extends Label
## Displays a version label like '0.3100'.

func _ready() -> void:
	text = ProjectSettings.get_setting("application/config/version")
