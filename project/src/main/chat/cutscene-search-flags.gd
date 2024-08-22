class_name CutsceneSearchFlags
## Set of flags defining search behavior for career cutscenes.
##
## Career cutscenes are organized hierarchically. Depending on the use case, we sometimes only want the earliest
## available cutscenes, or all available cutscenes, or we want to exclude cutscenes the player's seen before. This
## class stores flags describing these different kinds of searches.

## Set of chat keys for cutscenes to exclude from the search. This may include leaf nodes and branch nodes. If
## omitted, no chat keys will be excluded.
##
## key: (String) chat key to exclude from the search
## value: (bool) true
var excluded_chat_keys := {}

## If true, indicates that all numeric children should be included, instead of just including the lowest-numbered one.
var include_all_numeric_children := false

## The maximum numbered chat key which should be returned; for example, setting a value of '99' will exclude post-boss
## and post-epilogue cutscenes
var max_chat_key: int = 999999

func exclude_chat_key(chat_key: String) -> void:
	excluded_chat_keys[chat_key] = true
