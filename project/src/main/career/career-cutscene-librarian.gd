class_name CareerCutsceneLibrarian
## Looks up which cutscenes should play for specific levels in career mode.

## Returns an intro, boss, or interlude chat key pair for the current region.
##
## Parameters:
## 	'career_level': (Optional) Level whose chat key pair should be returned. This is specifically used for the
## 		case where the player is viewing an interlude, and we want the interlude to feature the same creatures
## 		shown in the level. For most cases, this parameter can be omitted.
func chat_key_pair(career_level: CareerLevel) -> ChatKeyPair:
	var result: ChatKeyPair = ChatKeyPair.new()

	# if it's an intro level, return any intro level cutscenes
	if result.empty() and PlayerData.career.is_intro_level():
		result = _intro_chat_key_pair()
	
	# if it's a boss level, return any boss level cutscenes
	if result.empty() and PlayerData.career.is_boss_level():
		result = _boss_chat_key_pair()
	
	# if it's the 3rd or 6th level, return any interludes
	if result.empty() and PlayerData.career.hours_passed in PlayerData.career.career_interlude_hours() \
			and not PlayerData.career.skipped_previous_level:
		result = _interlude_chat_key_pair(career_level)
	
	return result


## Returns a ChatKeyPair with any unplayed intro cutscenes for the current region.
##
## If the region does not have intro cutscenes or the player has already viewed them, this returns an empty
## ChatKeyPair.
func _intro_chat_key_pair() -> ChatKeyPair:
	var result: ChatKeyPair = ChatKeyPair.new()
	
	var region := PlayerData.career.current_region()
	var preroll_key := region.get_intro_level_preroll_chat_key()
	var postroll_key := region.get_intro_level_postroll_chat_key()
	if ChatLibrary.chat_exists(preroll_key) and not PlayerData.chat_history.is_chat_finished(preroll_key):
		result.preroll = preroll_key
	if ChatLibrary.chat_exists(postroll_key) and not PlayerData.chat_history.is_chat_finished(postroll_key):
		result.postroll = postroll_key
	if not result.empty():
		result.type = ChatKeyPair.INTRO_LEVEL
		
	return result


## Returns a ChatKeyPair with any unplayed boss cutscenes for the current region.
##
## If the region does not have boss  cutscenes or the player has already viewed them, this returns an empty
## ChatKeyPair.
func _boss_chat_key_pair() -> ChatKeyPair:
	var result: ChatKeyPair = ChatKeyPair.new()
	
	var region := PlayerData.career.current_region()
	var preroll_key := region.get_boss_level_preroll_chat_key()
	var postroll_key := region.get_boss_level_postroll_chat_key()
	if ChatLibrary.chat_exists(preroll_key) and not PlayerData.chat_history.is_chat_finished(preroll_key):
		result.preroll = preroll_key
	if ChatLibrary.chat_exists(postroll_key) and not PlayerData.chat_history.is_chat_finished(postroll_key):
		result.postroll = postroll_key
	if not result.empty():
		result.type = ChatKeyPair.BOSS_LEVEL
	
	return result


## Returns a ChatKeyPair with an arbitrary interlude cutscene for the current region.
##
## Parameters:
## 	'career_level': (Optional) Level whose chat key pair should be returned. This is specifically used for the
## 		case where the player is viewing an interlude, and we want the interlude to feature the same creatures
## 		shown in the level. For other cases, this parameter can be null.
func _interlude_chat_key_pair(career_level: CareerLevel) -> ChatKeyPair:
	var result: ChatKeyPair = ChatKeyPair.new()
	
	var region := PlayerData.career.current_region()
	
	# calculate the chef id/customer ids/observer id
	var chef_id: String
	var customer_id: String
	var observer_id: String
	if career_level:
		if career_level.chef_id or career_level.customer_ids or career_level.observer_id:
			chef_id = career_level.chef_id
			customer_id = career_level.customer_ids[0] if career_level.customer_ids else ""
			observer_id = career_level.observer_id
		else:
			customer_id = CareerLevel.NONQUIRKY_CUSTOMER
	
	if region.cutscene_path:
		# find a region-specific cutscene
		result = CareerCutsceneLibrary.next_interlude_chat_key_pair(
				[region.cutscene_path], chef_id, customer_id, observer_id)
	if result.empty():
		# no region-specific cutscene available; find a general cutscene
		result = CareerCutsceneLibrary.next_interlude_chat_key_pair(
				[CareerCutsceneLibrary.general_chat_key_root], chef_id, customer_id, observer_id)
	if not result.empty():
		result.type = ChatKeyPair.INTERLUDE
	
	return result
