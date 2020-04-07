extends Label

func _ready() -> void:
	var preset = ConfigFile.new()
	preset.load("res://export_presets.cfg")
	text = preset.get_value("preset.0.options", "application/file_version")
