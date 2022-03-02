class_name ChatIcons
extends Node2D
## Creates and initializes chat icons for all chattables in the scene tree.

export (PackedScene) var ChatIconScene: PackedScene

## key: Node2D in the 'chattable' node group
## value: ChatIcon instance
var _chat_icon_by_chattable: Dictionary

func _ready() -> void:
	var overworld_ui: OverworldUi = Global.get_overworld_ui()
	overworld_ui.connect("chat_cached", self, "_on_OverworldUi_chat_cached")
	
	recreate_all_icons()

## create chat icons for all chattables
func recreate_all_icons() -> void:
	# assign chat_bubble_type for all creatures based on ChatLibrary
	for creature in get_tree().get_nodes_in_group("creatures"):
		var chat_bubble_type: int = ChatLibrary.chat_icon_for_creature(creature)
		creature.set_meta("chat_bubble_type", chat_bubble_type)
	
	# remove existing chat icons
	for child in get_children():
		child.queue_free()
		remove_child(child)
	
	# create replacement chat icons
	for chattable in get_tree().get_nodes_in_group("chattables"):
		create_icon(chattable)


func create_icon(chattable: Node) -> void:
	var chat_icon: ChatIcon = ChatIconScene.instance()
	add_child(chat_icon)
	chat_icon.initialize(chattable)
	_chat_icon_by_chattable[chattable] = chat_icon
	chattable.connect("tree_exited", self, "_on_Chattable_tree_exited", [chat_icon])


func _on_Chattable_tree_exited(chat_icon: ChatIcon) -> void:
	chat_icon.queue_free()


## After the player talks to a creature we change their speech bubble.
##
## A repeat chat is treated as a 'drive by chat' so it's given the drive by speech bubble.
func _on_OverworldUi_chat_cached(focused_chattable: Node2D) -> void:
	var chat_icon: ChatIcon = _chat_icon_by_chattable.get(focused_chattable, null)
	if chat_icon and chat_icon.bubble_type == ChatIcon.SPEECH:
		yield(chat_icon, "vanish_finished")
		chat_icon.bubble_type = ChatIcon.FILLER
