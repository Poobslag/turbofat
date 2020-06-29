extends Camera2D
"""
Overworld camera. Follows the main character and zooms in during conversations.
"""

const ZOOM_DURATION := 1.0

# zoom amount for conversations
const ZOOM_CLOSE_UP := Vector2(0.5, 0.5)

# zoom amount when running around
const ZOOM_DEFAULT := Vector2(1.0, 1.0)

# how far from the camera center spira needs to be before the camera zooms out
const AUTO_ZOOM_OUT_DISTANCE := 100.0

export (NodePath) var spira_path: NodePath
export (NodePath) var overworld_ui_path: NodePath

# 'true' if the camera should currently be zoomed in for a conversation
var close_up: bool setget set_close_up

# 0.0 = zoomed out, 1.0 = zoomed in
var close_up_pct := 0.0

# the position to zoom in to. the midpoint of the smallest rectangle containing all chatters
var close_up_position: Vector2

onready var _spira: Spira = get_node(spira_path)
onready var _overworld_ui: OverworldUi = get_node(overworld_ui_path)

func _process(_delta: float) -> void:
	# calculate the position to zoom in to
	var bounding_box := Rect2(_spira.position, Vector2(0, 0))
	for chatter in _overworld_ui.chatters:
		bounding_box = bounding_box.expand(chatter.position)
	close_up_position = bounding_box.position + bounding_box.size * 0.5
	
	position = lerp(_spira.position, close_up_position, close_up_pct)
	zoom = lerp(ZOOM_DEFAULT, ZOOM_CLOSE_UP, close_up_pct)
	
	if close_up and _spira.position.distance_to(close_up_position) > AUTO_ZOOM_OUT_DISTANCE:
		# player left the chat area; zoom back out
		set_close_up(false)


func set_close_up(new_close_up: bool) -> void:
	if close_up == new_close_up:
		# don't launch tween if the value is the same
		return
	
	close_up = new_close_up
	$Tween.remove_all()
	$Tween.interpolate_property(self, "close_up_pct", close_up_pct, 1.0 if close_up else 0.0,
			ZOOM_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()


func _on_OverworldUi_chat_started() -> void:
	set_close_up(true)


func _on_OverworldUi_chat_ended() -> void:
	set_close_up(false)
