class_name CutsceneSearchFlags
## A set of flags defining search behavior for career cutscenes.
##
## Career cutscenes are organized hierarchically. Depending on the use case, we sometimes only want the earliest
## available cutscenes, or all available cutscenes, or we want to exclude cutscenes the player's seen before. This
## class stores flags describing these different kinds of searches.

## A set of chat keys for cutscenes to exclude from the search. This may include leaf nodes and branch nodes. If
## omitted, no chat keys will be excluded.
##
## key: (String) a chat key to exclude from the search
## value: true
var excluded_chat_keys := {}

## If true, indicates that all numeric children should be included, instead of just including the lowest-numbered one.
var include_all_numeric_children := false

func exclude_chat_key(chat_key: String) -> void:
	excluded_chat_keys[chat_key] = true
