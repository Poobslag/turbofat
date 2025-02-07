extends Node
## Automation script for stress testing.
##
## If enabled, this script will quickly launch a puzzle, drop 6 pieces, and exit the puzzle over and over again. This
## is useful for verifying whether the game can handle someone playing hundreds of puzzles in a row.
##
## To enable this script, it needs to be added to the Project Settings as an Autoload singleton.

## The interval between UI clicks and keypresses. By default, inputs will be run every single frame.
export (float, 0.0, 2.0) var interval: float = 0.1

## 'true' if the automation script should run.
export (bool) var active := true

## If 'interval' is assigned, this timer triggers UI clicks and keypresses.
var _interval_timer: Timer

## The time that the current scene was launched.
var _scene_start_time := 0

## The number of intervals which the current scene has been running for.
var _scene_cycle_count := 0

## Scene-based state, used for business logic.
##
## Scene-specific business logic can store arbitrary properties in here to track the scene state. For example if we
## wanted to simulate clicking a button three times, we could store the number of times the button has been clicked.
##
## These properties are cleared during a scene change.
var _scene_state := {}

## 'true' if a UI click or keypress has been triggered during this frame.
var _simulated_input := false

func _ready() -> void:
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")
	
	# If 'interval' is unset, we run a test cycle during each '_process' step
	set_process(active and interval == 0.0)
	
	if active and interval > 0.0:
		# If 'interval' is set, we schedule the timer for the specified time interval
		_interval_timer = Timer.new()
		add_child(_interval_timer)
		_interval_timer.start(interval)
		_interval_timer.connect("timeout", self, "_on_Timer_timeout")
	
	if active:
		# Disable verbose debug messages. Changing scenes 100s of time generates too much output otherwise.
		Global.verbose_stdout_mode = false


func _process(_delta: float) -> void:
	_run_test_cycle()


## Runs a single test cycle, simulating any necessary keypresses or mouse clicks.
func _run_test_cycle() -> void:
	_simulated_input = false
	
	if get_tree().get_root().is_input_disabled():
		return
	
	match get_tree().current_scene.name:
		"SplashScreen": _run_splash_screen()
		"MainMenu": _run_main_menu()
		"TrainingMenu": _run_training_menu()
		"Puzzle": _run_puzzle_1()
	
	_scene_cycle_count += 1


## Returns the number of milliseconds since the scene was launched.
func _scene_ticks_msec() -> int:
	return Time.get_ticks_msec() - _scene_start_time


## Clicks the splash screen's play button.
func _run_splash_screen() -> void:
	var play_button := get_tree().current_scene.get_node("DropPanel/PlayHolder/Play")
	_left_click_control(play_button)


## Clicks the main menu's training button.
func _run_main_menu() -> void:
	var training_button := get_tree().current_scene.get_node("DropPanel/Practice/Training")
	_left_click_control(training_button)


## Clicks the training menu's start button.
func _run_training_menu() -> void:
	var start_button := get_tree().current_scene.get_node("MainMenu/DropPanel/VBoxContainer/System/Start")
	_left_click_control(start_button)


## Interacts with the puzzle scene, starting a level, dropping six pieces and exiting.
func _run_puzzle_1() -> void:
	if not _simulated_input and _scene_state.get("state", 0) == 0:
		var start_button := get_tree().current_scene.get_node("Hud/Center/PuzzleMessages/Buttons/Start")
		if not start_button:
			push_error("start button not found")
			_scene_state["state"] = 999
		else:
			_left_click_control(start_button)
			if not start_button.is_visible_in_tree():
				_scene_state["state"] = 100
	
	if not _simulated_input and _scene_state.get("state", 0) == 100:
		match PuzzleState.level_performance.pieces:
			0, 1:
				_press_key(KEY_LEFT)
				_release_key(KEY_RIGHT)
				_press_key(KEY_SPACE)
			2, 3:
				_release_key(KEY_LEFT)
				_release_key(KEY_RIGHT)
				_press_key(KEY_SPACE)
			4, 5:
				_release_key(KEY_LEFT)
				_press_key(KEY_RIGHT)
				_press_key(KEY_SPACE)
			6:
				_release_key(KEY_LEFT)
				_release_key(KEY_RIGHT)
				_release_key(KEY_SPACE)
				_scene_state["state"] = 200
	
	if not _simulated_input and _scene_state.get("state", 0) == 200:
		_press_key(KEY_ESCAPE)
		_release_key(KEY_ESCAPE)
		_scene_state["state"] = 300
	
	if not _simulated_input and _scene_state.get("state", 0) == 300:
		var give_up_button := get_tree().current_scene.get_node(
				"SettingsMenu/Window/UiArea/Bottom/HBoxContainer/VBoxContainer1/Holder1/Quit1")
		if not give_up_button:
			push_error("give_up button not found")
			_scene_state["state"] = 999
		else:
			_left_click_control(give_up_button)
			if not give_up_button.is_visible_in_tree():
				_scene_state["state"] = 400
	
	if not _simulated_input and _scene_state.get("state", 0) == 400:
		var back_button := get_tree().current_scene.get_node("Hud/Center/PuzzleMessages/Buttons/Back")
		_left_click_control(back_button)


## Clicks the center of a control (typically a button.)
func _left_click_control(control: Control) -> void:
	_left_click(control.get_global_rect().get_center())


## Clicks a position on the screen (typically the center of a button.)
func _left_click(position: Vector2) -> void:
	_press_mouse(BUTTON_LEFT, position)
	_release_mouse(BUTTON_LEFT, position)


## Simulates a mouse press event.
func _press_mouse(button_index: int, position: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.set_button_index(button_index)
	press.set_position(position)
	press.set_pressed(true)
	Input.parse_input_event(press)
	_simulated_input = true


## Simulates a mouse release event.
func _release_mouse(button_index: int, position: Vector2) -> void:
	var release := InputEventMouseButton.new()
	release.set_button_index(button_index)
	release.set_position(position)
	release.set_pressed(false)
	Input.parse_input_event(release)
	_simulated_input = true


## Simulates a key press event.
func _press_key(scancode: int) -> void:
	var key := InputEventKey.new()
	key.scancode = scancode
	key.pressed = true
	Input.parse_input_event(key)
	_simulated_input = true


## Simulates a key release event.
func _release_key(scancode: int) -> void:
	var key := InputEventKey.new()
	key.scancode = scancode
	key.pressed = false
	Input.parse_input_event(key)
	_simulated_input = true


## Each time the specified timer interval elapses, we run a single test cycle.
func _on_Timer_timeout() -> void:
	_run_test_cycle()


## When the scene changes, we reset any scene-specific test data.
func _on_SceneTree_node_added(node: Node) -> void:
	if not is_inside_tree():
		return
	if node == get_tree().current_scene:
		_scene_cycle_count = 0
		_scene_state.clear()
		_scene_start_time = Time.get_ticks_msec()
		print("[%s] Loading scene %s." % [Time.get_ticks_msec(), node.name])
