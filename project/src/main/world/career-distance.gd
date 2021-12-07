extends HBoxContainer
## UI elements for displaying and editing the player's distance in career mode.

## Buttons for decreasing/increasing the player's distance
onready var _down_button: Button = $Down
onready var _up_button: Button = $Up

## Label for showing the player's current distance
onready var _label: Label = $Label

func _ready() -> void:
	PlayerData.career.connect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	_refresh_distance()


## Refreshes the labels and buttons based on the player's current distance.
func _refresh_distance() -> void:
	_refresh_buttons()
	_refresh_label()


## Refreshes the step count label based on the player's current distance.
func _refresh_label() -> void:
	if PlayerData.career.distance_earned > 0:
		_label.text = "%s (+%s)" % [StringUtils.comma_sep(PlayerData.career.distance_travelled),
				StringUtils.comma_sep(PlayerData.career.distance_earned)]
	elif PlayerData.career.distance_earned < 0:
		_label.text = "%s (%s)" % [StringUtils.comma_sep(PlayerData.career.distance_travelled),
				StringUtils.comma_sep(PlayerData.career.distance_earned)]
	else:
		_label.text = StringUtils.comma_sep(PlayerData.career.distance_travelled)


## Refreshes the buttons based on the player's current distance.
##
## Buttons are disabled and hidden if the player can't decrease/increase their distance, either because they're at the
## limits or because they're in the middle of a career session.
func _refresh_buttons() -> void:
	_down_button.disabled = false
	_up_button.disabled = false
	
	if PlayerData.career.hours_passed > 0:
		# disable the buttons; the player is in the middle of a career session
		_down_button.disabled = true
		_up_button.disabled = true
	
	var curr_region: CareerRegion = CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	var next_region: CareerRegion = CareerLevelLibrary.region_for_distance(curr_region.distance + curr_region.length)
	var prev_region: CareerRegion = CareerLevelLibrary.region_for_distance(curr_region.distance - 1)
	
	if next_region == curr_region or next_region.distance > PlayerData.career.max_distance_travelled:
		# disable the up button; the player is at their maximum distance
		_up_button.disabled = true
	
	if prev_region == curr_region:
		# disable the down button; the player is at their minimum distance
		_down_button.disabled = true
	
	# Hide disabled buttons from view with the modulate property. We don't set visible to false, because we still want
	# them taking up space in the UI.
	for button in [_down_button, _up_button]:
		button.modulate = Color.transparent if button.disabled else Color.white
		button.focus_mode = Control.FOCUS_NONE if button.disabled else Control.FOCUS_ALL


func _on_Down_pressed() -> void:
	# set our distance to the start of the previous region
	var curr_region: CareerRegion = CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	var prev_region: CareerRegion = CareerLevelLibrary.region_for_distance(curr_region.distance - 1)
	PlayerData.career.distance_travelled = prev_region.distance


func _on_Up_pressed() -> void:
	# set our distance to the start of the next region
	var curr_region: CareerRegion = CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	var next_region: CareerRegion = CareerLevelLibrary.region_for_distance(curr_region.distance + curr_region.length)
	PlayerData.career.distance_travelled = next_region.distance


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_distance()
