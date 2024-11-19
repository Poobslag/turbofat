extends Label
## Shows a hint on career mode's map screen.

## Fixed seed to shuffle the hints in a reliable order, so we can ensure all hints are given eventually
const SEED := 452866638

onready var _accent := $Accent

func _ready() -> void:
	var hints := _hints()
	Utils.seeded_shuffle(hints, SEED)
	var hint_index := _hint_index() % hints.size()
	text = tr("Hint: %s" % [hints[hint_index]])
	_accent.refresh()


## Returns a list of hints the player can be shown.
##
## This list changes as the player makes it further in the game. Experts are shown hints about advanced techniques
## which are not shown to beginners.
##
## Returns:
## 	A list of String hints to choose between.
func _hints() -> Array:
	var result := []
	
	# Essential hints to help the player understand career mode or get accustomed to the game
	result.append(tr("Earning more money in a level moves you further on the map."))
	result.append(tr("Adventure mode ends after six levels. Make every level count!"))
	result.append(tr("Adventure mode ends if you lose all your lives. Try not to top out!"))
	result.append(tr("Sudden death levels are risky but reward you with an extra life."))
	result.append(tr("Struggling? Enable a hold piece or slow things down in the Difficulty menu!"))
	result.append(tr("Looking for line pieces? They're in the Difficulty menu... if you really need them!"))
	var region := PlayerData.career.current_region()
	if region.boss_level and not PlayerData.career.is_region_finished(region) \
			and not PlayerData.career.is_boss_level():
		result.append(tr("The boss level is near! Can you reach it in time?"))
	
	# Basic hints to remind the player of rules they might forget
	if PlayerData.career.best_distance_travelled >= 20:
		result.append(tr("Tap down to squeeze pieces through tight spaces!"))
		result.append(tr("Practice tricky levels in Training Mode!"))
		if PlayerData.career.level_choice_count() > 1:
			result.append(tr("The leftmost level is further from the goal. Choose wisely!"))
		result.append(tr("Make a snack box by arranging a pentomino and a tetromino into a square!"))
		result.append(tr("Make a cake box by arranging 3 pieces into a rectangle!"))
		result.append(tr("Two different same-colored pieces can always make a square!"))
		result.append(tr("Keep clearing lines and making boxes to build a big combo!"))
		result.append(tr("Making boxes extends your combo. Keep your combo alive!"))
		result.append(tr("Clear lines to keep your combo going and earn tons of money!"))
	
	# Advanced hints for expert players
	if PlayerData.career.best_distance_travelled >= 40:
		result.append(tr("Snack boxes score 5 points per line, but cake boxes score 10. Make those cakes!"))
		result.append(tr("Combos can earn up to 20 bonus points per line. Build those combos!"))
		result.append(tr("Hold left or right as the next piece appears to move it instantly!"))
		result.append(tr("Hold a rotate key as the next piece appears to spin it instantly!"))
		result.append(tr("Hold both rotate keys as the next piece appears to flip it instantly!"))
		result.append(tr("Press both rotate keys to flip a piece!"))
		result.append(tr("Hold up as the next piece appears to hard-drop it instantly!"))
		result.append(tr("Enable 'Soft Drop Lock Cancel' in Settings for some advanced piece finesse!"))
	
	return result


## Returns the hint index to display.
##
## We don't display random hints, we cycle through the hints in a pseudo-random order to ensure they're each shown in
## sequence.
##
## Returns:
## 	The index of the hint to display. This may be larger than the number of hints, and should be wrapped.
func _hint_index() -> int:
	return PlayerData.career.day + PlayerData.career.hours_passed
