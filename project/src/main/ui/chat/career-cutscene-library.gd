extends Node
## Manages data for all cutscenes in career mode. This includes logic for loading them, arranging them into a
## hierarchy, and deciding which order they're shown in.
##
## Cutscene resources are arranged in a mostly-flat directory structure like this:
##
## 	career/general/00-a
## 	career/general/00-b
## 	career/marsh/00
## 	career/marsh/00-end
## 	career/marsh/10-a
## 	career/marsh/10-b
## 	career/marsh/10-c
## 	...
##
## However, these filenames define a tree-like structure for cutscenes:
##
## 	+career/general
## 	|+career/general/00
## 	||-career/general/00_a
## 	|\-career/general/00_b
## 	+career/marsh
## 	|+career/marsh/00
## 	|+career/marsh/10
## 	||-career/marsh/10_a
## 	||-career/marsh/10_b
## 	|\-career/marsh/10_c
## 	|...
##
## These cutscenes are ordered such that numeric siblings are always played in ascending order (00, 10, 11, 20..) but
## alphabetic siblings are played in random order (c, a, b...). These ordering rules apply both to leaf nodes as well
## as parent nodes.

## Default resource path containing career cutscenes.
const DEFAULT_CAREER_CUTSCENE_ROOT_PATH := "res://assets/main/chat/career"

## List of specially named chat keys which should be excluded when browsing for cutscenes to play
const SPECIAL_CHAT_KEY_NAMES := [
	"prologue",
	"intro_level",
	"intro_level_end",
	"boss_level",
	"boss_level_end",
	"epilogue",
]

## Search flag for find_chat_key_pairs, which indicates that all numeric children should be included, instead of just
## including the lowest-numbered one
const INCLUDE_ALL_NUMERIC_CHILDREN := "include_all_numeric_children"

## Search flag for find_chat_key_pairs, which specifies a list of chat keys to exclude from the results
const EXCLUDED_CHAT_KEYS := "excluded_chat_keys"

## Resource path containing career cutscenes. Can be changed for tests.
var career_cutscene_root_path := DEFAULT_CAREER_CUTSCENE_ROOT_PATH setget set_career_cutscene_root_path

## Ordered list of chat key pairs, from earliest cutscenes to latest cutscenes
##
## Each entry in this array is a dictionary with a 'preroll' entry and/or a 'postroll' entry, defining chat keys
## for cutscenes which play before or after a level.
##
## This is calculated based on the contents of the filesystem, but can be overridden for tests.
var all_chat_key_pairs := [] setget set_all_chat_key_pairs

## key: (String) A preroll chat key like 'chat/career/general_00_a'. For the case where a level has a postroll cutscene
## 	but no preroll cutscene, this chat key may actually correspond to a non-existent preroll cutscene.
##
## value: (Dictionary) A dictionary with a 'preroll' entry and/or a 'postroll' entry, defining chat keys for
## 	cutscenes which play before or after a level.
var _chat_key_pairs_by_preroll := {}

## Defines a hierarchy of preroll cutscenes.
##
## key: (String) A preroll chat key like 'chat/career/general_00_a', or a parent path like 'chat/career/general'.
##
## value: (Array) A list of child chat key fragments, like ['00', '01', '02']. Each fragment corresponds to a suffix
## 	which can be appended to the chat key, along with an appropriate delimeter, to create a new path.
var _preroll_tree := {}

func _ready() -> void:
	_refresh_chat_key_pairs()


## Updates the location for career cutscenes.
##
## Also regenerates all internal fields such as the chat key pairs and preroll tree.
func set_career_cutscene_root_path(new_career_cutscene_root_path: String) -> void:
	career_cutscene_root_path = new_career_cutscene_root_path
	_refresh_chat_key_pairs()


## Calculates the list of potential chat key pairs, and returns a random one.
##
## Parameters:
## 	'chat_key_roots': An array of string chat key roots like 'chat/career/marsh' which correspond to a group of
## 		cutscenes to choose between.
##
## Returns:
## 	A dictionary with a 'preroll' entry and/or a 'postroll' entry, defining chat keys for cutscenes which play
## 	before or after a level.
func next_chat_key_pair(chat_key_roots: Array) -> Dictionary:
	var potential_chat_key_pairs := potential_chat_key_pairs(chat_key_roots)
	return Utils.rand_value(potential_chat_key_pairs) if potential_chat_key_pairs else {}


