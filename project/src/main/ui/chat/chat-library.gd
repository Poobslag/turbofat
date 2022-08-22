extends Node
## Loads chat lines from files.
##
## Chat lines are stored as a set of chatscript resources. This class loads those resources into ChatTree instances so
## they can be fed into the UI.

const DEFAULT_CHAT_KEY_ROOT_PATH := "res://assets/main"

const CHAT_EXTENSION := ".chat"

## Resource path containing career cutscenes. Can be changed for demos and tests.
var chat_key_root_path := DEFAULT_CHAT_KEY_ROOT_PATH


## Returns the chat tree for the specified chat key, such as 'chat/marsh_prologue'.
##
## Parameters:
## 	'chat_key': A key such as 'chat/marsh_prologue' identifying a chat resource
func chat_tree_for_key(chat_key: String) -> ChatTree:
	var path := path_from_chat_key(chat_key)
	return chat_tree_from_file(path)


func chat_exists(chat_key: String) -> bool:
	return FileUtils.file_exists(path_from_chat_key(chat_key))


## Loads the chat events from the specified file.
func chat_tree_from_file(path: String) -> ChatTree:
	var result: ChatTree
	if path.ends_with(CHAT_EXTENSION):
		result = _chat_tree_from_chatscript_file(path)
	else:
		push_error("Unrecognized cutscene suffix: %s" % [path])
	return result


## Add lull characters to the specified string.
##
## Lull characters make the chat UI briefly pause at parts of the chat line. We add these after periods, commas and
## other punctuation.
func add_lull_characters(s: String) -> String:
	if "|" in s:
		# if the sentence already contains lull characters, we leave it alone
		return s
	
	var transformer := StringTransformer.new(s)
	
	# add pauses after certain kinds of punctuation
	transformer.sub("([!.?,])", "$1|")
	
	# add pauses after dashes, but not in hyphenated words
	transformer.sub("(-)(?=[|!.?,\\- ])", "$1|")
	
	# remove pauses from ellipses which conclude a line, unless the entire sentence is an ellipsis
	if transformer.search("[^\\|!.?,\\- ]"):
		for _i in range(10):
			var old_transformed := transformer.transformed
			transformer.sub("\\|([\\|!.?]*)$", "$1")
			if old_transformed == transformer.transformed:
				break
	
	# remove lull character from the end of the line
	transformer.transformed = transformer.transformed.trim_suffix("|")
	
	return transformer.transformed


## Add many lull characters to the specified string to make it pause after every character.
##
## This can be used for very short sentences like 'OH, MY!!!'
func add_mega_lull_characters(s: String) -> String:
	var transformer := StringTransformer.new(s)
	
	# long pause between words
	transformer.sub(" ", "|| ")
	
	# short pause between letters, punctuation
	transformer.sub("([^| ])", "$1|")
	
	# remove lull character from the end of the line
	transformer.transformed = transformer.transformed.trim_suffix("|")
	return transformer.transformed


## Converts a path like 'res://assets/main/chat/career/lemon/20-a.chat' into a chat key like
## 'chat/career/lemon/20_a'.
##
## Using these chat keys has many benefits. Most notably they aren't invalidated if we move files or change extensions.
##
## Parameters:
## 	'path': The path of a chat resource.
##
## Returns:
## 	A key such as 'chat/career/lemon/20_a' corresponding to the specified chat resource
func chat_key_from_path(path: String) -> String:
	var chat_key := path
	chat_key = chat_key.trim_suffix(".chat")
	chat_key = chat_key.trim_prefix("%s/" % [chat_key_root_path])
	chat_key = StringUtils.hyphens_to_underscores(chat_key)
	return chat_key


## Converts a chat key like 'chat/career/lemon/20_a' into a path like
## 'res://assets/main/chat/career/lemon/20-a.chat'
##
## Parameters:
## 	'chat_key': A chat key such as 'chat/career/lemon/20_a'
##
## Returns:
## 	The path of the resource identified by the specified chat key.
func path_from_chat_key(chat_key: String) -> String:
	var path := chat_key
	path = StringUtils.underscores_to_hyphens(chat_key)
	path = "%s/%s.chat" % [chat_key_root_path, path]
	return path


## Loads the chat events from the specified chatscript file.
func _chat_tree_from_chatscript_file(path: String) -> ChatTree:
	var chat_tree: ChatTree
	if not FileUtils.file_exists(path):
		push_error("File not found: %s" % path)
		chat_tree = ChatTree.new()
	else:
		var parser := ChatscriptParser.new()
		chat_tree = parser.chat_tree_from_file(path)
	
	return chat_tree
