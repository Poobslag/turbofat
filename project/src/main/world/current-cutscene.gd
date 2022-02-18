extends Node
## Stores information about the current cutscene.

## Emitted after a scene is launched to play a cutscene.
##
## Parameters:
## 	'chat_key': A chat key such as 'chat/marsh_prologue'
signal cutscene_played(chat_key)

## The chat key for the cutscene currently being launched or played
var chat_key: String

## The chat tree for the cutscene currently being launched or played
var chat_tree: ChatTree

## Stores the launched cutscene data, so the cutscene can be played later.
##
## Parameters:
## 	'new_chat_key': The chat key for the newly launched cutscene.
func set_launched_cutscene(new_chat_key: String) -> void:
	chat_key = new_chat_key
	
	if chat_key:
		chat_tree = ChatLibrary.chat_tree_for_key(chat_key)
	else:
		chat_tree = null


## Launches an overworld scene with the previously specified 'launched cutscene' settings.
##
## The new scene is appended to the end of the breadcrumb trail.
func push_cutscene_trail() -> void:
	SceneTransition.push_trail(Global.SCENE_CUTSCENE)
	emit_signal("cutscene_played", chat_key)


## Launches an overworld scene with the previously specified 'launched cutscene' settings.
##
## The new scene replaces the current scene in the the breadcrumb trail.
func replace_cutscene_trail() -> void:
	SceneTransition.replace_trail(Global.SCENE_CUTSCENE)
	emit_signal("cutscene_played", chat_key)


## Unsets all of the 'launched cutscene' data.
##
## This ensures the overworld will not try to play the same cutscene twice.
func clear_launched_cutscene() -> void:
	set_launched_cutscene("")
