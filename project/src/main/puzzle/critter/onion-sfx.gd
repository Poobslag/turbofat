extends Node
## Sound effects for onions, puzzle critters which darken things making it hard to see.

## AudioStreamPlayers to use for rooster sound effects. We randomize these for variety.
onready var _roosters := [
	$Rooster0,
	$Rooster1,
]

## AudioStreamPlayers to use for the onion's voice when dancing. We randomize these for variety.
onready var _voices := [
	$Voice00,
	$Voice01,
	$Voice02,
	$Voice03,
	$Voice04,
	$Voice05,
	$Voice06,
	$Voice07,
	$Voice08,
	$Voice09,
	$Voice10,
	$Voice11,
	$Voice12,
]

## Plays a sound for the onion's voice when dancing.
func play_voice_sound() -> void:
	Utils.rand_value(_voices).play()


func play_rooster_sound() -> void:
	Utils.rand_value(_roosters).play()
