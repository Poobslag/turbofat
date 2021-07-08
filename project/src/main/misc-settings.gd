class_name MiscSettings
"""
Manages miscellaneous settings such as language.
"""

# Whether cutscenes should play by default.
var cutscene_force: int = CurrentLevel.CutsceneForce.NONE

"""
Resets the miscellaneous settings to their default values.
"""
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"locale": TranslationServer.get_locale(),
		"cutscene_force": cutscene_force,
	}


func from_json_dict(json: Dictionary) -> void:
	cutscene_force = json.get("cutscene_force", CurrentLevel.CutsceneForce.NONE)
	
	if json.has("locale"):
		TranslationServer.set_locale(json.get("locale"))
	else:
		# resetting the locale sets it to the OS locale unless the 'locale/test' property is set.
		var default_locale: String
		if ProjectSettings.get_setting("locale/test"):
			default_locale = ProjectSettings.get_setting("locale/test")
		else:
			default_locale = OS.get_locale()
		TranslationServer.set_locale(default_locale)
