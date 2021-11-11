class_name SwipeContainer
extends ScrollContainer
## Allows you to scroll a scroll container by dragging. Includes momentum.
##
## Adapted from https://github.com/godotengine/godot/issues/21137#issuecomment-474598933

const MIN_SWIPE_DISTANCE := 25

var _swiping: bool
var _swipe_start: Vector2
var _swipe_mouse_start: Vector2
var _swipe_mouse_times: Array
var _swipe_mouse_positions: Array

func _ready() -> void:
	_center_scrollbars()


func _input(event: InputEvent) -> void:
	if Utils.key_scancode(event) == KEY_SHIFT:
		var scrollbar_value: Vector2 = ($MarginContainer.rect_size - rect_size) / 2
		get_h_scrollbar().value = scrollbar_value.x
		get_v_scrollbar().value = scrollbar_value.y
	
	if event is InputEventMouseButton:
		if event.pressed:
			_swiping = true
			_swipe_start = Vector2(get_h_scroll(), get_v_scroll())
			_swipe_mouse_start = event.position
			_swipe_mouse_times = [OS.get_ticks_msec()]
			_swipe_mouse_positions = [_swipe_mouse_start]
		else:
			_swipe_mouse_times.append(OS.get_ticks_msec())
			_swipe_mouse_positions.append(event.position)
			var source := Vector2(get_h_scroll(), get_v_scroll())
			var idx := _swipe_mouse_times.size() - 1
			var now := OS.get_ticks_msec()
			var cutoff := now - 100
			for i in range(_swipe_mouse_times.size() - 1, -1, -1):
				if _swipe_mouse_times[i] >= cutoff: idx = i
				else: break
			var flick_start: Vector2 = _swipe_mouse_positions[idx]
			var flick_dur := min(0.3, (event.position - flick_start).length() / 1000)
			if flick_dur > 0.0:
				var tween := Tween.new()
				add_child(tween)
				var delta: Vector2 = event.position - flick_start
				var target := source - delta * flick_dur * 15.0
				tween.interpolate_method(self, "set_h_scroll", source.x, target.x,
						flick_dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				tween.interpolate_method(self, "set_v_scroll", source.y, target.y,
						flick_dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				tween.interpolate_callback(tween, flick_dur, "queue_free")
				tween.start()
			_swiping = false
	elif _swiping and event is InputEventMouseMotion:
		var delta: Vector2 = event.position - _swipe_mouse_start
		if delta.length() > MIN_SWIPE_DISTANCE or _swipe_mouse_times.size() > 1:
			set_h_scroll(_swipe_start.x - delta.x)
			set_v_scroll(_swipe_start.y - delta.y)
			_swipe_mouse_times.append(OS.get_ticks_msec())
			_swipe_mouse_positions.append(event.position)


func _center_scrollbars() -> void:
	yield(get_tree(), "idle_frame")
	var scrollbar_value: Vector2 = ($MarginContainer.rect_size - rect_size) / 2
	get_h_scrollbar().value = scrollbar_value.x
	get_v_scrollbar().value = scrollbar_value.y
