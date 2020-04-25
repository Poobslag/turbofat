extends Sprite3D
"""
The mesh object used to display a visual icon next to things the player can interact with.
"""

# The chat icons bounce. These constants control how they bounce.
const BOUNCES_PER_SECOND := 0.7
const BOUNCE_HEIGHT := 2.5

# The chat icons fade in and fade out as the player get close. These constants control how they fade.
const FOCUSED_COLOR := Color(1.0, 1.0, 1.0, 1.00)
const UNFOCUSED_COLOR := Color(1.0, 1.0, 1.0, 0.25)

var bounce_phase := 0.0
var focused := false

func _ready() -> void:
	$PulsePlayer.play("pulse", -1, 2.0)
	modulate = UNFOCUSED_COLOR


func _physics_process(delta) -> void:
	bounce_phase += delta * (2.5 if focused else 1)
	if bounce_phase * BOUNCES_PER_SECOND * PI > 10.0:
		# keep bounce_phase bounded, otherwise a sprite will jitter slightly 3 billion millenia from now
		bounce_phase -= 2 / BOUNCES_PER_SECOND
	
	translation.y = 5 + abs(BOUNCE_HEIGHT * sin(bounce_phase * BOUNCES_PER_SECOND * PI))


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


"""
Tweens this objects 'modulate' property to a new value.
"""
func _tween_modulate(new_modulate: Color, duration: float) -> void:
	$FocusTween.remove_all()
	$FocusTween.interpolate_property(self, "modulate", modulate, new_modulate,
			duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$FocusTween.start()
