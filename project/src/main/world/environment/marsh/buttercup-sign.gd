extends OverworldObstacle
## The 'Buttercup Cafe' sign which appears on the overworld.

## Defining chat extents makes this sign easier to interact with when obstructed
onready var chat_extents: Vector2 = $CollisionShape2D.shape.extents

func _ready() -> void:
	if PlayerData.level_history.is_level_finished("marsh/goodbye_everyone"):
		# if the Buttercup Cafe is closed there is a different message
		set_chat_key("chat/buttercup_sign_closed")
	elif PlayerData.level_history.is_level_finished("marsh/pulling_for_everyone"):
		# if the trees have been chopped down, the sign is readable
		set_chat_key("chat/buttercup_sign")
	elif PlayerData.chat_history.is_chat_finished("chat/meet_the_competition"):
		# if the player's already seen the 'meet the competition' cutscene, we only provide a short description
		set_chat_key("chat/butt_up_sign")
	else:
		# if the player hasn't seen the 'meet the competition' cutscene, we play a cutscene
		set_chat_key("chat/meet_the_competition")
		set_meta("chat_bubble_type", ChatIcon.BubbleType.SPEECH)
