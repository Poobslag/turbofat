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
	
	# disable population of rank data; it takes about 300 ms which is too long for unit tests. it also invalidates old
	# tests which wanted to verify that level history is carried forward, as most of those older levels don't exist
	# anymore and are purged from our history
	PlayerSave.populate_rank_data = false
