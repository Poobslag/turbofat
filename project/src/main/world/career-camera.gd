extends Camera2D
## Career mode camera. Focuses on the area around the player, drifting slightly.

## amount of empty space around characters
const CAMERA_BOUNDARY := 240

## how fast the camera moves when being moved manually with a cheat code
const MANUAL_CAMERA_SPEED := 3000

## The camera drifts slightly. This field is used to calculate the drift amount
var _total_time := randf_range(0.0, 10.0)

## base zoom value before drift is applied
var _base_zoom := Vector2.ONE

## period for offset/zoom drift, in seconds
var offset_h_drift_period := 6.450 * randf_range(0.666, 1.333)
var offset_v_drift_period := 8.570 * randf_range(0.666, 1.333)
var zoom_drift_period := 15.020 * randf_range(0.666, 1.333)

## 'true' if the camera is being moved manually with a cheat code
var manual_mode := false

func _process(delta: float) -> void:
	_total_time += delta
	_apply_camera_drift()


func _physics_process(delta: float) -> void:
	if manual_mode:
		# if the camera is being moved manually with a cheat code, adjust its position
		var dir := Utils.ui_pressed_dir()
		if dir:
			position += dir * delta * MANUAL_CAMERA_SPEED


## Pans and zooms the camera to encompass the specified creatures
##
## Parameters:
## 	'creatures': List of creature instances to pan/zoom in on
func zoom_in_on_creatures(creatures: Array) -> void:
	if manual_mode:
		return
	
	# calculate the bounding box, including the camera boundary
	var bounding_box: Rect2 = _creature_bounding_box(creatures)
	bounding_box = bounding_box.grow(CAMERA_BOUNDARY)
	
	# calculate the camera position
	position = bounding_box.position + bounding_box.size * 0.5
	position.y -= bounding_box.size.y * 0.25
	
	# calculate the camera zoom
	_base_zoom.x = max(bounding_box.size.x / Global.window_size.x, bounding_box.size.y / Global.window_size.y)
	_base_zoom.x = clamp(_base_zoom.x, 0.1, 10.0)
	_base_zoom.y = _base_zoom.x
	
	# immediately apply camera drift to prevent the camera from snapping for one frame
	_apply_camera_drift()


## Pans and zooms the camera slightly
func _apply_camera_drift() -> void:
	drag_horizontal_offset = 0.01 * sin(_total_time * PI / offset_h_drift_period)
	drag_vertical_offset = 0.03 * sin(_total_time * PI / offset_v_drift_period)
	zoom = _base_zoom + _base_zoom * 0.01 * sin(_total_time * PI / zoom_drift_period)


## Calculates the minimal bounding box containing all of the specified creatures
##
## Parameters:
## 	'creatures': List of creature instances to calculate
func _creature_bounding_box(creatures: Array) -> Rect2:
	var bounding_box: Rect2
	
	# compute bounding box
	for creature in creatures:
		var chat_extents: Vector2 = creature.chat_extents if "chat_extents" in creature else Vector2.ZERO
		var chatter_box := Rect2(creature.position - chat_extents / 2, chat_extents)
		if bounding_box:
			bounding_box = bounding_box.merge(chatter_box)
		else:
			bounding_box = chatter_box
	
	return bounding_box
