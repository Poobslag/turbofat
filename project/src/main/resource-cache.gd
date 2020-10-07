extends Node
"""
Preloads resources to speed up scene transitions.

By default, Godot loads the resources it needs for each scene and caches them until they're not needed anymore. This
allows the game to start up quickly, but results in long wait times when transitioning from one scene to another.

By preloading resources used throughout the game, we have a slower startup time in exchange for faster load times
during the game.
"""

# warning-ignore:unused_signal
signal finished_loading

# number of threads to launch; 1 is slower, but more than 4 doesn't seem to help
const THREAD_COUNT := 4

# loading scenes is slower than loading regular resources; this constant estimates how much slower
const WORK_PER_SCENE := 8.0

const CHUNK_SECONDS := 0.1

# enables logging paths and durations for loaded resources
export (bool) var verbose := false

# reduces the number of textures loaded throughout the game
export (bool) var minimal_resources := false

# maintains references to all resources to prevent them from being cleaned up
var _cache := {}
var _cache_mutex := Mutex.new()

# setting this to 'true' causes the background thread to terminate gracefully
var _exiting := false

# background threads for loading resources
var _load_threads := []

# properties used for the get_progress calculation
var _work_done := 0.0
var _work_done_mutex := Mutex.new()
var _work_total := 3.0

var _remaining_resource_paths := []
var _remaining_resource_paths_mutex := Mutex.new()

var _remaining_scene_paths := []
 
# the wallpaper singleton, cached to preserve its appearance during scene transitions
var wallpaper: Node

"""
Initializes the resource load.

For desktop/mobile targets, this involves launching a background thread.

Web targets do not support background threads (Godot issue #12699) so we initialize the list of PNG paths, and load
them one at a time in the _process function.
"""
func start_load() -> void:
	set_process(true)
	_find_resource_paths()
	if OS.has_feature("web"):
		# Godot issue #12699; threads not supported for HTML5
		pass
	else:
		for _i in range(THREAD_COUNT):
			var thread := Thread.new()
			thread.start(self, "_preload_all_resources")
			_load_threads.append(thread)


func _process(_delta: float) -> void:
	if _remaining_resource_paths:
		if OS.has_feature("web"):
			var start_usec := OS.get_ticks_usec()
			# Web targets do not support background threads, so we load a few resources every frame
			while _remaining_resource_paths and OS.get_ticks_usec() < start_usec + 1000000 * CHUNK_SECONDS: 
				_preload_next_resource()
	elif _remaining_scene_paths:
		var start_usec := OS.get_ticks_usec()
		# Loading scenes in threads causes 'another resource is loaded' errors, so we don't thread this
		while _remaining_scene_paths and OS.get_ticks_usec() < start_usec + 1000000 * CHUNK_SECONDS:
			_preload_next_scene()
	else:
		set_process(false)
		call_deferred("emit_signal", "finished_loading")


func _exit_tree() -> void:
	if wallpaper:
		# singletons are not freed when their parent scene is removed from the tree, we have to free them manually
		wallpaper.free()
	if _load_threads:
		_exiting = true
		for thread in _load_threads:
			thread.wait_to_finish()


"""
Replaces non-singletons in the scene tree with their singleton counterparts.
"""
func substitute_singletons(parent: Node) -> void:
	if wallpaper and parent.has_node("Wallpaper"):
		# we have a singleton value to substitute; remove the non-singleton value
		var wallpaper_index := parent.get_children().find(parent.get_node("Wallpaper"))
		parent.get_node("Wallpaper").queue_free()
		parent.remove_child(parent.get_node("Wallpaper"))
		
		# add the singleton value
		parent.add_child(wallpaper)
		parent.move_child(wallpaper, wallpaper_index)
	else:
		# we have no singleton value stored; store a new singleton value
		wallpaper = parent.get_node("Wallpaper")


"""
Removes singletons from the scene tree to prevent them from being freed.
"""
func remove_singletons(parent: Node) -> void:
	if wallpaper and parent.has_node("Wallpaper"):
		parent.remove_child(wallpaper)


func get_progress() -> float:
	return clamp(_work_done / _work_total, 0.0, 1.0)


func is_done() -> bool:
	return _work_done >= _work_total


func has_cached_resource(path: String) -> bool:
	return _cache.has(path)


func get_cached_resource(path: String) -> Resource:
	return _cache.get(path)


"""
Loads all pngs in the /assets directory and stores the resulting resources in our cache

Parameters:
	'_userdata': Unused; needed for threads
"""
func _preload_all_resources(_userdata: Object) -> void:
	while _remaining_resource_paths and not _exiting:
		_preload_next_resource()


"""
Loads a single resource and stores the resulting resource in our cache.

Thread safe.
"""
func _preload_next_resource() -> void:
	_remaining_resource_paths_mutex.lock()
	var path: String = _remaining_resource_paths.pop_front()
	_remaining_resource_paths_mutex.unlock()
	
	_load_resource(path)
	
	_work_done_mutex.lock()
	_work_done += 1.0
	_work_done_mutex.unlock()


"""
Loads a single scene and stores the resulting resource in our cache.

Loading scenes in threads causes 'another resource is loaded' errors, so this is not threaded.
"""
func _preload_next_scene() -> void:
	var path: String = _remaining_scene_paths.pop_front()
	_load_resource(path)
	_work_done += WORK_PER_SCENE


"""
Returns a list of all png files in the /assets directory.

Recursively traverses the assets directory searching for pngs. Any additional directories it discovers are appended to
a queue for later traversal.

Note: We search for '.png.import' files instead of searching for png files directly. This is because png files
	disappear when the project is exported.
"""
func _find_resource_paths() -> Array:
	_remaining_resource_paths.clear()
	
	# directories remaining to be traversed
	var dir_queue := ["res://assets/main", "res://src/main"]
	
	var dir: Directory
	var file: String
	while true:
		if file:
			if dir.current_is_dir():
				dir_queue.append("%s/%s" % [dir.get_current_dir(), file])
			elif file.ends_with(".tscn"):
				_remaining_scene_paths.append("%s/%s" % [dir.get_current_dir(), file.get_file()])
			elif file.ends_with(".png.import") or file.ends_with(".wav.import"):
				_remaining_resource_paths.append("%s/%s" % [dir.get_current_dir(), file.get_basename()])
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
	_remaining_resource_paths.shuffle()
	_remaining_scene_paths.shuffle()
	randomize()
	
	# all pngs have been located. increment the progress bar and calculate its new maximum
	_work_total = 3.0
	_work_total += _remaining_resource_paths.size()
	_work_total += _remaining_scene_paths.size() * WORK_PER_SCENE
	_work_done += 3.0
	
	return _remaining_resource_paths


"""
Loads and caches the resource at the specified path.

If the resource is not found, we cache that fact and do not attempt to load it again.
"""
func _load_resource(resource_path: String) -> void:
	if _cache.has(resource_path):
		# resource already cached
		pass
	else:
		var result
		if not ResourceLoader.exists(resource_path):
			# resource doesn't exist; cache so we don't try again
			result = "_"
		else:
			var start := OS.get_ticks_msec()
			result = load(resource_path)
			var duration := OS.get_ticks_msec() - start
			if verbose: print("resource loaded: %4d, %s" % [duration, resource_path])
		
		_cache_mutex.lock()
		_cache[resource_path] = result
		_cache_mutex.unlock()
