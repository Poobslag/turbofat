extends Node
"""
Preloads resources to speed up scene transitions.

By default, Godot loads the resources it needs for each scene and caches them until they're not needed anymore. This
allows the game to start up quickly, but results in long wait times when transitioning from one scene to another.

By preloading resources used throughout the game, we have a slower startup time in exchange for faster load times
during the game.
"""

signal finished_loading

# enables logging paths and durations for loaded resources
export (bool) var _verbose := false

# maintains references to all resources to prevent them from being cleaned up
var _cache := {}

# setting this to 'true' causes the background thread to terminate gracefully
var _exiting := false

# background thread for loading resources
var _load_thread: Thread

# these two properties are used for the get_progress calculation
var _work_done := 0.0
var _work_remaining := 3.0
var _remaining_png_paths := []

"""
Initializes the resource load.

For desktop/mobile targets, this involves launching a background thread.

Web targets do not support background threads (Godot issue #12699) so we initialize the list of PNG paths, and load
them one at a time in the _process function.
"""
func start_load() -> void:
	if OS.has_feature("web"):
		# Godot issue #12699; threads not supported for HTML5
		_find_png_paths()
	else:
		_load_thread = Thread.new()
		_load_thread.start(self, "_preload_all_pngs")


func _process(delta: float) -> void:
	if OS.has_feature("web") and _remaining_png_paths:
		# Web targets do not support background threads, so we load resources one at a time
		_preload_next_png()


func _exit_tree() -> void:
	if _load_thread:
		_exiting = true
		_load_thread.wait_to_finish()


func get_progress() -> float:
	return clamp(_work_done / _work_remaining, 0.0, 1.0)


"""
Loads all pngs in the /assets directory and stores the resulting resources in our cache

Parameters:
	'userdata': Unused; needed for threads
"""
func _preload_all_pngs(userdata: Object) -> void:
	_find_png_paths()
	
	while _remaining_png_paths and not _exiting:
		_preload_next_png()


"""
Loads a single png in the /assets directory and stores the resulting resource in our cache
"""
func _preload_next_png() -> void:
	_load_resource(_remaining_png_paths.pop_front())
	_work_done += 1.0
	if not _remaining_png_paths:
		emit_signal("finished_loading")


"""
Returns a list of all png files in the /assets directory.

Recursively traverses the assets directory searching for pngs. Any additional directories it discovers are appended to
a queue for later traversal.

Note: We search for '.png.import' files instead of searching for png files directly. This is because png files
	disappear when the project is exported.
"""
func _find_png_paths() -> Array:
	_remaining_png_paths.clear()
	
	# directories remaining to be traversed
	var dir_queue := ["res://assets"]
	
	var dir: Directory
	var file: String
	while true:
		if file:
			if dir.current_is_dir():
				dir_queue.append("%s/%s" % [dir.get_current_dir(), file])
			elif file.ends_with(".png.import"):
				_remaining_png_paths.append("%s/%s" % [dir.get_current_dir(), file.get_basename()])
		else:
			if dir:
				dir.list_dir_end()
			if dir_queue.empty():
				break
			# there are more directories. open the next directory
			dir = Directory.new()
			dir.open(dir_queue.pop_front())
			dir.list_dir_begin(true, true)
		file = dir.get_next()
	
	seed(253686)
	# We shuffle the pngs to prevent clumps of similar files. We use a known seed to keep the timing predictable.
	_remaining_png_paths.shuffle()
	
	# all pngs have been located. increment the progress bar and calculate its new maximum
	_work_remaining += _remaining_png_paths.size()
	_work_done += 3.0
	
	return _remaining_png_paths


"""
Loads and caches the resource at the specified path.

If the resource is not found, we cache that fact and do not attempt to load it again.
"""
func _load_resource(resource_path: String) -> void:
	if _cache.has(resource_path):
		# resource already cached
		pass
	elif !ResourceLoader.exists(resource_path):
		# resource doesn't exist; cache so we don't try again
		_cache[resource_path] = "_"
	else:
		var start := OS.get_ticks_msec()
		_cache[resource_path] = load(resource_path)
		var duration := OS.get_ticks_msec() - start
		if _verbose: print("resource loaded: %4d, %s" % [duration, resource_path])
