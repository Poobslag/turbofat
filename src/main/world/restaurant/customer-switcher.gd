extends Node2D

# the amount of time spent panning the camera to a new customer
const PAN_DURATION_SECONDS := 0.4

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_fatness(fatness: float, customer_index: int = -1) -> void:
	$Scene.set_fatness(fatness, customer_index)
	if customer_index == -1 or customer_index == get_current_customer_index():
		$FatPlayer.set_fatness(fatness)

func get_current_customer_index() -> int:
	return $Scene.current_customer_index

func summon_customer(customer_def: Dictionary, customer_index: int = -1) -> void:
	$Scene.summon_customer(customer_def, customer_index)

func set_current_customer_index(current_customer_index: int) -> void:
	$Scene.current_customer_index = current_customer_index
	$CustomerSwitchTween.interpolate_property(
			self, "position:x",
			position.x, -1000 * current_customer_index, PAN_DURATION_SECONDS,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$FatPlayer.set_fatness($Scene.get_fatness(current_customer_index))
	$CustomerSwitchTween.start()

func get_fatness() -> float:
	return $FatPlayer.get_fatness()

func play_goodbye_voice() -> void:
	$SceneClip/CustomerSwitcher/Scene.play_goodbye_voice()
