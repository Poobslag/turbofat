extends Node
## Makes the music popup appear and disappear.

enum PopupState {
	POPPED_OUT, # off the top of the screen
	POPPING_IN, # moving onscreen
	POPPED_IN, # onscreen
	POPPING_OUT # moving offscreen
}

## the how long it takes the popup to slide in or out of view
const TWEEN_DURATION := 0.2

## the duration in seconds that the popup remains visible
const POPUP_DURATION := 4.0

## the music panel's y coordinate when popped in and when popped out
const POP_IN_Y := 32
const POP_OUT_Y := 0

## tracks whether the popup is currently popping in or out
var _popup_state: int = PopupState.POPPED_OUT

var _tween: SceneTreeTween

onready var _music_panel := get_node("../Panel")

func _ready() -> void:
	$PopOutTimer.connect("timeout", self, "_on_PopOutTimer_timeout")


func _enter_tree() -> void:
	# Wait a frame for the Timer to be added to the scene tree before restoring its state. We use a one-shot listener
	# method instead of a yield statement to avoid 'class instance is gone' errors. We also wrap it in an if statement
	# because this music popup can be reused as a singleton, so it's possible for it to be launched multiple times
	# with no idle_frame.
	if not get_tree().is_connected("idle_frame", self, "_restore_tween_and_timer_state"):
		get_tree().connect("idle_frame", self, "_restore_tween_and_timer_state", [get_tree()])


## Makes the music popup appear, and then hides it after a few seconds.
##
## Parameters:
## 	'pop_in_delay': The number of seconds to wait before showing the popup.
func pop_in_and_out(pop_in_delay: float) -> void:
	if pop_in_delay:
		# we use a one-shot listener method instead of a yield statement to avoid 'class instance is gone' errors.
		get_tree().create_timer(pop_in_delay).connect("timeout", self, "_pop_in")
	else:
		_pop_in()


func _pop_in() -> void:
	# Calculate the tween duration.
	# This is usually TWEEN_DURATION, but can be shorter if the popup is partially popped in.
	var pop_in_amount := inverse_lerp(POP_OUT_Y, POP_IN_Y, _music_panel.rect_position.y)
	var tween_duration := TWEEN_DURATION * (1.0 - pop_in_amount)
	
	if tween_duration:
		_popup_state = PopupState.POPPING_IN
		_tween = Utils.recreate_tween(self, _tween)
		_tween.tween_property(_music_panel, "rect_position:y", POP_IN_Y, tween_duration)
		_tween.tween_callback(self, "_on_Tween_pop_in_completed")
	else:
		$PopOutTimer.start(POPUP_DURATION)
		_popup_state = PopupState.POPPED_IN


func _pop_out() -> void:
	# Calculate the tween duration.
	# This is usually TWEEN_DURATION, but can be shorter if the popup is partially popped out.
	var pop_in_amount := inverse_lerp(POP_OUT_Y, POP_IN_Y, _music_panel.rect_position.y)
	var tween_duration := TWEEN_DURATION * pop_in_amount
	
	if tween_duration:
		_popup_state = PopupState.POPPING_OUT
		_tween = Utils.recreate_tween(self, _tween)
		_tween.tween_property(_music_panel, "rect_position:y", POP_OUT_Y, tween_duration)
		_tween.tween_callback(self, "_on_Tween_pop_out_completed")
	else:
		_popup_state = PopupState.POPPED_OUT


## Restores the MusicPopupTween and Timer to the state before they exited the tree.
##
## The MusicPopup is a singleton so that it maintains its position as the player navigates menus. However, timers and
## tweens stop running when they exit the scene tree. This method restores the timers and tweens so that they're
## running again.
##
## The SceneTree is passed in as a parameter because sometimes, this listener can be called over and over after this
## node has been removed from the scene tree. In that edge case we need an instance of the tree to remove the listener
## because get_tree() returns null.
func _restore_tween_and_timer_state(tree: SceneTree) -> void:
	# disconnect our one-shot method
	if tree.is_connected("idle_frame", self, "_restore_tween_and_timer_state"):
		tree.disconnect("idle_frame", self, "_restore_tween_and_timer_state")
	
	if is_inside_tree():
		match _popup_state:
			PopupState.POPPING_IN:
				# PopupTween was interrupted while popping in.
				# Pop in, wait a few seconds and then pop out.
				pop_in_and_out(0.0)
			
			PopupState.POPPING_OUT:
				# PopupTween was interrupted while popping out.
				# Finish popping out.
				_pop_out()
			
			PopupState.POPPED_IN:
				# PopupTween was interrupted while popped in.
				# Wait for however long was left on the timer, and then pop out.
				$PopOutTimer.start($PopOutTimer.time_left)


func _on_Tween_pop_in_completed() -> void:
	$PopOutTimer.start(POPUP_DURATION)
	_popup_state = PopupState.POPPED_IN


func _on_Tween_pop_out_completed() -> void:
	_popup_state = PopupState.POPPED_OUT


func _on_PopOutTimer_timeout() -> void:
	_pop_out()
