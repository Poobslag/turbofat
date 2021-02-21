extends Camera2D
"""
Overworld camera. Follows the main character and zooms in during conversations.
"""

# how far from the camera center the player needs to be before the camera zooms out
const AUTO_ZOOM_OUT_DISTANCE := 100.0

# amount of empty space around characters
const CAMERA_BOUNDARY := 160

# amount of time spent zooming in and out
const ZOOM_DURATION := 1.0

# maximum zoom amount for conversations
const ZOOM_CLOSE_UP := Vector2(0.5, 0.5)

# zoom amount when running around
const ZOOM_DEFAULT := Vector2(1.0, 1.0)

# 'true' if the camera should currently be zoomed in for a conversation
var close_up: bool setget set_close_up

# 0.0 = zoomed out, 1.0 = zoomed in
var close_up_pct := 0.0

# the position to zoom in to. the midpoint of the smallest rectangle containing all chatters
var close_up_position: Vector2
var close_up_bounding_box: Rect2

# zoom amount for the current conversation; we don't zoom in as much if the creature is fat
var zoom_close_up := ZOOM_CLOSE_UP

onready var _overworld_ui: OverworldUi = Global.get_overworld_ui()

onready var _project_resolution := Vector2(ProjectSettings.get_setting("display/window/size/width"), \
		ProjectSettings.get_setting("display/window/size/height"))

func _ready() -> void:
	_overworld_ui.connect("chat_started", self, "_on_OverworldUi_chat_started")
	_overworld_ui.connect("chat_ended", self, "_on_OverworldUi_chat_ended")


func _process(_delta: float) -> void:
	if not ChattableManager.player:
		# The overworld camera follows the player. If there is no player, we have nothing to follow
		return
	
	# calculate the position to zoom in to
	if _overworld_ui.chatters:
		var max_visual_fatness := 1.0
		for chatter in _overworld_ui.chatters:
			if chatter is Creature:
				max_visual_fatness = max(max_visual_fatness, chatter.get_visual_fatness())
		
		var new_close_up_bounding_box := _overworld_ui.get_chatter_bounding_box().grow(CAMERA_BOUNDARY)
		if new_close_up_bounding_box != close_up_bounding_box:
			close_up_bounding_box = new_close_up_bounding_box
			close_up_position = close_up_bounding_box.position + close_up_bounding_box.size * 0.5
			
			zoom_close_up.x = max(close_up_bounding_box.size.x / _project_resolution.x, \
					close_up_bounding_box.size.y / _project_resolution.y)
			zoom_close_up.x = clamp(zoom_close_up.x, 0.5, 1.0)
			zoom_close_up.y = zoom_close_up.x

	zoom = lerp(ZOOM_DEFAULT, zoom_close_up, close_up_pct)
	position = lerp(ChattableManager.player.position, close_up_position, close_up_pct)
	
	if not _overworld_ui.cutscene and close_up \
			and ChattableManager.player.position.distance_to(close_up_position) > AUTO_ZOOM_OUT_DISTANCE:
		 # player left the chat area; zoom back out
		set_close_up(false)


func set_close_up(new_close_up: bool) -> void:
	if close_up == new_close_up:
		# don't launch tween if the value is the same
		return
	
	close_up = new_close_up
	$Tween.remove_all()
	$Tween.interpolate_property(self, "close_up_pct", close_up_pct, 1.0 if close_up else 0.0,
			ZOOM_DURATION, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_OverworldUi_chat_started() -> void:
	if not _overworld_ui.is_drive_by_chat():
		set_close_up(true)


func _on_OverworldUi_chat_ended() -> void:
	set_close_up(false)
