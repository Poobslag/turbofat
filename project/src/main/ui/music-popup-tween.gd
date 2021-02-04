extends Tween
"""
Makes the music popup appear and disappear.
"""

enum PopupState {
	NONE,
	POPPING_IN,
	POPPING_OUT
}

# the how long it takes the popup to slide in or out of view
const TWEEN_DURATION := 0.2

# the duration that the popup remains visible
const POPUP_DURATION := 4.0

# the music panel's y coordinate when popped in and when popped out
const POP_IN_Y := 32
const POP_OUT_Y := 0

# tracks whether the popup is currently popping in or out
var _popup_state: int = PopupState.NONE

onready var _music_panel := get_node("../Panel")

func _ready() -> void:
	connect("tween_all_completed", self, "_on_tween_all_completed")


func _enter_tree() -> void:
	# wait a frame for the Timer to be added to the scene tree before restoring its state.
	# we use a one-shot listener method instead of a yield statement to avoid 'class instance is gone' errors.
	get_tree().connect("idle_frame", self, "_restore_tween_and_timer_state")


"""
Makes the music popup appear, and then hides it after a few seconds.

Parameters:
	'pop_in_delay': The number of seconds to wait before showing the popup.
"""
func pop_in_and_out(pop_in_delay: float) -> void:
	if pop_in_delay:
		yield(get_tree().create_timer(pop_in_delay), "timeout")
	_pop_in()
	$Timer.start(POPUP_DURATION)
	yield($Timer, "timeout")
	_pop_out()


func _pop_in() -> void:
	# Calculate the tween duration.
	# This is usually TWEEN_DURATION, but can be shorter if the popup is partially popped in.
	var pop_in_amount := inverse_lerp(POP_OUT_Y, POP_IN_Y, _music_panel.rect_position.y)
	var tween_duration := TWEEN_DURATION * (1.0 - pop_in_amount)
	
	_popup_state = PopupState.POPPING_IN
	remove_all()
	interpolate_property(_music_panel, "rect_position:y", _music_panel.rect_position.y, POP_IN_Y, tween_duration)
	start()


func _pop_out() -> void:
	# Calculate the tween duration.
	# This is usually TWEEN_DURATION, but can be shorter if the popup is partially popped out.
	var pop_in_amount := inverse_lerp(POP_OUT_Y, POP_IN_Y, _music_panel.rect_position.y)
	var tween_duration := TWEEN_DURATION * pop_in_amount
	
	_popup_state = PopupState.POPPING_OUT
	remove_all()
	interpolate_property(_music_panel, "rect_position:y", _music_panel.rect_position.y, POP_OUT_Y, tween_duration)
	start()


"""
Restores the MusicPopupTween and Timer to the state before they exited the tree.

The MusicPopup is a singleton so that it maintains its position as the player navigates menus. However, timers and
tweens stop running when they exit the scene tree. This method restores the timers and tweens so that they're running
again.
"""
func _restore_tween_and_timer_state() -> void:
	# disconnect our one-shot method
	get_tree().disconnect("idle_frame", self, "_restore_tween_and_timer_state")
	
	match _popup_state:
		PopupState.POPPING_IN:
			# PopupTween was interrupted while popping in.
			# Pop in, wait a few seconds and then pop out.
			pop_in_and_out(0.0)
		
		PopupState.POPPING_OUT:
			# PopupTween was interrupted while popping out.
			# Finish popping out.
			_pop_out()
		
		PopupState.NONE:
			if _music_panel and _music_panel.rect_position.y > POP_OUT_Y:
				# PopupTween was interrupted while popped in.
				# Wait a few seconds and then pop out.
				$Timer.start(POPUP_DURATION)
				yield($Timer, "timeout")
				_pop_out()
			else:
				# PopupTween was not interrupted.
				pass


func _on_tween_all_completed() -> void:
	_popup_state = PopupState.NONE