## Calculates the list of potential chat key pairs.
##
## Parameters:
## 	'chat_key_roots': An array of string chat key roots like 'chat/career/marsh' which correspond to a group of
## 		cutscenes to choose between.
##
## Returns:
## 	A list of dictionary entries. Each dictionary entry has a 'preroll' entry and/or a 'postroll' entry, defining
## 	chat keys for cutscenes which play before or after a level.
func potential_chat_key_pairs(chat_key_roots: Array) -> Array:
	var exhausted_chat_keys := exhausted_chat_keys(chat_key_roots)
	return find_chat_key_pairs(chat_key_roots, {"excluded_chat_keys": exhausted_chat_keys})


## Assigns the list of chat key pairs, and regenerates all internal fields such as the preroll tree.
func set_all_chat_key_pairs(new_all_chat_key_pairs: Array) -> void:
	all_chat_key_pairs = new_all_chat_key_pairs
	
	# populate _chat_key_pairs_by_preroll
	_chat_key_pairs_by_preroll.clear()
	for chat_key_pair in all_chat_key_pairs:
		var preroll_key := _preroll_key_from_chat_key_pair(chat_key_pair)
		_chat_key_pairs_by_preroll[preroll_key] = chat_key_pair
	
	# populate _preroll_tree
	_preroll_tree.clear()
	for chat_key_pair in all_chat_key_pairs:
		var preroll_key := _preroll_key_from_chat_key_pair(chat_key_pair)
		var key_parts := [StringUtils.substring_before_last(preroll_key, "/")]
		key_parts.append_array(StringUtils.substring_after_last(preroll_key, "/").split("_"))
		for i in range(1, key_parts.size()):
			var key_part: String = key_parts[i]
			var prefix: String = key_parts[0]
			if i >= 2:
				prefix += "/" + PoolStringArray(key_parts.slice(1, i - 1)).join("_")
			if not _preroll_tree.has(prefix):
				_preroll_tree[prefix] = []
			if not _preroll_tree[prefix].has(key_part):
				_preroll_tree[prefix].append(key_part)


## Returns a collection of preroll chat keys for cutscenes the player has already seen.
##
## Parameters:
## 	'chat_key_roots': An array of string chat key roots like 'chat/career/marsh' which correspond to a group of
## 		cutscenes to choose between.
##
## Returns:
## 	A set of chat keys for cutscenes the player has already seen. This includes the leaf nodes for cutscenes which
## 	have been seen, and branch nodes where all child cutscenes have been seen.
func exhausted_chat_keys(chat_key_roots: Array) -> Dictionary:
	var excluded_chat_keys := {}
	
	# branches are only exhausted when their leaves are exhausted, so leaves must be traversed first (postorder)
	var chat_key_queue := chat_keys(chat_key_roots)
	while chat_key_queue:
		var chat_key: String = chat_key_queue.pop_front()
		var chat_key_pair: Dictionary = _chat_key_pairs_by_preroll.get(chat_key, {})
		var preroll: String = chat_key_pair.get("preroll", "")
		var postroll: String = chat_key_pair.get("postroll", "")
		if preroll and not PlayerData.chat_history.is_chat_finished(preroll):
			# don't exclude; preroll cutscene hasn't been played
			continue
		if postroll and not PlayerData.chat_history.is_chat_finished(postroll):
			# don't exclude; postroll cutscene hasn't been played
			continue
		elif _preroll_tree.has(chat_key):
			# calculate whether all child cutscenes have been played
			var all_children_exhausted := true
			for child in _preroll_tree.get(chat_key):
				var child_key := _child_key(chat_key_roots, chat_key, child)
				if not excluded_chat_keys.has(child_key):
					all_children_exhausted = false
			if not all_children_exhausted:
				# don't exclude; child cutscenes haven't been played
				continue
		
		# exclude; neither this node nor its children contains unplayed cutscenes
		excluded_chat_keys[chat_key] = true
	
	return excluded_chat_keys


