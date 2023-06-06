#@tool
class_name PlayfieldFx
extends Node2D
## Generates visual lighting effects for the playfield.
##
## These effects are pretty to look at, but also provide feedback if the player's combo is about to end.

## Number of hues present when displaying a rainbow
const RAINBOW_COLOR_COUNT := 7

## Lights change color based on the lines the player clears.
const VEGETABLE_LIGHT_COLOR := Color("74a32060")
const FOOD_LIGHT_COLORS := [
	Color("f47700c0"), # brown
	Color("ff5d68b0"), # pink
	Color("ffc357c0"), # bread
	Color("fff69ba0"), # white
]

## Rainbows are modulated white, because the tiles themselves have a color to them.
const RAINBOW_LIGHT_COLOR := Color("ffffff50")

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

@export var combo_tracker_path: NodePath

@warning_ignore("unused_private_class_variable")
@export var _init_tile_set: bool: set = init_tile_set

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

## current background light color
var _color := Color.TRANSPARENT

## Key: (String) Food/vegetable color string in html format
## Value: Tile alternative id
var _light_map_alternative_ids_by_color: Dictionary

## Key: (String) Food/vegetable color string in html format
## Value: Tile alternative id
var _glow_map_alternative_ids_by_color: Dictionary

@onready var _combo_tracker: ComboTracker = get_node(combo_tracker_path)

## lights which turn on and off
@onready var light_map: TileMap = $LightMap

## glowy effect around the lights
@onready var glow_map: TileMap = $GlowMap

## bright flash when the player clears a line
@onready var bg_strobe: ColorRect = $BgStrobe

## gradually dims the glowiness
@onready var _glow_tween: Tween

func _ready() -> void:
	PuzzleState.game_prepared.connect(_on_PuzzleState_game_prepared)
	_combo_tracker.combo_break_changed.connect(_on_ComboTracker_combo_break_changed)
	PuzzleState.combo_changed.connect(_on_PuzzleState_combo_changed)
	PuzzleState.added_pickup_score.connect(_on_PuzzleState_added_pickup_score)
	init_tile_set()
	_init_alternative_ids_by_color(_light_map_alternative_ids_by_color, light_map)
	_init_alternative_ids_by_color(_glow_map_alternative_ids_by_color, glow_map)
	reset()


func _process(delta: float) -> void:
	_elapsed_beats += delta * (60.0 / RankCalculator.min_frames_per_line(PieceSpeeds.current_speed))
	modulate.a = lerp(_brightness * (1 - _pulse_amount), _brightness, 0.5 + 0.5 * cos(_elapsed_beats * TAU))


func reset() -> void:
	_pattern = OFF_PATTERN
	_color = RAINBOW_LIGHT_COLOR
	light_map.modulate = Color.TRANSPARENT
	glow_map.modulate = Color.TRANSPARENT
	_calculate_brightness(0)
	_refresh_tile_maps()


## Initializes the different colored tiles in LightMap/GlowMap.
func init_tile_set(value: bool = true) -> void:
	if not value:
		return
	
	if light_map.tile_set.get_source(1).get_alternative_tiles_count(Vector2i(0, 0)) > 1:
		return
	
	for food_light_color in FOOD_LIGHT_COLORS:
		_init_tile(food_light_color)
	
	_init_tile(VEGETABLE_LIGHT_COLOR)
	
	for i in range(RAINBOW_COLOR_COUNT):
		var rainbow_color := Utils.to_transparent(Color.RED, 0.60)
		rainbow_color.h += i / float(RAINBOW_COLOR_COUNT)
		_init_tile(rainbow_color)


## Initializes the mapping of tile indexes by food/vegetable color.
func _init_alternative_ids_by_color(target_dict: Dictionary, tile_map: TileMap) -> void:
	if not target_dict.is_empty():
		return
	
	var tile_set_source: TileSetAtlasSource = tile_map.tile_set.get_source(1)
	for alternative_id_index in range(1, tile_set_source.get_alternative_tiles_count(Vector2i(0, 0))):
		var alternative_id: int = tile_set_source.get_alternative_tile_id(Vector2i(0, 0), alternative_id_index)
		var color: Color = tile_set_source.get_tile_data(Vector2i(0, 0), alternative_id).modulate
		target_dict[color.to_html(true)] = alternative_id


func _init_tile(color: Color) -> void:
	for tile_set in [light_map.tile_set, glow_map.tile_set]:
		var original_tile_data: TileData = tile_set.get_source(1).get_tile_data(Vector2i(0, 0), 0)
		
		var alternative_id: int = tile_set.get_source(1).create_alternative_tile(Vector2i(0, 0))
		var alternative_tile_data: TileData = tile_set.get_source(1).get_tile_data(Vector2i(0, 0), alternative_id)
		alternative_tile_data.material = original_tile_data.material
		alternative_tile_data.modulate = color
		alternative_tile_data.texture_origin = original_tile_data.texture_origin


## Starts the glow tween, causing the lights to slowly dim.
func _start_glow_tween() -> void:
	if _brightness > 0 and _glow_duration > 0.0:
		light_map.modulate.a = 1.00
		glow_map.modulate.a = 0.75
		bg_strobe.color.a = 0.33
		
		_glow_tween = Utils.recreate_tween(self, _glow_tween).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		_glow_tween.tween_property(light_map, "modulate:a", 0.50, _glow_duration)
		_glow_tween.parallel().tween_property(glow_map, "modulate:a", 0.125, _glow_duration)
		_glow_tween.parallel().tween_property(bg_strobe, "color:a", 0.00, _glow_duration)


## Calculates the light color for a row in the playfield.
func _calculate_line_color(box_ints: Array) -> void:
	if box_ints.is_empty():
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
				if x > 4:
					continue
				
				var light_map_alternative_tile := find_alternative_tile(light_map, Vector2i(x, y))
				light_map.set_cell(0, Vector2i(x, y), 1, Vector2i(0, 0), light_map_alternative_tile)
				
				var glow_map_alternative_tile := find_alternative_tile(glow_map, Vector2i(x, y))
				glow_map.set_cell(0, Vector2i(x, y), 1, Vector2i(0, 0), glow_map_alternative_tile)


func find_alternative_tile(tile_map: TileMap, coords: Vector2i) -> int:
	var result: int = -1
	var alternative_ids_by_color: Dictionary = \
			_light_map_alternative_ids_by_color if tile_map == light_map else _glow_map_alternative_ids_by_color
	var s: String = _pattern[(coords.y + _pattern_y) % _pattern.size()]
	if s[coords.x] == '#':
#		if _color.to_html(true) == RAINBOW_LIGHT_COLOR.to_html(true):
		if _color.to_html(true) == RAINBOW_LIGHT_COLOR.to_html(true):
			result = 6 + ((coords.x + _pattern_y) % RAINBOW_COLOR_COUNT)
		elif alternative_ids_by_color.has(_color.to_html(true)):
			result = alternative_ids_by_color[_color.to_html(true)]
	return result


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
func _on_Playfield_box_built(_rect: Rect2i, _box_type: Foods.BoxType) -> void:
	_refresh_tile_maps()
	_start_glow_tween()


func _on_PuzzleState_added_pickup_score(_pickup_score: int) -> void:
	_refresh_tile_maps()
	_start_glow_tween()


func _on_PuzzleState_game_prepared() -> void:
	reset()
