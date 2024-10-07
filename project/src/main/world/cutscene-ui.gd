extends OverworldUi
## UI elements for overworld cutscenes.

## The delay between the speaker and the listener when they start walking. The speaking creature starts walking first,
## then the other creature starts walking after a short pause.
const WALK_REACTION_DELAY := 0.4

## Extends the parent class's _apply_chat_event_meta() method to add support for the 'start_walking' and 'stop_walking'
## metadata items.
func _apply_chat_event_meta(chat_event: ChatEvent, meta_item: String) -> void:
	._apply_chat_event_meta(chat_event, meta_item)
	match(meta_item):
		"stop_walking":
			for creature in _overworld_environment.get_creatures():
				if not creature is WalkingBuddy:
					continue
				var walking_buddy: WalkingBuddy = creature
				var delay := WALK_REACTION_DELAY
				if creature.creature_id == chat_event.who:
					delay = 0.0
				walking_buddy.stop_walking(delay)
		"start_walking":
			for creature in _overworld_environment.get_creatures():
				if not creature is WalkingBuddy:
					continue
				var walking_buddy: WalkingBuddy = creature
				var delay := WALK_REACTION_DELAY
				if creature.creature_id == chat_event.who:
					delay = 0.0
				walking_buddy.start_walking(delay)


func _on_SettingsMenu_quit_pressed() -> void:
	PlayerData.cutscene_queue.reset()
	
	if Breadcrumb.trail.size() >= 2 and Breadcrumb.trail[1] == Global.SCENE_CAREER_MAP:
		# When quitting a career mode cutscene, quit career mode entirely
		Breadcrumb.initialize_trail()
		SceneTransition.push_trail(Global.SCENE_MAIN_MENU)
	else:
		SceneTransition.pop_trail()


func _on_SettingsMenu_hide() -> void:
	if not _chat_ui:
		return
	
	_chat_ui.grab_focus()
