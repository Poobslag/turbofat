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

# resources which shouldn't be cached. we shouldn't cache large resources unless it's necessary
export (Array, String) var skipped_resource_paths: Array

# maintains references to all resources to prevent them from being cleaned up
# key: resource path
# value: resource
var _cache := {}
var _cache_mutex := Mutex.new()

# stores parsed versions of Aseprite json resources to speed up retrieval
# key: json resource path
# value: array of Rect2 instances representing regions defined by Aseprite
var _frame_src_rect_cache := {}
var _frame_dest_rect_cache := {}
var _frame_cache_mutex := Mutex.new()

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
 
# singleton nodes, cached to preserve their appearance during scene transitions
# key: singleton names
# value: singleton nodes
var _singletons: Dictionary

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
	for singleton in _singletons.values():
		# singletons are not freed when their parent scene is removed from the tree, we have to free them manually
		singleton.free()
	if _load_threads:
		_exiting = true
		for thread in _load_threads:
			thread.wait_to_finish()


"""
Replaces non-singletons in the scene tree with their singleton counterparts.
"""
func substitute_singletons() -> void:
	for non_singleton_obj in get_tree().get_nodes_in_group("singletons"):
		var non_singleton: Node = non_singleton_obj
		
		var parent := non_singleton.get_parent()
		if _singletons.has(non_singleton.name):
			# we have a singleton value to substitute; remove the non-singleton value
			var wallpaper_index := parent.get_children().find(non_singleton)
			non_singleton.queue_free()
			parent.remove_child(non_singleton)
			
			# add the singleton value
			parent.add_child(_singletons[non_singleton.name])
			parent.move_child(_singletons[non_singleton.name], wallpaper_index)
		else:
			# we have no singleton value stored; store a new singleton value
			_singletons[non_singleton.name] = non_singleton


"""
Removes singletons from their parent nodes to prevent them from being freed.
"""
func remove_singletons() -> void:
	for singleton_obj in _singletons.values():
		if singleton_obj.get_parent():
			singleton_obj.get_parent().remove_child(singleton_obj)


func get_progress() -> float:
	return clamp(_work_done / _work_total, 0.0, 1.0)


func is_done() -> bool:
	return _work_done >= _work_total


func has_cached_resource(path: String) -> bool:
	return _cache.has(path)


func get_cached_resource(path: String) -> Resource:
	return _cache.get(path)


"""
Returns Rect2 instances representing sprite sheet regions loaded from an Aseprite JSON file.

The resulting Rect2s are sprite sheet regions where each frame can be read.
"""
func get_frame_src_rects(path: String) -> Array:
	return _frame_src_rect_cache.get(path, [])


"""
Returns Rect2 instances representing screen regions loaded from an Aseprite JSON file.

The resulting Rect2s are screen regions where each frame should be drawn
"""
func get_frame_dest_rects(path: String) -> Array:
	return _frame_dest_rect_cache.get(path, [])


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
	
	if path.ends_with(".json"):
		_load_json_resource(path)
	else:
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
			var resource_path: String
			if file.ends_with(".import"):
				resource_path = "%s/%s" % [dir.get_current_dir(), file.get_basename()]
			else:
				resource_path = "%s/%s" % [dir.get_current_dir(), file.get_file()]
			if resource_path in skipped_resource_paths:
				if verbose: print("resource skipped: %s" % [resource_path])
			elif dir.current_is_dir():
				dir_queue.append(resource_path)
			elif file.ends_with(".tscn"):
				_remaining_scene_paths.append(resource_path)
			elif file.ends_with(".png.import") or file.ends_with(".wav.import"):
				_remaining_resource_paths.append(resource_path)
			elif file.ends_with(".json"):
				_remaining_resource_paths.append(resource_path)
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
Loads and caches the parsed version of an Aseprite json resource at the specified path.

If the specified json resource is not an Aseprite json resource, we do nothing.
"""
func _load_json_resource(json_path: String) -> void:
	# parse json
	var json: String = FileUtils.get_file_as_text(json_path)
	var json_root: Dictionary = parse_json(json)
	if not json_root.has("frames"):
		# the specified json resource is not an Aseprite json resource; do nothing
		return
	
	# extract frame data from json
	var json_frames: Array
	if json_root["frames"] is Array:
		json_frames = json_root["frames"]
	elif json_root["frames"] is Dictionary:
		json_frames = json_root["frames"].values()
	else:
		push_warning("Invalid frame data in file '%s'" % json_path)
	
	# store json frame data as Rect2 instances
	_frame_cache_mutex.lock()
	var frame_src_rects := []
	var frame_dest_rects := []
	for json_frame in json_frames:
		frame_src_rects.append(Utils.json_to_rect2(json_frame["frame"]))
		frame_dest_rects.append(Utils.json_to_rect2(json_frame["spriteSourceSize"]))
	_frame_src_rect_cache[json_path] = frame_src_rects
	_frame_dest_rect_cache[json_path] = frame_dest_rects
	_frame_cache_mutex.unlock()


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
