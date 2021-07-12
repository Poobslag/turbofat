extends OverworldObstacle
"""
The 'Buttercup Cafe' sign which appears on the overworld.
"""

func _ready() -> void:
	if PlayerData.level_history.is_level_finished("marsh/pulling_for_everyone"):
		# if the trees have been chopped down, the sign is readable
		set_chat_path(ChatHistory.path_from_history_key("chat/buttercup_sign"))
	elif PlayerData.chat_history.is_chat_finished("chat/meet_the_competition"):
		# if the player's already seen the 'meet the competition' cutscene, we only provide a short description
		set_chat_path(ChatHistory.path_from_history_key("chat/butt_up_sign"))
	else:
		# if the player hasn't seen the 'meet the competition' cutscene, we play a cutscene
		set_chat_path(ChatHistory.path_from_history_key("chat/meet_the_competition"))
		set_meta("chat_bubble_type", ChatIcon.BubbleType.SPEECH)
