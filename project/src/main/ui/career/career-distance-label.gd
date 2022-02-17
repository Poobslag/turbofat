extends Control
## Shows the distance in the career mode status bar.
##
## This includes a text label like '16 (+3)' and a static icon.

export (NodePath) var level_select_path: NodePath

onready var _label := $Label

## UI components for career mode's level select buttons
onready var _level_select: CareerLevelSelect = get_node(level_select_path)

func _ready() -> void:
	PlayerData.career.connect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	_refresh_label()


## Refreshes the label based on the player's current distance.
func _refresh_label() -> void:
	# Determine the currently selected distance penalty
	var focused_level_button_index := _level_select.focused_level_button_index()
	var distance_penalty: int = PlayerData.career.distance_penalties()[focused_level_button_index]
	
	# Display the distance travelled with the distance penalty applied
	var distance_earned_value := PlayerData.career.distance_earned - distance_penalty
	_label.text = StringUtils.comma_sep(distance_earned_value)
	
	if distance_earned_value > 0:
		# distance_earned is positive; prefix distance_option with a '+'
		_label.text += " (+%s)" % [StringUtils.comma_sep(distance_earned_value)]
	elif distance_earned_value < 0:
		# distance_earned is negative; no prefix is necessary, distance_option already includes a '-'
		_label.text += " (%s)" % [StringUtils.comma_sep(distance_earned_value)]
	else:
		# distance_earned is zero; don't show it
		pass


## Updates the distance label after the player selects a level.
##
## After the player selects a label, the distance penalty is applied to the player's distance travelled. This method
## updates the label's text with the player's raw distance travelled with no penalty applied. This prevents a bug
## where we temporarily display the distance with the penalty applied twice.
func suppress_distance_penalty() -> void:
	# Display the distance travelled with the distance penalty applied
	_label.text = StringUtils.comma_sep(PlayerData.career.distance_travelled)


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_label()


func _on_LevelSelect_level_button_focused(_button_index: int) -> void:
	_refresh_label()
