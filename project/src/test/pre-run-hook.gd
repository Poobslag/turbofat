extends GutHookScript
## Performs initialization steps for Gut tests.

func run() -> void:
	# Prevent the player's settings from triggering fullscreen mode or vsync.
	SystemData.disallow_graphics_customization()
