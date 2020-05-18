extends Node2D
"""
Generates visual lighting effects for the playfield.

These effects are pretty to look at, but also provide feedback if the player's combo is about to end.
"""

# Number of hues present when displaying a rainbow
const RAINBOW_COLOR_COUNT := 7

# Lights change color based on the lines the player clears.
const VEGETABLE_LIGHT_COLOR := Color("3074a320")
const FOOD_LIGHT_COLORS: Array = [
	Color("60f47700"), # brown
	Color("58ff5d68"), # pink
	Color("60ffc357"), # bread
	Color("50fff69b"), # white
]
# Rainbows are modulated white, because the tiles themselves have a color to them.
const RAINBOW_LIGHT_COLOR := Color("50ffffff")

# Light pattern shown when the player clears a line or continues their combo.
const ON_PATTERN: Array = [
	"....#....",
	"...###...",
	"..#####..",
	".#######.",
	"####.####",
	"###...###",
	"##.....##",
	"#.......#",
]

# Light pattern shown when the player's combo is about to end.
const HALF_PATTERN: Array = [
	"....#....",
	"...#.#...",
	"..#.#.#..",
	".#.#.#.#.",
	"#.#...#.#",
	".#.....#.",
	"#.......#",
	".........",
]

# Light pattern shown when the player has no combo.
const OFF_PATTERN: Array = [
	".........",
]

onready var _combo_tracker: ComboTracker = $"../../ComboTracker"

# light pattern being shown.
var _pattern := OFF_PATTERN

# offset used for displaying the light pattern, as well as for rainbow colors
var _pattern_y := 0

# number of 'elapsed beats' used for pulsing the lights. The length of a beat varies based on the piece speed, one
# beat is the amount of time an expert player would take to clear a line.
var _elapsed_beats := 0.0

# brightness of the background lights
var _brightness := 0.0

# how much the background lights dim when pulsing.
# 1.0 = pulsing completely on and off, 0.0 = not pulsing at all
var _pulse_amount := 0.0

# how long the lights remain on after a line clear
var _glow_duration := 0.0

# the current background light color
var _color := Color.transparent
var _color_int := -1

func _ready() -> void:
	reset()
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	
	for i in range(RAINBOW_COLOR_COUNT):
		var rainbow_color := Color.red
		rainbow_color.h += i / float(RAINBOW_COLOR_COUNT)
		
		$LightMap.tile_set.create_tile(i + 1)
		$LightMap.tile_set.tile_set_texture(i + 1, $LightMap.tile_set.tile_get_texture(0))
		$LightMap.tile_set.tile_set_material(i + 1, $LightMap.tile_set.tile_get_material(0))
		$LightMap.tile_set.tile_set_modulate(i + 1, rainbow_color)
		$LightMap.tile_set.tile_set_texture_offset(i + 1, $LightMap.tile_set.tile_get_texture_offset(0))
		
		$GlowMap.tile_set.create_tile(i + 1)
		$GlowMap.tile_set.tile_set_texture(i + 1, $GlowMap.tile_set.tile_get_texture(0))
		$GlowMap.tile_set.tile_set_material(i + 1, $GlowMap.tile_set.tile_get_material(0))
		$GlowMap.tile_set.tile_set_modulate(i + 1, rainbow_color)
		$GlowMap.tile_set.tile_set_texture_offset(i + 1, $GlowMap.tile_set.tile_get_texture_offset(0))


func _process(delta: float) -> void:
	_elapsed_beats += delta * (60.0 / RankCalculator.min_frames_per_line(PieceSpeeds.current_speed))
	modulate.a = lerp(_brightness * (1 - _pulse_amount), _brightness, 0.5 + 0.5 * cos(_elapsed_beats * TAU))


func reset() -> void:
	_pattern = OFF_PATTERN
	_color = Color.transparent
	_calculate_brightness(0)
	_remodulate_lights(0)


func _on_Playfield_before_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	_calculate_brightness(_combo_tracker.combo)
	_calculate_line_color(box_ints)
	_pattern_y += 1
	_start_glow_tween()
	_remodulate_lights(_combo_tracker.combo)


