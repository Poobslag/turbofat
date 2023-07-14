extends Node
## Demo which shows off the popup window which is shown if there is a problem loading the save data
##
## Keys:
## 	[B]: Changes which backup was loaded (hourly, daily...)
## 	[L]: Changes the locale (english, spanish...)
## 	[P]: Shows/hides the popup

onready var _control := $BadSaveDataControl

func _ready() -> void:
	PlayerSave.corrupt_filenames = ["user://example.save"]


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_B:
			var new_loaded_backup := PlayerSave.rolling_backups.loaded_backup + 1
			if new_loaded_backup >= RollingBackups.Backup.size():
				new_loaded_backup = -1
			PlayerSave.rolling_backups.loaded_backup = new_loaded_backup
			_control.popup()
		KEY_L:
			var old_locale := TranslationServer.get_locale()
			var locales := TranslationServer.get_loaded_locales()
			var new_locale_index := (locales.find(old_locale) + 1) % locales.size()
			var new_locale: String = locales[new_locale_index]
			SystemData.misc_settings.set_locale(new_locale)
		KEY_P:
			if _control.visible:
				_control.hide()
			else:
				_control.popup()
