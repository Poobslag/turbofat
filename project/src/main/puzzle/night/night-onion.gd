extends Sprite2D
## Onion shown during nighttime. Hovers in the sky wiggling its tentacles.

## Position where the onion hovers about.
const CENTER_POSITION := Vector2(162, 92)

## Radius within which the onion hovers.
const WOBBLE_RADIUS := Vector2(7, 4)

## The onion hovers around during night time. This field is used to calculate the hover amount.
var _total_time := 0.0

## Update the onion's position.
func _process(delta: float) -> void:
	_total_time += delta
	
	position = CENTER_POSITION
	position.x += WOBBLE_RADIUS.x * sin(_total_time / 6.203 * PI)
	position.y += WOBBLE_RADIUS.x * sin(_total_time / 9.416 * PI)
