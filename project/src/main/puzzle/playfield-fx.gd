class_name PlayfieldFx
extends Node2D
## Generates visual lighting effects for the playfield.
##
## These effects are pretty to look at, but also provide feedback if the player's combo is about to end.

## Number of hues present when displaying a rainbow
const RAINBOW_COLOR_COUNT := 7

## Lights change color based on the lines the player clears.
const VEGETABLE_LIGHT_COLOR := Color("6074a320")
const FOOD_LIGHT_COLORS := [
	Color("c0f47700"), # brown
	Color("b0ff5d68"), # pink
	Color("c0ffc357"), # bread
	Color("a0fff69b"), # white
]

## Rainbows are modulated white, because the tiles themselves have a color to them.
const RAINBOW_LIGHT_COLOR := Color("50ffffff")

## Light pattern shown when the player clears a line or continues their combo.
const ON_PATTERN := [
	"....#....",
	"...###...",
	"..#####..",
	".#######.",
	"####.####",
	"###...###",
	"##.....##",
	"#.......#",
]

## Light pattern shown when the player's combo is about to end.
const HALF_PATTERN := [
	"....#....",
	"...#.#...",
	"..#.#.#..",
	".#.#.#.#.",
	"#.#...#.#",
	".#.....#.",
	"#.......#",
	".........",
]

## Light pattern shown when the player has no combo.
const OFF_PATTERN := [
	".........",
]

export (NodePath) var combo_tracker_path: NodePath

## light pattern being shown.
var _pattern := OFF_PATTERN

## offset used for displaying the light pattern, as well as for rainbow colors
var _pattern_y := 0

## number of 'elapsed beats' used for pulsing the lights. The length of a beat varies based on the piece speed, one
## beat is the amount of time an expert player would take to clear a line.
var _elapsed_beats := 0.0

## brightness of the background lights
var _brightness := 0.0

## how much the background lights dim when pulsing.
## 1.0 = pulsing completely on and off, 0.0 = not pulsing at all
var _pulse_amount := 0.0

## how long the lights remain on after a line clear
var _glow_duration := 0.0

## the current background light color
var _color := Color.transparent

## tile indexes by food/vegetable color
var _color_tile_indexes: Dictionary

onready var _combo_tracker: ComboTracker = get_node(combo_tracker_path)

## lights which turn on and off
onready var light_map: TileMap = $LightMap

## glowy effect around the lights
onready var glow_map: TileMap = $GlowMap

## bright flash when the player clears a line
onready var bg_strobe: ColorRect = $BgStrobe

## gradually dims the glowiness
onready var _glow_tween: Tween = $GlowTween

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	_combo_tracker.connect("combo_break_changed", self, "_on_ComboTracker_combo_break_changed")
	PuzzleState.connect("combo_changed", self, "_on_PuzzleState_combo_changed")
	PuzzleState.connect("added_pickup_score", self, "_on_PuzzleState_added_pickup_score")
	_init_tile_set()
	_init_color_tile_indexes()
	reset()


func _process(delta: float) -> void:
	_elapsed_beats += delta * (60.0 / RankCalculator.min_frames_per_line(PieceSpeeds.current_speed))
	modulate.a = lerp(_brightness * (1 - _pulse_amount), _brightness, 0.5 + 0.5 * cos(_elapsed_beats * TAU))


func reset() -> void:
	_pattern = OFF_PATTERN
	_color = RAINBOW_LIGHT_COLOR
	light_map.modulate = Color.transparent
	glow_map.modulate = Color.transparent
	_calculate_brightness(0)
	_refresh_tile_maps()


## Initializes the different colored tiles in LightMap/GlowMap.
func _init_tile_set() -> void:
	if len(light_map.tile_set.get_tiles_ids()) > 1:
		return
	
	for food_light_color in FOOD_LIGHT_COLORS:
		_init_tile(food_light_color)
	
	_init_tile(VEGETABLE_LIGHT_COLOR)
	
	for i in range(RAINBOW_COLOR_COUNT):
		var rainbow_color := Utils.to_transparent(Color.red, 0.60)
		rainbow_color.h += i / float(RAINBOW_COLOR_COUNT)
		_init_tile(rainbow_color)


## Initializes the mapping of tile indexes by food/vegetable color.
func _init_color_tile_indexes() -> void:
	if _color_tile_indexes:
		return
	
	for tile_index in light_map.tile_set.get_tiles_ids():
		var color: Color = light_map.tile_set.tile_get_modulate(tile_index)
		_color_tile_indexes[color] = tile_index


func _init_tile(color: Color) -> void:
	for tile_set in [light_map.tile_set, glow_map.tile_set]:
		var tile_index := len(tile_set.get_tiles_ids())
		tile_set.create_tile(tile_index)
		tile_set.tile_set_texture(tile_index, tile_set.tile_get_texture(0))
		tile_set.tile_set_material(tile_index, tile_set.tile_get_material(0))
		tile_set.tile_set_modulate(tile_index, color)
		tile_set.tile_set_texture_offset(tile_index, tile_set.tile_get_texture_offset(0))


