extends HBoxContainer
## UI elements for displaying and editing the player's distance in career mode.

## Buttons for decreasing/increasing the player's distance
onready var _down_button: Button = $Down
onready var _up_button: Button = $Up

func _ready() -> void:
	PlayerData.career.connect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	_refresh_buttons()


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
	
	var curr_region: CareerRegion = PlayerData.career.current_region()
	var next_region: CareerRegion = PlayerData.career.next_region()
	var prev_region: CareerRegion = PlayerData.career.prev_region()
	
	if next_region == curr_region or next_region.distance > PlayerData.career.max_distance_travelled:
		# disable the up button; the player is at their maximum distance
		_up_button.disabled = true
	
	if prev_region == curr_region:
		# disable the down button; the player is at their minimum distance
		_down_button.disabled = true
	
	# hide ourselves from view if both buttons are disabled
	visible = false if _down_button.disabled and _up_button.disabled else true


func _on_Down_pressed() -> void:
	# set our distance to the start of the previous region
	var prev_region: CareerRegion = PlayerData.career.prev_region()
	PlayerData.career.distance_travelled = prev_region.distance


func _on_Up_pressed() -> void:
	# set our distance to the start of the next region
	var next_region: CareerRegion = PlayerData.career.next_region()
	PlayerData.career.distance_travelled = next_region.distance


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_buttons()
