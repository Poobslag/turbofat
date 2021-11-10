extends OverworldUi
## UI elements for the overworld walking scene.

## The delay between the speaker and the listener when they start walking. The speaking creature starts walking first,
## then the other creature starts walking after a short pause.
const WALK_REACTION_DELAY := 0.4

## Extends the parent class's _apply_chat_event_meta() method to add support for the 'start_walking' and 'stop_walking'
## metadata items.
func _apply_chat_event_meta(chat_event: ChatEvent, meta_item: String) -> void:
	._apply_chat_event_meta(chat_event, meta_item)
	match(meta_item):
		"stop_walking":
			for creature in get_tree().get_nodes_in_group("creatures"):
				if not creature is WalkingBuddy:
					continue
				var walking_buddy: WalkingBuddy = creature
				var delay := WALK_REACTION_DELAY
				if creature.creature_id == chat_event.who:
					delay = 0.0
				walking_buddy.stop_walking(delay)
		"start_walking":
			for creature in get_tree().get_nodes_in_group("creatures"):
				if not creature is WalkingBuddy:
					continue
				var walking_buddy: WalkingBuddy = creature
				var delay := WALK_REACTION_DELAY
				if creature.creature_id == chat_event.who:
					delay = 0.0
				walking_buddy.start_walking(delay)
