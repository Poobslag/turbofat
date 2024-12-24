extends CanvasLayer
## Background wallpaper with colored areas, borders and shapes.
##
## To enable wallpaper for a scene, add it to the 'wallpaper_enabled' group. This will make the Wallpaper singleton
## visible when that node is the current scene.

## optional float parameters don't have the concept of null. this default value acts as a substitute so we can tell
## when a float value is unspecified.
const UNSPECIFIED_FLOAT := 3025403.0

export (PackedScene) var WallpaperBorderScene: PackedScene
export (PackedScene) var StickerRowScene: PackedScene

## two colors used for this wallpaper
var dark_color: Color
var light_color: Color

func _ready() -> void:
	_assign_daily_colors()
	
	# add borders
	var border_index := 0
	for border_y in range(-250, 250, 150):
		var wallpaper_border := _add_border(border_y, 50)
		if border_index % 2 == 0:
			wallpaper_border.set_gradient_colors(light_color, dark_color)
			wallpaper_border.velocity = Vector2(12.0, 0)
		else:
			wallpaper_border.set_gradient_colors(dark_color, light_color)
			wallpaper_border.velocity = Vector2(-12.0, 0)
		border_index += 1
	
	# add color rects
	var color_rect_index := 0
	for color_rect_y in range (-350, 350, 150):
		var color_rect := _add_color_rect(color_rect_y - 2, 104)
		color_rect.color = dark_color if color_rect_index % 2 == 0 else light_color
		color_rect_index += 1
	
	# stretch top/bottom color rects so they fill the screen
	$Container/ColorRects.get_children().front().anchor_top = 0.0
	$Container/ColorRects.get_children().front().margin_top = 0.0
	$Container/ColorRects.get_children().back().anchor_bottom = 1.0
	$Container/ColorRects.get_children().back().margin_bottom = 1.0
	
	# add sticker rows
	var sticker_row_index := 0
	for sticker_row_y in range (-350, 350, 150):
		var sticker_row := _add_sticker_row(sticker_row_y, 100)
		sticker_row.color = light_color if sticker_row_index % 2 == 0 else dark_color
		sticker_row.velocity = Vector2(-30.0, 0) if sticker_row_index % 2 == 0 else Vector2(30, 0)
		sticker_row_index += 1
	
	get_tree().connect("node_added", self, "_on_node_added")
	_refresh_visible()


## Assigns the background colors based on the day of the week.
func _assign_daily_colors() -> void:
	match OS.get_datetime().get("weekday"):
		OS.DAY_MONDAY: # chocolate brown
			dark_color = Color("280808")
			light_color = Color("360f09")
		OS.DAY_TUESDAY: # baby blue
			dark_color = Color("009cf3")
			light_color = Color("61bff3")
		OS.DAY_WEDNESDAY: # dark purple
			dark_color = Color("602091")
			light_color = Color("7125a9")
		OS.DAY_THURSDAY: # sugar white
			dark_color = Color("cba688")
			light_color = Color("e3c9b1")
		OS.DAY_FRIDAY: # grassy green
			dark_color = Color("36b16a")
			light_color = Color("6adc8d")
		OS.DAY_SATURDAY: # bready orange
			dark_color = Color("e87d25")
			light_color = Color("f79545")
		OS.DAY_SUNDAY, _: # strawberry red
			dark_color = Color("ed333b")
			light_color = Color("ff5d68")


func _add_sticker_row(row_y: float, row_height: float) -> StickerRow:
	var row: StickerRow = StickerRowScene.instance()
	set_anchors(row, 0.0, 0.5, 1.0)
	set_margins(row, 0.0, row_y, 0.0, row_y + row_height)
	$Container/Stickers.add_child(row)
	return row


func _add_border(border_y: float, border_height: float) -> WallpaperBorder:
	var border: WallpaperBorder = WallpaperBorderScene.instance()
	set_anchors(border, 0.0, 0.5, 1.0)
	set_margins(border, 0.0, border_y, 0.0, border_y + border_height)
	border.texture_scale = Vector2(200, border_height)
	border.velocity = Vector2(40, 0)
	$Container/Borders.add_child(border)
	return border


func _add_color_rect(rect_y: float, rect_height: float) -> ColorRect:
	var color_rect: ColorRect = ColorRect.new()
	set_anchors(color_rect, 0.0, 0.5, 1.0)
	set_margins(color_rect, 0.0, rect_y, 0.0, rect_y + rect_height)
	$Container/ColorRects.add_child(color_rect)
	return color_rect


## Toggles the wallpaper visibility.
##
## The wallpaper is visible if the current scene is in the 'wallpaper_enabled' group.
func _refresh_visible() -> void:
	if not is_inside_tree():
		return
	visible = get_tree().current_scene.is_in_group("wallpaper_enabled")


func _on_node_added(node: Node) -> void:
	if not is_inside_tree():
		return
	if node == get_tree().current_scene:
		_refresh_visible()


## Sets the left/top/right/bottom margins for a node.
##
## When one value is specified, it applies the same margin to all four sides.
##
## When two values are specified, the first margin applies to the left and right, the second to the top and bottom.
##
## When three values are specified, the first margin applies to the left, the second to the top and bottom, and the
## third to the right.
static func set_margins(target: Node, left: float, top: float = UNSPECIFIED_FLOAT,
		right: float = UNSPECIFIED_FLOAT, bottom: float = UNSPECIFIED_FLOAT) -> void:
	target.margin_left = left
	target.margin_top = top if top != UNSPECIFIED_FLOAT else left
	target.margin_right = right if right != UNSPECIFIED_FLOAT else left
	target.margin_bottom = bottom if bottom != UNSPECIFIED_FLOAT else top


## Sets the left/top/right/bottom anchors for a node.
##
## When one value is specified, it applies the same anchor to all four sides.
##
## When two values are specified, the first anchor applies to the left and right, the second to the top and bottom.
##
## When three values are specified, the first anchor applies to the left, the second to the top and bottom, and the
## third to the right.
static func set_anchors(target: Control, left: float, top: float = UNSPECIFIED_FLOAT,
		right: float = UNSPECIFIED_FLOAT, bottom: float = UNSPECIFIED_FLOAT) -> void:
	target.anchor_left = left
	target.anchor_top = top if top != UNSPECIFIED_FLOAT else left
	target.anchor_right = right if right != UNSPECIFIED_FLOAT else left
	target.anchor_bottom = bottom if bottom != UNSPECIFIED_FLOAT else top
