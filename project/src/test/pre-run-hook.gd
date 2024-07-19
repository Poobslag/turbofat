extends GutHookScript
## Performs initialization steps for Gut tests.

const TEMP_FILENAME := "test-harbor-unobtainable.json"
const TEMP_LEGACY_FILENAME := "test-moaning-corn.json"

func run() -> void:
	# Prevent the player's settings from triggering fullscreen mode or vsync.
	SystemData.disallow_graphics_customization()
	
	# Prevent the tests from deleting the user's save data.
	SystemSave.data_filename = "user://%s" % TEMP_FILENAME
	SystemSave.legacy_filename = "user://%s" % TEMP_LEGACY_FILENAME
	PlayerSave.data_filename = "user://%s" % TEMP_FILENAME
	SystemSave.ignore_save_slot_filename = true
