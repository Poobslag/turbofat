class_name ChatIcon
extends Sprite
"""
A visual icon which appears next to something the player can interact with.
"""

enum BubbleType {
	NONE,
	SPEECH,
	THOUGHT
}

# The chat icons bounce. These constants control how they bounce.
const BOUNCES_PER_SECOND := 0.7
const BOUNCE_HEIGHT := 12.0

# The chat icons fade in and fade out as the player get close. These constants control how they fade.
const FOCUSED_COLOR := Color(1.0, 1.0, 1.0, 1.00)
const UNFOCUSED_COLOR := Color(1.0, 1.0, 1.0, 0.25)

export (BubbleType) var bubble_type: int setget set_bubble_type

# 'true' if this bubble should appear on the right side, 'false' if it's on the left side
export (bool) var right_side := true setget set_right_side

var bounce_phase := 0.0
var focused := false

func _ready() -> void:
	modulate = UNFOCUSED_COLOR
	_refresh()


func _physics_process(delta: float) -> void:
	bounce_phase += delta * (2.5 if focused else 1.0)
	if bounce_phase * BOUNCES_PER_SECOND * PI > 10.0:
		# keep bounce_phase bounded, otherwise a sprite will jitter slightly 3 billion millenia from now
		bounce_phase -= 2 / BOUNCES_PER_SECOND
	
	position.y = -52 - abs(BOUNCE_HEIGHT * sin(bounce_phase * BOUNCES_PER_SECOND * PI))


func set_bubble_type(new_bubble_type: int) -> void:
	bubble_type = new_bubble_type
	_refresh()


func set_right_side(new_right_side: bool) -> void:
	right_side = new_right_side
	position.x = 64 if right_side else -64
	flip_h = not right_side


"""
Make the chat icon focused, so the player knows they can interact with it.

This brightens the icon and makes it bounce faster.
"""
func focus() -> void:
	_tween_modulate(FOCUSED_COLOR, 0.8)
	focused = true


"""
Make the chat icon unfocused, so the player knows they need to get closer to interact with it.

This dims the icon and makes it bounce slower.
"""
func unfocus() -> void:
	_tween_modulate(UNFOCUSED_COLOR, 1.6)
	focused = false


"""
Makes the chat icon invisible, so the player knows they can't interact with it.
"""
func vanish() -> void:
	_tween_modulate(Color.transparent, 0.4)
	focused = false


func _refresh() -> void:
	visible = bubble_type != BubbleType.NONE
	frame = randi() % 3 + (3 if bubble_type == BubbleType.THOUGHT else 0)
	
	if is_inside_tree():
		if bubble_type == BubbleType.NONE:
			if get_parent().is_in_group("chattables"):
				get_parent().remove_from_group("chattables")
			if ChattableManager.is_connected("focus_changed", self, "_on_ChattableManager_focus_changed"):
				ChattableManager.disconnect("focus_changed", self, "_on_ChattableManager_focus_changed")
		else:
			if not get_parent().is_in_group("chattables"):
				get_parent().add_to_group("chattables")
			ChattableManager.connect("focus_changed", self, "_on_ChattableManager_focus_changed")


"""
Tweens this objects 'modulate' property to a new value.
"""
func _tween_modulate(new_modulate: Color, duration: float) -> void:
	$FocusTween.remove_all()
	$FocusTween.interpolate_property(self, "modulate", modulate, new_modulate,
			duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$FocusTween.start()


func _on_ChattableManager_focus_changed() -> void:
	if not ChattableManager.is_focus_enabled():
		vanish()
	elif ChattableManager.is_focused(get_parent()):
		focus()
	else:
		unfocus()
