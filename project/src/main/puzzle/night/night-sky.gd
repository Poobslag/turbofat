extends ColorRect
## Draws the starry sky behind the playfield during night mode.

## two large blue elliptical Sprites which add some texture to the sky
onready var _sky_sprites := [$SkyA, $SkyB]

## Particle2Ds which draw a starfield of big, cartoony stars
onready var _star_nodes := [$NightStarsDark, $NightStarsLight]

## rapidly rotates the stars when the playfield shows up, for a time lapse effect
onready var _sky_spin_tween := $SkySpinTween

func _ready() -> void:
	for sprite in _sky_sprites:
		sprite.frame = Utils.randi_range(0, 2)
	_randomize_sky_sprites()


## Randomly animates the blue sky sprites.
##
## The sprites never use the same animation frame twice in a row. The animation frames are largely symmetrical, so if
## frames were reused they'd appear to be mostly stationary, even if they were flipped.
func _randomize_sky_sprites() -> void:
	for sprite in _sky_sprites:
		sprite.frame = (sprite.frame + Utils.randi_range(1, 2)) % 3
		sprite.flip_h = randf() > 0.5
		sprite.flip_v = randf() > 0.5
		sprite.offset = Vector2(rand_range(-2, 2), rand_range(-2, 2))


## Rapidly rotates the stars for a time lapse effect
func _spin_sky() -> void:
	_sky_spin_tween.remove_all()
	for node in _star_nodes:
		_sky_spin_tween.interpolate_property(node, "rotation", 0, PI / 2, 0.6, Tween.TRANS_QUINT, Tween.EASE_OUT)
	_sky_spin_tween.start()


func _on_AnimateTimer_timeout() -> void:
	_randomize_sky_sprites()


## When we transition from daytime to nighttime, we rapidly rotate the stars for a time lapse effect
func _on_visibility_changed() -> void:
	if visible:
		_spin_sky()
