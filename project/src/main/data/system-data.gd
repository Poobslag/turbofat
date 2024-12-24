extends Node
## Stores data about the system and its configuration.
##
## This data includes configuration data like language, keybindings, and graphics settings.
##
## Data about the player's progress and high scores is stored in the PlayerData class, not here.

var gameplay_settings := GameplaySettings.new()
var graphics_settings := GraphicsSettings.new()
var volume_settings := VolumeSettings.new()
var touch_settings := TouchSettings.new()
var keybind_settings := KeybindSettings.new()
var misc_settings := MiscSettings.new()

## We accelerate scene transitions and animations during development.
var fast_mode := OS.is_debug_build()

## If 'true', the player has pending configuration changes which need to be saved
var has_unsaved_changes := false

## We store the non-fullscreened window size so we can restore it when the player disables fullscreen mode.
var _prev_window_size: Vector2 = Global.window_size
var _prev_window_position: Vector2 = OS.window_position

## When the graphics settings change, we update them after a few milliseconds delay.
##
## This delay prevents the game from rapidly toggling between fullscreen and windowed modes on startup when
## initializing and loading the player's settings.
var _refresh_graphics_settings_timer: SceneTreeTimer = null

func _ready() -> void:
	graphics_settings.connect("fullscreen_changed", self, "_on_GraphicsSettings_fullscreen_changed")
	graphics_settings.connect("use_vsync_changed", self, "_on_GraphicsSettings_use_vsync_changed")
	_schedule_refresh_graphics_settings()
	
	# allow the alt+enter shortcut to process even when gameplay is paused
	pause_mode = Node.PAUSE_MODE_PROCESS


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		SystemData.graphics_settings.fullscreen = !SystemData.graphics_settings.fullscreen
		SystemData.has_unsaved_changes = true
		SystemSave.save_system_data()
		if is_inside_tree():
			get_tree().set_input_as_handled()


## Prevents the player's settings from triggering fullscreen mode or vsync.
##
## This is called when running Gut tests to prevent the Gut window from becoming fullscreen. This could happen if the
## developer enables fullscreen mode, or when a test loads system data with fullscreen mode enabled.
func disallow_graphics_customization() -> void:
	graphics_settings.disconnect("fullscreen_changed", self, "_on_GraphicsSettings_fullscreen_changed")
	graphics_settings.disconnect("use_vsync_changed", self, "_on_GraphicsSettings_use_vsync_changed")
	if _refresh_graphics_settings_timer:
		_refresh_graphics_settings_timer.disconnect("timeout", self, "_on_RefreshGraphicsSettingsTimer_timeout")
		_refresh_graphics_settings_timer = null


## Resets the system's in-memory data to a default state.
func reset() -> void:
	gameplay_settings.reset()
	graphics_settings.reset()
	volume_settings.reset()
	touch_settings.reset()
	keybind_settings.reset()
	misc_settings.reset()
	has_unsaved_changes = false


## Apply the vsync/maximized settings.
func _refresh_graphics_settings() -> void:
	OS.set_use_vsync(graphics_settings.use_vsync)
	
	var old_maximized := OS.window_maximized and OS.window_borderless
	var new_maximized := graphics_settings.fullscreen
	
	if not old_maximized and new_maximized:
		# becoming maximized; store the old window size and position
		_prev_window_size = OS.window_size
		_prev_window_position = OS.window_position
	
	OS.window_borderless = graphics_settings.fullscreen
	OS.window_maximized = graphics_settings.fullscreen
	
	if old_maximized and not new_maximized:
		# becoming windowed; restore the old window size and position
		OS.window_size = _prev_window_size
		OS.window_position = _prev_window_position


## Schedules the vsync/maximized settings to be applied a few milliseconds in the future.
##
## This delay prevents the game from rapidly toggling between fullscreen and windowed modes on startup when
## initializing and loading the player's settings.
func _schedule_refresh_graphics_settings() -> void:
	if not is_inside_tree():
		return
	if _refresh_graphics_settings_timer != null:
		return
	
	_refresh_graphics_settings_timer = get_tree().create_timer(0.05)
	_refresh_graphics_settings_timer.connect("timeout", self, "_on_RefreshGraphicsSettingsTimer_timeout")


func _on_GraphicsSettings_fullscreen_changed(_value: bool) -> void:
	_schedule_refresh_graphics_settings()


func _on_GraphicsSettings_use_vsync_changed(_value: bool) -> void:
	_schedule_refresh_graphics_settings()


## When the RefreshGraphicsSettings timer times out, we call _refresh_graphics_settings() and reset the timer.
func _on_RefreshGraphicsSettingsTimer_timeout() -> void:
	_refresh_graphics_settings_timer = null
	_refresh_graphics_settings()