## Returns a list of all chat keys in _preroll_tree in preroll order (leaves first.)
##
## Parameters:
## 	'chat_key_roots': An array of string chat key roots like 'chat/career/marsh' which correspond to a group of
## 		cutscenes to choose between.
##
## Returns:
## 	An array of String chat keys in postorder (leaves first)
func chat_keys(chat_key_roots: Array) -> Array:
	var chat_keys := []
	var chat_key_queue := chat_key_roots.duplicate()
	while chat_key_queue:
		var chat_key: String = chat_key_queue.pop_front()
		
		var children: Array = _preroll_tree.get(chat_key, [])
		for child in children:
			var child_key := _child_key(chat_key_roots, chat_key, child)
			chat_key_queue.push_front(child_key)
		
		chat_keys.push_front(chat_key)
	return chat_keys


## Filters the list of potential chat key pairs, excluding the specified chat keys.
##
## The returned list includes only the earliest numeric keys in each branch, because numeric siblings are always
## played in ascending order. However, it includes ALL alphabetic keys in each branch, because alphabetic siblings are
## played in random order.
##
## The 'search_flags' parameter accepts several different search flags, which can be combined:
## 	'include_all_numeric_children': If true, indicates that all numeric children should be included, instead of just
## 		including the lowest-numbered one
## 	'excluded_chat_keys': A set of chat keys for cutscenes the player has already seen. This includes the leaf nodes
## 		for cutscenes which have been seen, and branch nodes where all child cutscenes have been seen. If omitted, no
## 		chat keys will be excluded.
##
## Parameters:
## 	'chat_key_roots': An array of string chat key roots like 'chat/career/marsh' which correspond to a group of
## 		cutscenes to choose between.
##
## 	'search_flags': A dictionary of flags defining search behavior, as documented above.
##
## Returns:
## 	A filtered list of dictionary entries. Each dictionary entry has a 'preroll' entry and/or a 'postroll' entry,
## 	defining chat keys for cutscenes which play before or after a level.
func find_chat_key_pairs(chat_key_roots: Array, search_flags: Dictionary) -> Array:
	var potential_chat_key_pairs := []
	var include_all_numeric_children: bool = search_flags.get(INCLUDE_ALL_NUMERIC_CHILDREN, false)
	var excluded_chat_keys: Dictionary = search_flags.get(EXCLUDED_CHAT_KEYS, {})
	
	# We traverse the tree top-down. This queue tracks the child nodes we haven't traversed:
	#
	# [['00-a-01', '00-a-02], ['00-b', '00-c'], ['01']]
	#
	# Each entry in the queue is an array with the untraversed keys at that tree level. The first entry in the queue
	# is a list of the deepest untraversed keys; the last entry in the queue is a list of untraversed roots.
	var chat_key_queue := [chat_key_roots]
	
	# if the player's seen all cutscenes in a chat key root, remove it when initializing the queue
	chat_key_queue[0] = Utils.subtract(chat_key_queue[0], excluded_chat_keys.keys())
	
	while chat_key_queue and chat_key_queue.front():
		var chat_key: String = chat_key_queue.front().pop_front()
		var children: Array = _preroll_tree.get(chat_key, [])
		if not children:
			# leaf node; enqueue it
			potential_chat_key_pairs.append(_chat_key_pairs_by_preroll[chat_key])
		else:
			# branch node; enqueue its children
			chat_key_queue.push_front([])
			var min_numeric_child := ""
			for child in children:
				# enqueue letter key
				var child_key := _child_key(chat_key_roots, chat_key, child)
				if excluded_chat_keys.has(child_key):
					# don't include these chat keys; the player's already seen these cutscenes
					pass
				elif not include_all_numeric_children and child.is_valid_integer():
					if not min_numeric_child or int(child) < int(min_numeric_child):
						# track lowest-numbered numeric key
						min_numeric_child = child
				else:
					if not excluded_chat_keys.has(child_key):
						chat_key_queue.front().push_back(child_key)
				
			# enqueue lowest-numbered numeric key
			if min_numeric_child:
				var child_key := _child_key(chat_key_roots, chat_key, min_numeric_child)
				if not excluded_chat_keys.has(child_key):
					chat_key_queue.front().push_front(child_key)
		
		# dequeue any empty arrays before iterating, so the loop will terminate
		while chat_key_queue and not chat_key_queue.front():
			chat_key_queue.pop_front()
	
	return potential_chat_key_pairs


