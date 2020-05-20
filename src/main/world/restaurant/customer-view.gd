extends Node2D
"""
A small bubble which appears alongside the game window which shows the current customer. As the player drops blocks
and scores points, the customer eats and grows larger.
"""

# the amount of time spent panning the camera to a new customer
const PAN_DURATION_SECONDS := 0.4

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")


"""
Increases/decreases the camera and customer's fatness, playing an animation which gradually applies the change.

Parameters:
	'fatness': How fat the customer should be; 5.0 = 5x normal size
"""
func set_fatness(fatness: float, customer_index: int = -1) -> void:
	$SceneClip/CustomerSwitcher/Scene.set_fatness(fatness, customer_index)
	if customer_index == -1 or customer_index == $SceneClip/CustomerSwitcher/Scene.current_customer_index:
		$FatPlayer.set_fatness(fatness)


"""
Recolors the customer according to the specified customer definition. This involves updating shaders and sprite
properties.
"""
func summon_customer(customer_index: int = -1) -> void:
	var customer_def: Dictionary
	if Global.customer_queue.empty():
		customer_def = CustomerLoader.DEFINITIONS[randi() % CustomerLoader.DEFINITIONS.size()]
	else:
		customer_def = Global.customer_queue.pop_front()
	$SceneClip/CustomerSwitcher/Scene.summon_customer(customer_def, customer_index)


"""
Returns the camera's 'fatness' -- when fatness is 1.0 the camera is zoomed in, and when the fatness is at 10.0 it's
zoomed out so that the customer is in frame.
"""
func get_fatness() -> float:
	return $FatPlayer.get_fatness()


"""
Pans the camera to a new customer. This also changes which customer will be fed.
"""
func set_current_customer_index(current_customer_index: int) -> void:
	$SceneClip/CustomerSwitcher/Scene.current_customer_index = current_customer_index
	$SceneClip/CustomerSwitcher/CustomerSwitchTween.interpolate_property(
			$SceneClip/CustomerSwitcher, "position:x",
			$SceneClip/CustomerSwitcher.position.x, -1000 * current_customer_index, PAN_DURATION_SECONDS,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$FatPlayer.set_fatness($SceneClip/CustomerSwitcher/Scene.get_fatness(current_customer_index))
	$SceneClip/CustomerSwitcher/CustomerSwitchTween.start()


"""
Returns the index of the customer which the camera is currently focused on.
"""
func get_current_customer_index() -> int:
	return $SceneClip/CustomerSwitcher/Scene.current_customer_index


"""
Plays a 'check please!' voice sample, for when a customer is ready to leave
"""
func play_goodbye_voice() -> void:
	$SceneClip/CustomerSwitcher/Scene.play_goodbye_voice()


"""
Scroll to a new customer and replace the old customer.
"""
func scroll_to_new_customer() -> void:
	var customer_index: int = get_current_customer_index()
	var new_customer_index: int = (customer_index + randi() % 2 + 1) % 3
	set_current_customer_index(new_customer_index)
	yield(get_tree().create_timer(0.5), "timeout")
	set_fatness(1, customer_index)
	summon_customer(customer_index)


"""
If they ended the previous game while serving a customer, we scroll to a new one
"""
func _on_PuzzleScore_game_prepared() -> void:
	if get_fatness() > 1 and Global.customer_switch:
		scroll_to_new_customer()
