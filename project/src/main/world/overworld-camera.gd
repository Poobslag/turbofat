extends Camera2D
## Overworld camera. Follows the main character and zooms in during conversations.

## how far from the camera center the player needs to be before the camera zooms out
const AUTO_ZOOM_OUT_DISTANCE := 100.0

## amount of empty space around characters
const CAMERA_BOUNDARY := 160

## duration of sweeping pan/zoom during cutscenes and conversations
const ZOOM_DURATION := 1.8

## speed of pan/zoom adjustments when zoomed in or out
const LERP_WEIGHT_NEAR := 0.05
const LERP_WEIGHT_FAR := 0.10

## zoom amount when zoomed in or out
const ZOOM_AMOUNT_NEAR := Vector2(0.5, 0.5)
const ZOOM_AMOUNT_FAR := Vector2(1.0, 1.0)

## 'true' if the camera should currently be zoomed in for a conversation
var close_up: bool setget set_close_up

onready var _overworld_ui: OverworldUi = Global.get_overworld_ui()

onready var _project_resolution := Vector2(ProjectSettings.get_setting("display/window/size/width"), \
		ProjectSettings.get_setting("display/window/size/height"))

onready var _tween: Tween = $Tween

func _ready() -> void:
	_overworld_ui.connect("chat_started", self, "_on_OverworldUi_chat_started")
	_overworld_ui.connect("chat_ended", self, "_on_OverworldUi_chat_ended")
	_overworld_ui.connect("visible_chatters_changed", self, "_on_OverworldUi_visible_chatters_changed")


func _process(_delta: float) -> void:
	if not ChattableManager.player:
		# The overworld camera follows the player. If there is no player, we have nothing to follow
		return
	
	if _tween.is_active():
		return
	
	var new_zoom := _calculate_zoom()
	zoom = lerp(zoom, new_zoom, LERP_WEIGHT_NEAR if close_up else LERP_WEIGHT_FAR)

	var new_position := _calculate_position()
	position = lerp(position, new_position, LERP_WEIGHT_NEAR if close_up else LERP_WEIGHT_FAR)


func set_close_up(new_close_up: bool) -> void:
	if close_up == new_close_up:
		# don't launch tween if the value is the same
		return
	
	close_up = new_close_up
	_tween_camera_to_chatters()


## Returns a rectangle representing the area which should be captured by the camera.
func _calculate_camera_bounding_box() -> Rect2:
	return _overworld_ui.get_chatter_bounding_box().grow(CAMERA_BOUNDARY)


## Returns a number in the range [0.0, 1.0] corresponding the fattest creature in the cutscene.
##
## A value of 0.0 means all the characters are thin. A value of 1.0 means at least one character is very fat. This
## value is used in making camera adjustments.
func _max_fatness_weight() -> float:
	var max_visual_fatness := 1.0
	for chatter in _overworld_ui.chatters:
		if chatter is Creature:
			max_visual_fatness = max(max_visual_fatness, chatter.get_visual_fatness())
	return inverse_lerp(1.0, 10.0, clamp(max_visual_fatness, 1.0, 10.0))


## Calculate the desired camera position based on the chatting creatures.
##
## This method does not update the camera's zoom value. It returns a value which can be used in a lerp or tween.
func _calculate_position() -> Vector2:
	if not ChattableManager.player:
		return position
	if not close_up:
		return ChattableManager.player.position
	
	var camera_bounding_box := _calculate_camera_bounding_box()
	var new_position := camera_bounding_box.position + camera_bounding_box.size * 0.5
	
	# Adjust the cutscene camera so the creature's faces are visible. We move
	# it down slightly for skinny creatures, otherwise they're hidden by dialog
	# bubbles. We move it up for exceptionally fat creatures, otherwise their
	# heads are out of frame.
	new_position.y += camera_bounding_box.size.y * lerp(0.1, -0.3, _max_fatness_weight())
	return new_position


## Calculate the desired camera zoom based on the chatting creatures.
##
## This method does not update the camera's zoom value. It returns a value which can be used in a lerp or tween.
func _calculate_zoom() -> Vector2:
	if not close_up:
		return ZOOM_AMOUNT_FAR
	
	var camera_bounding_box := _calculate_camera_bounding_box()
	var new_zoom := Vector2.ZERO
	new_zoom.x = max(camera_bounding_box.size.x / _project_resolution.x, \
			camera_bounding_box.size.y / _project_resolution.y)
	new_zoom.x = clamp(new_zoom.x, ZOOM_AMOUNT_NEAR.x, ZOOM_AMOUNT_FAR.x)
	
	# If any exceptionally fat creatures are in frame, we keep the camera zoomed out.
	new_zoom.x = max(new_zoom.x, lerp(ZOOM_AMOUNT_NEAR.x, ZOOM_AMOUNT_FAR.x, _max_fatness_weight()))
	
	new_zoom.y = new_zoom.x
	return new_zoom


## Launches a new tween, panning and zooming the camera to the current chat participants.
##
## This overwrites any old pan/zoom tween.
func _tween_camera_to_chatters() -> void:
	_tween.remove_all()
	var new_zoom := _calculate_zoom()
	var new_position := _calculate_position()
	
	_tween.interpolate_property(self, "zoom", zoom, new_zoom,
			ZOOM_DURATION, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	
	if not close_up:
		# camera will follow the player; the tween should track the player's position
		_tween.follow_property(self, "position", position,
				ChattableManager.player, "position",
				ZOOM_DURATION, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	else:
		_tween.interpolate_property(self, "position", position,
				new_position,
				ZOOM_DURATION, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	_tween.start()


func _on_OverworldUi_chat_started() -> void:
	if not _overworld_ui.is_drive_by_chat():
		set_close_up(true)


func _on_OverworldUi_chat_ended() -> void:
	set_close_up(false)


## Launches a pan/zoom tween when creatures exit or enter the cutscene.
##
## This method might get called multiple times in rapid succession, or possibly even in the same frame.
func _on_OverworldUi_visible_chatters_changed() -> void:
	_tween_camera_to_chatters()
