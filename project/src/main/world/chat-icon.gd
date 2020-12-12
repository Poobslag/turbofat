class_name ChatIcon
extends Node2D
"""
A visual icon which appears next to something the player can interact with.
"""

# emitted when the icon is finished vanishing after a call to 'vanish()'
signal vanish_finished

enum BubbleType {
	NONE,
	SPEECH, # large chat bubble for notable/interesting chats
	THOUGHT, # thought bubble
	FILLER, # small chat bubble for one-liner/filler chats
	FOOD, # food bubble for chats which launch a puzzle
}

const NONE := BubbleType.NONE
const SPEECH := BubbleType.SPEECH
const THOUGHT := BubbleType.THOUGHT
const FILLER := BubbleType.FILLER
const FOOD := BubbleType.FOOD

# The chat icons bounce. These constants control how they bounce.
const BOUNCE_DURATION := 0.7
const BOUNCE_HEIGHT := 12.0

# The chat icons fade in and fade out as the player get close. These constants control how they fade.
const COLOR_FOCUSED := Color(1.0, 1.0, 1.0, 1.00)
const COLOR_UNFOCUSED := Color(1.0, 1.0, 1.0, 0.25)

# mapping from chat icons to chat bubble sprite frames
const BUBBLE_TYPE_FRAMES := {
	NONE: [],
	SPEECH: [6, 7, 8],
	THOUGHT: [3, 4, 5],
	FILLER: [0, 1, 2],
	FOOD: [9, 10, 11, 12]
}

var bubble_type: int = BubbleType.SPEECH setget set_bubble_type

var _bounce_phase := 0.0
var _focused := false
var _chattable: Node
var _vanishing := false

func _ready() -> void:
	$FocusTween.connect("tween_completed", self, "_on_FocusTween_tween_completed")
	$PackedSprite.modulate = COLOR_UNFOCUSED
	_refresh()


func _physics_process(delta: float) -> void:
	_bounce_phase += delta * (2.5 if _focused else 1.0)
	if _bounce_phase * BOUNCE_DURATION * PI > 10.0:
		# keep bounce_phase bounded, otherwise a sprite will jitter slightly 3 billion millenia from now
		_bounce_phase -= 2 / BOUNCE_DURATION

	$PackedSprite.position.y = -57 - abs(BOUNCE_HEIGHT * sin(_bounce_phase * BOUNCE_DURATION * PI))


"""
Initializes the icon's appearance and position for the specified chattable.

Chattables must have a 'ChatIconHook' node. ChatIconHook is a RemoteTransform2D which updates the icon's position.
"""
func initialize(chattable: Node) -> void:
	_chattable = chattable
	if _chattable.has_meta("chat_bubble_type"):
		set_bubble_type(_chattable.get_meta("chat_bubble_type"))
	
	var hook: RemoteTransform2D = _chattable.get_node("ChatIconHook")
	hook.remote_path = hook.get_path_to(self)
	global_position = hook.global_position


func set_bubble_type(new_bubble_type: int) -> void:
	bubble_type = new_bubble_type
	_refresh()


"""
Make the chat icon focused, so the player knows they can interact with it.

This brightens the icon and makes it bounce faster.
"""
func focus() -> void:
	if _focused == true:
		return
	
	_tween_modulate(COLOR_FOCUSED, 0.8)
	_focused = true


"""
Make the chat icon unfocused, so the player knows they need to get closer to interact with it.

This dims the icon and makes it bounce slower.
"""
func unfocus() -> void:
	_tween_modulate(COLOR_UNFOCUSED, 1.6)
	_focused = false


"""
Makes the chat icon invisible, so the player knows they can't interact with it.
"""
func vanish() -> void:
	_tween_modulate(Color.transparent, 0.4)
	_focused = false


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	visible = bubble_type != BubbleType.NONE
	if visible:
		$PackedSprite.frame = Utils.rand_value(BUBBLE_TYPE_FRAMES[bubble_type])
	
	if bubble_type == BubbleType.NONE:
		if ChattableManager.is_connected("focus_changed", self, "_on_ChattableManager_focus_changed"):
			ChattableManager.disconnect("focus_changed", self, "_on_ChattableManager_focus_changed")
	else:
		if not ChattableManager.is_connected("focus_changed", self, "_on_ChattableManager_focus_changed"):
			ChattableManager.connect("focus_changed", self, "_on_ChattableManager_focus_changed")


"""
Tweens this objects 'modulate' property to a new value.
"""
func _tween_modulate(new_modulate: Color, duration: float) -> void:
	if $PackedSprite.modulate == new_modulate:
		# don't launch tween if our modulate property is already set appropriately
		return
	
	$FocusTween.remove_all()
	$FocusTween.interpolate_property($PackedSprite, "modulate", $PackedSprite.modulate, new_modulate,
			duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$FocusTween.start()


func _on_ChattableManager_focus_changed() -> void:
	if not ChattableManager.is_focus_enabled():
		vanish()
	elif ChattableManager.is_focused(_chattable):
		focus()
	else:
		unfocus()


func _on_FocusTween_tween_completed(object: Object, key: NodePath) -> void:
	if object == $PackedSprite and key.get_concatenated_subnames() == "modulate" and $PackedSprite.modulate.a == 0.0:
		emit_signal("vanish_finished")