"""
Starts the glow tween, causing the lights to slowly dim.
"""
func _start_glow_tween() -> void:
	if _brightness > 0 and _glow_duration > 0.0:
		$GlowTween.remove_all()
		$GlowTween.interpolate_property($LightMap, "modulate:a", _color.a * 2.00, _color.a * 1.00,
			_glow_duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
		$GlowTween.interpolate_property($GlowMap, "modulate:a", _color.a * 1.50, _color.a * 0.25,
			_glow_duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
		$GlowTween.interpolate_property($BgStrobe, "color:a", _color.a * 0.75, 0.00,
			_glow_duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
		$GlowTween.start()


"""
Calculates the RGB light color for a row in the playfield.
"""
func _calculate_line_color(box_ints: Array) -> void:
	var line_color_int
	if box_ints.empty():
		line_color_int = -1
	elif box_ints.has(Playfield.BOX_INT_CAKE):
		line_color_int = Playfield.BOX_INT_CAKE
	elif box_ints.size() == 1 or box_ints[0] != _color_int:
		line_color_int = box_ints[0]
	else:
		# avoid showing the same color twice if we can help it
		line_color_int = box_ints[1]
	
	_color_int = line_color_int
	_color = _tile_index_to_color(line_color_int)


"""
Returns the RGB light color corresponding to a tile index from the playfield tilemap.
"""
static func _tile_index_to_color(color_int: int) -> Color:
	var color: Color
	if color_int == -1:
		# vegetable
		color = VEGETABLE_LIGHT_COLOR
	elif Playfield.is_snack_box(color_int):
		# snack box
		color = FOOD_LIGHT_COLORS[color_int]
	elif Playfield.is_cake_box(color_int):
		# cake box
		color = RAINBOW_LIGHT_COLOR
		color.h = rand_range(0.0, 1.0)
	return color


"""
Calculates the brightness of the lights based on the current combo.
"""
func _calculate_brightness(combo: int) -> void:
	_elapsed_beats = 0.0
	if combo >= 12:
		# 100% opacity flashing lights is hard on the eyes. even at max combo, we dial it back from 100%
		_brightness = lerp(0.30, 0.60, smoothstep(12, 40, combo))
		_pulse_amount = lerp(0.10, 0.30, smoothstep(12, 30, combo))
		_glow_duration = lerp(0.60, 2.40, smoothstep(12, 100, combo))
	elif combo >= 5:
		# We quickly ramp from a low brightness to medium brightness. Low brightness has some visual artifacts.
		_brightness = lerp(0.10, 0.30, smoothstep(5, 12, combo))
		_pulse_amount = lerp(0.00, 0.00, smoothstep(10, 12, combo))
		_glow_duration = lerp(0.30, 0.60, smoothstep(5, 12, combo))
	else:
		# Combos smaller than 5 do not cause lights to appear.
		_brightness = 0.0
		_pulse_amount = 0.0
		_glow_duration = 0.0
	modulate.a = _brightness


"""
Adjust the modulation for the lights.
"""
func _remodulate_lights(combo: int) -> void:
	$LightMap.modulate = Global.to_transparent(_color)
	$GlowMap.modulate = Global.to_transparent(_color)
	$BgStrobe.color = Global.to_transparent(_color)
	
	_refresh_tilemaps(combo)


"""
Calculates the new light pattern and refreshes the tilemaps.
"""
func _refresh_tilemaps(combo: int) -> void:
	var new_pattern: Array
	
	match _combo_tracker.combo_break:
		0: new_pattern = ON_PATTERN
		1: new_pattern = HALF_PATTERN
		_: new_pattern = OFF_PATTERN
	
	for y in range(Playfield.ROW_COUNT):
		for x in range(Playfield.COL_COUNT):
			var s: String = new_pattern[(y + _pattern_y) % new_pattern.size()]
			var tile: int = -1
			if s[x] == '#':
				if _color == RAINBOW_LIGHT_COLOR:
					tile = 1 + ((x + _pattern_y) % RAINBOW_COLOR_COUNT)
				else:
					tile = 0
			$LightMap.set_cell(x, y, tile)
			$GlowMap.set_cell(x, y, tile)
	
	_pattern = new_pattern


"""
When the player's combo breaks or resets we update the lights.
"""
func _on_ComboTracker_combo_break_changed(value: int) -> void:
	if value >= 2:
		if _pattern != OFF_PATTERN:
			reset()
			_refresh_tilemaps(value)
	else:
		_refresh_tilemaps(value)


"""
When the player makes a box we brighten the combo lights again.
"""
func _on_Playfield_box_made(x: int, y: int, width: int, height: int, color_int: int) -> void:
	_remodulate_lights(_combo_tracker.combo)
	_start_glow_tween()


func _on_PuzzleScore_game_prepared() -> void:
	reset()
