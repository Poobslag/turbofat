## Advances the calendar and clock in career mode.

var career_data: CareerData

func _init(init_career_data: CareerData) -> void:
	career_data = init_career_data


## Advances the clock and advances the player the specified distance.
##
## Even if new_distance_earned is a large number, the player's travel distance can be limited in two scenarios:
##
## 1. If they just played a non-boss level, they cannot advance past a boss level they haven't cleared.
##
## 2. If they just played a boss level, they cannot advance without meeting its success criteria.
##
## Parameters:
## 	'new_distance_earned': The maximum distance the player will travel.
##
## 	'success': 'True' if the player met the success criteria for the current level.
func advance_clock(new_distance_earned: int, success: bool) -> void:
	career_data.distance_earned = new_distance_earned
	career_data.skipped_previous_level = false
	
	career_data.hours_passed += 1
	
	if career_data.is_boss_level():
		var boss_region: CareerRegion = career_data.current_region()
		if success:
			# if they pass a boss level, update max_distance_travelled to mark the region as cleared
			career_data.max_distance_travelled = boss_region.end + 1
		else:
			# if they fail a boss level, they lose 1-2 days worth of progress
			career_data.distance_earned = -int(max(boss_region.length * rand_range(0.125, 0.25), 2))
	
	if career_data.distance_earned > 0:
		# if they make forward progress, they also spend their banked steps
		career_data.distance_earned += career_data.banked_steps
		career_data.banked_steps = 0
	
	var unapplied_distance_earned := career_data.distance_earned
	while unapplied_distance_earned != 0:
		unapplied_distance_earned = _apply_distance_earned(unapplied_distance_earned)


## Apply some of the player's distance earned, either advancing the player or banking the steps for later.
##
## This only applies a small chunk of the player's distance earned, stopping at region boundaries. It should be called
## iteratively until it returns zero.
##
## Parameters:
## 	'unapplied_distance_earned': The amount of distance_earned which hasn't been applied to advance the player, or
## 		banked for later.
##
## Returns:
## 	The remaining amount of the player's distance earned, after applying some of it toward advancing the player or
## 		banking the steps for later.
func _apply_distance_earned(unapplied_distance_earned: int) -> int:
	var region: CareerRegion = career_data.current_region()
	var newly_banked_steps := 0
	var newly_travelled_distance := unapplied_distance_earned
	
	if not career_data.is_region_cleared(region) and region.intro_level \
			and not career_data.is_intro_level_finished(region):
		# The player can't advance further into this region, they haven't cleared its intro level. Move them to
		# the start of the region and forbid movement.
		newly_banked_steps = unapplied_distance_earned
	elif career_data.distance_travelled + unapplied_distance_earned >= region.end + 1:
		# The player is trying to cross into the next region
		var distance_to_next_region := region.end + 1 - career_data.distance_travelled
		if career_data.is_region_cleared(region):
			# The player can cross into the next region. Move them to the start of the next region and allow
			# movement.
			newly_travelled_distance = distance_to_next_region
		else:
			# The player can't cross into the next region, they haven't cleared the boss level. Move them to the end
			# of this region and forbid movement.
			newly_banked_steps = unapplied_distance_earned - distance_to_next_region + 1
	
	# if the player hit a wall, we bank their steps and don't move them as far this time
	career_data.banked_steps += newly_banked_steps
	newly_travelled_distance -= newly_banked_steps
	unapplied_distance_earned -= newly_banked_steps
	
	career_data.distance_travelled += newly_travelled_distance
	unapplied_distance_earned -= newly_travelled_distance
	
	return unapplied_distance_earned


## Advances the calendar day and resets all daily variables.
func advance_calendar() -> void:
	career_data.prev_daily_earnings.push_front(career_data.daily_earnings)
	if career_data.prev_daily_earnings.size() > CareerData.MAX_DAILY_HISTORY:
		career_data.prev_daily_earnings = career_data.prev_daily_earnings.slice(0, CareerData.MAX_DAILY_HISTORY - 1)
	
	career_data.max_distance_travelled = max(career_data.max_distance_travelled, career_data.distance_travelled)
	career_data.prev_distance_travelled.push_front(career_data.distance_travelled)
	if career_data.prev_distance_travelled.size() > CareerData.MAX_DAILY_HISTORY:
		career_data.prev_distance_travelled = career_data.prev_distance_travelled.slice(0, CareerData.MAX_DAILY_HISTORY - 1)
	
	career_data.banked_steps = 0
	career_data.distance_earned = 0
	career_data.hours_passed = 0
	career_data.daily_customers = 0
	career_data.daily_earnings = 0
	career_data.daily_level_ids.clear()
	career_data.daily_seconds_played = 0.0
	career_data.daily_steps = 0
	career_data.day = min(career_data.day + 1, CareerData.MAX_DAY)
	
	# Put the player at the start of their current region and trigger the 'distance_travelled_changed' signal
	career_data.distance_travelled = career_data.current_region().start