## Returns a child chat key by combining the specified chat key with a delimiter and suffix.
##
## 	_child_key(['chat/career/general', 'chat/career/general', '00']       = 'chat/career/general/00'
## 	_child_key(['chat/career/general', 'chat/career/general/00', 'a']     = 'chat/career/general/00_a'
## 	_child_key(['chat/career/general', 'chat/career/general/00_a', '0']   = 'chat/career/general/00_a_0'
func _child_key(chat_key_roots: Array, chat_key: String, child_suffix: String) -> String:
	return chat_key + ("/" if chat_key in chat_key_roots else "_") + child_suffix


## Returns the parent of the specified chat key.
##
## 	_parent_key("chat/career/general_00_a")  = "chat/career/general_00"
## 	_parent_key("chat/career/general")       = "chat/career"
func _parent_key(chat_key: String) -> String:
	return chat_key.substr(0, max(chat_key.find_last("_"), chat_key.find_last("/")))


## Returns the preroll key for the specified chat key pair.
##
## Parameters:
## 	'chat_key_pair': A dictionary with a 'preroll' entry and/or a 'postroll' entry, defining chat keys for cutscenes
## 		which play before or after a level.
##
## Returns:
## 	A preroll key for the specified chat key pair. For the case where a level has a postroll cutscene but no
## 	preroll cutscene, this chat key may actually correspond to a non-existent preroll cutscene.
func _preroll_key_from_chat_key_pair(chat_key_pair: Dictionary) -> String:
	var preroll_key: String
	if chat_key_pair.has("preroll"):
		preroll_key = chat_key_pair.get("preroll")
	else:
		preroll_key = chat_key_pair.get("postroll").trim_suffix("_end")
	return preroll_key


func _is_special_chat_key(chat_key: String) -> bool:
	var result := false
	for special_chat_key_name in SPECIAL_CHAT_KEY_NAMES:
		if chat_key.ends_with(special_chat_key_name):
			result = true
			break
	return result


## Finds all chat key pairs by searching for resources under the career_cutscene_root_path.
##
## Also regenerates all internal fields such as the preroll tree.
func _refresh_chat_key_pairs() -> void:
	var resource_paths := _find_resource_paths(career_cutscene_root_path)
	
	# populate all_chat_key_pairs
	var new_all_chat_key_pairs := []
	var chat_key_pairs_by_preroll_tmp := {}
	for resource_path in resource_paths:
		var chat_key: String = ChatLibrary.chat_key_from_path(resource_path)
		var preroll_key := chat_key.trim_suffix("_end")
		
		if _is_special_chat_key(chat_key):
			# don't include special chat keys: prologue, epilogue, etc...
			continue
		
		if not chat_key_pairs_by_preroll_tmp.has(preroll_key):
			var new_chat_key_pair := {}
			new_all_chat_key_pairs.append(new_chat_key_pair)
			chat_key_pairs_by_preroll_tmp[preroll_key] = new_chat_key_pair
		
		if chat_key.ends_with("_end"):
			# postroll key
			chat_key_pairs_by_preroll_tmp[preroll_key]["postroll"] = chat_key
		else:
			chat_key_pairs_by_preroll_tmp[preroll_key]["preroll"] = chat_key
	
	# assign all_chat_key_pairs, regenerate other internal fields such as the preroll tree
	set_all_chat_key_pairs(new_all_chat_key_pairs)


## Returns a list of all file paths in the specified directory, performing a tree traversal.
static func _find_resource_paths(path: String) -> Array:
	var resource_paths := []
	
	# queue of directories remaining to be traversed
	var dir_queue := [path]
	var dir: Directory
	var file: String
	while true:
		if file:
			var resource_path := "%s/%s" % [dir.get_current_dir(), file.get_file()]
			if dir.current_is_dir():
				dir_queue.append(resource_path)
			else:
				resource_paths.append(resource_path)
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
	
	return resource_paths
