extends Control
## Shows the distance in the career mode status bar.
##
## This includes a text label like '16 (+3)' and a static icon.

onready var _label := $Label

func _ready() -> void:
	PlayerData.career.connect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	_refresh_label()


## Refreshes the label based on the player's current distance.
func _refresh_label() -> void:
	_label.text = StringUtils.comma_sep(PlayerData.career.distance_travelled)
	
	# append the distance_earned
	if PlayerData.career.distance_earned > 0:
		# distance_earned is positive; prefix it with a '+'
		_label.text += " (+%s)" % [StringUtils.comma_sep(PlayerData.career.distance_earned)]
	elif PlayerData.career.distance_earned < 0:
		# distance_earned is negative; no prefix is necessary, it already includes a '-'
		_label.text += " (%s)" % [StringUtils.comma_sep(PlayerData.career.distance_earned)]
	else:
		# distance earned is zero; don't show it
		pass


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_label()
