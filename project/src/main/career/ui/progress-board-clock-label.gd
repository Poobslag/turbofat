extends Label
## Draws the analog clock which appears above the progress board.
##
## The clock shows text like '12:30 pm', and can flash and emit particles.

## The duration in seconds that the clock should flash white.
const FLASH_DURATION := 1.5

## The default font outline color, when not flashing.
const OUTLINE_COLOR := Color("6c4331")

## The tween that handles the clock's flash effect.
onready var _flash_tween := $FlashTween

## Particles emitted when the clock flashes.
onready var _particles := $Particles

## Make the clock flash white and emit particles.
##
## This is called when the text changes to get the player's attention.
func flash() -> void:
	for particles_2d_node in _particles.get_children():
		var particles_2d: Particles2D = particles_2d_node
		particles_2d.restart()
		particles_2d.emitting = true
	
	var font: DynamicFont = get("custom_fonts/font")
	_flash_tween.remove_all()
	_flash_tween.interpolate_property(font, "outline_color", Color.white, OUTLINE_COLOR, \
			1.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	_flash_tween.start()
