class_name LevelSpeedAdjuster
## Adjusts a LevelSettings to use faster or slower piece speeds

## key: (String) speed id
## value: (Vector2) x/y coordinates for an entry in PieceSpeeds.speed_id_matrix
var _coordinates_by_speed := {}

## the settings to adjust
var settings: LevelSettings

func _init(init_settings: LevelSettings) -> void:
	settings = init_settings
	
	# initialize the _coordinates_by_speed matrix based on the entries in PieceSpeeds.speed_id_matrix
	for row in range(PieceSpeeds.speed_id_matrix.size()):
		for col in range(PieceSpeeds.speed_id_matrix[row].size()):
			_coordinates_by_speed[PieceSpeeds.speed_id_matrix[row][col]] = Vector2(col, row)


## Adjusts the piece speeds of our LevelSettings instance.
##
## We calculate the fastest speed of the LevelSettings instance, and compare it to the specified speed to determine
## whether we should speed up or slow down the level's piece speeds.
##
## When applying the piece speed change, we modify the initial speed as well as any 'speed up' events for levels which
## increase in difficulty.
##
## Passing in an empty speed results in no adjustment.
##
## Parameters:
## 	new_speed: The desired slowest speed id for the LevelSettings.
func adjust(new_speed: String) -> void:
	if not new_speed:
		# empty speed, do not adjust
		return
	if not _coordinates_by_speed.has(new_speed):
		push_warning("Unrecognized speed: '%s'" % [new_speed])
		return
	if not _coordinates_by_speed.has(settings.speed.get_start_speed()):
		push_warning("Unrecognized speed: '%s'" % [settings.speed.get_start_speed()])
		return
	
	var can_adjust := true
	var new_coord: Vector2 = _coordinates_by_speed[new_speed]
	var old_coord: Vector2 = _coordinates_by_speed[settings.speed.get_start_speed()]
	if new_coord.y != old_coord.y:
		can_adjust = false
	
	if can_adjust:
		# calculate adjustment
		var adjustment: int = new_coord.x - old_coord.x
		
		# adjust milestone speeds (including the start speed)
		for milestone in settings.speed.speed_ups:
			var new_milestone_speed := get_adjusted_speed(milestone.get_meta("speed"), adjustment)
			milestone.set_meta("speed", new_milestone_speed)


## Returns a new speed id which is faster/slower than the specified speed id.
##
## Parameters:
## 	'speed': A piece speed id which should be sped up or slowed down.
##
## 	'adjustment': If positive, the speed is increased. If negative, the speed is decreased.
##
## Returns:
## 	A new speed id which is faster/slower than the specified speed id.
func get_adjusted_speed(speed: String, adjustment: int) -> String:
	if not _coordinates_by_speed.has(speed):
		push_warning("Unrecognized speed: '%s'" % [speed])
		return speed
	
	var coord: Vector2 = _coordinates_by_speed[speed]
	coord.x = clamp(coord.x + adjustment, 0, PieceSpeeds.speed_id_matrix[coord.y].size() - 1)
	return PieceSpeeds.speed_id_matrix[coord.y][coord.x]
