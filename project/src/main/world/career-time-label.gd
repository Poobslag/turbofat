extends Control
## Shows the time in the career mode status bar.
##
## This includes a text label like '8:00 am' and a clock icon which changes.

## key: (int) corresonding to the number of levels the player has played
## value: (String) human-readable time of day
var TIME_OF_DAY_BY_HOURS := {
	0: tr("8:00 am"),
	1: tr("9:10 am"),
	2: tr("10:15 am"),
	3: tr("11:20 am"),
	4: tr("12:30 pm"),
	5: tr("1:40 pm"),
	6: tr("2:45 pm"),
	7: tr("3:50 pm"),
	8: tr("5:00 pm"),
}

func _ready() -> void:
	# update the label's text
	$Label.text = TIME_OF_DAY_BY_HOURS.get(PlayerData.career.hours_passed, "?:?? zm")
	if not TIME_OF_DAY_BY_HOURS.has(PlayerData.career.hours_passed):
		push_warning("TIME_OF_DAY_BY_HOURS has no entry for %s" % [PlayerData.career.hours_passed])
	
	# update the icon
	$Icon/IconSprite.frame = PlayerData.career.hours_passed