## Starts the glow tween, causing the lights to slowly dim.
func _start_glow_tween() -> void:
	if _brightness > 0 and _glow_duration > 0.0:
		_glow_tween.remove_all()
		_glow_tween.interpolate_property(light_map, "modulate:a", 1.00, 0.50,
			_glow_duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
		_glow_tween.interpolate_property(glow_map, "modulate:a", 0.75, 0.125,
			_glow_duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
		_glow_tween.interpolate_property(bg_strobe, "color:a", 0.33, 0.00,
			_glow_duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
		_glow_tween.start()


## Calculates the light color for a row in the playfield.
func _calculate_line_color(box_ints: Array) -> void:
	if box_ints.empty():
		# vegetable
		_color = VEGETABLE_LIGHT_COLOR
	elif PuzzleTileMap.has_cake_box(box_ints):
		# cake box
		_color = RAINBOW_LIGHT_COLOR
	elif box_ints.size() == 1 or FOOD_LIGHT_COLORS[box_ints[0]] != _color:
		# snack box
		_color = FOOD_LIGHT_COLORS[box_ints[0]]
	else:
		# avoid showing the same color twice if we can help it
		_color = FOOD_LIGHT_COLORS[box_ints[1]]


## Calculates the brightness of the lights based on the current combo.
func _calculate_brightness(combo: int) -> void:
	_elapsed_beats = 0.0
	
	# apply enhance_combo_fx setting for tutorial
	if CurrentLevel.settings.other.enhance_combo_fx and combo >= 3:
		combo += 12
	
	if combo >= 12:
		# 100% opacity flashing lights is hard on the eyes. even at max combo, we dial it back from 100%
		_brightness = lerp(0.30, 0.60, smoothstep(12, 40, combo))
		_pulse_amount = lerp(0.10, 0.30, smoothstep(12, 30, combo))
		_glow_duration = lerp(0.60, 2.40, smoothstep(12, 100, combo))
	elif combo >= 3:
		# We quickly ramp from a low brightness to medium brightness. Low brightness has some visual artifacts.
		_brightness = lerp(0.10, 0.30, smoothstep(3, 12, combo))
		_pulse_amount = 0.0
		_glow_duration = lerp(0.30, 0.60, smoothstep(3, 12, combo))
	else:
		# Combos smaller than 5 do not cause lights to appear.
		_brightness = 0.0
		_pulse_amount = 0.0
		_glow_duration = 0.0
	modulate.a = _brightness


## Calculates the new light pattern and refreshes the tile maps.
func _refresh_tile_maps() -> void:
	bg_strobe.color = Utils.to_transparent(_color)
	
	var old_pattern := _pattern
	var new_pattern: Array = OFF_PATTERN
	
	if _combo_tracker.combo_break == CurrentLevel.settings.combo_break.pieces - 1:
		new_pattern = HALF_PATTERN
	elif _combo_tracker.combo_break < CurrentLevel.settings.combo_break.pieces - 1:
		new_pattern = ON_PATTERN
	
	if old_pattern == OFF_PATTERN and new_pattern == OFF_PATTERN:
		# no need to refresh if all the lights remain off
		pass
	else:
		_pattern = new_pattern
		for y in range(PuzzleTileMap.ROW_COUNT):
			for x in range(PuzzleTileMap.COL_COUNT):
				var s: String = _pattern[(y + _pattern_y) % _pattern.size()]
				var tile: int = -1
				if s[x] == '#':
					if _color == RAINBOW_LIGHT_COLOR:
						tile = 6 + ((x + _pattern_y) % RAINBOW_COLOR_COUNT)
					elif _color_tile_indexes.has(_color):
						tile = _color_tile_indexes[_color]
				light_map.set_cell(x, y, tile)
				glow_map.set_cell(x, y, tile)


func _on_Playfield_before_line_cleared(_y: int, _total_lines: int, _remaining_lines: int, box_ints: Array) -> void:
	_calculate_line_color(box_ints)
	_pattern_y += 1
	_refresh_tile_maps()


func _on_ComboTracker_combo_break_changed(_value: int) -> void:
	_refresh_tile_maps()


func _on_PuzzleState_combo_changed(value: int) -> void:
	_calculate_brightness(value)
	_refresh_tile_maps()
	_start_glow_tween()


## When the player builds a box we brighten the combo lights again.
func _on_Playfield_box_built(_rect: Rect2, _box_type: int) -> void:
	_refresh_tile_maps()
	_start_glow_tween()


func _on_PuzzleState_added_pickup_score(_pickup_score: int) -> void:
	_refresh_tile_maps()
	_start_glow_tween()


func _on_PuzzleState_game_prepared() -> void:
	reset()
