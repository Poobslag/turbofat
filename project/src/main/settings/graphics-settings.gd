class_name GraphicsSettings
## Manages settings which control the graphics.

signal creature_detail_changed(value)

signal fullscreen_changed(value)

signal use_vsync_changed(value)

enum CreatureDetail {
	LOW,
	HIGH,
}

## enum from CreatureDetail describing how detailed the creatures should look
var creature_detail: int = _default_creature_detail() setget set_creature_detail

var fullscreen: bool = true setget set_fullscreen

var use_vsync: bool = _default_use_vsync() setget set_use_vsync

func set_creature_detail(new_creature_detail: int) -> void:
	if creature_detail == new_creature_detail:
		return
	creature_detail = new_creature_detail
	emit_signal("creature_detail_changed", new_creature_detail)


func set_fullscreen(new_fullscreen: bool) -> void:
	if fullscreen == new_fullscreen:
		return
	fullscreen = new_fullscreen
	emit_signal("fullscreen_changed", new_fullscreen)


func set_use_vsync(new_use_vsync: bool) -> void:
	if use_vsync == new_use_vsync:
		return
	use_vsync = new_use_vsync
	emit_signal("use_vsync_changed", new_use_vsync)


## Resets the gameplay settings to their default values.
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"creature_detail": creature_detail,
		"fullscreen": fullscreen,
		"use_vsync": use_vsync,
	}


func from_json_dict(json: Dictionary) -> void:
	set_creature_detail(json.get("creature_detail", _default_creature_detail()))
	set_fullscreen(json.get("fullscreen", true))
	set_use_vsync(json.get("use_vsync", _default_use_vsync()))


## Returns the default creature detail setting value. Web and mobile targets use lower detail.
##
## GPUs on mobile devices (and seemingly, web targets) work in dramatically different ways from GPUs on desktop, and
## often used tile renderers. Tile renderers split up the screen into regular-sized tiles that fit into super fast
## cache memory, which reduces the number of read/write operations to the main memory. However, tiles that rely on the
## results of rendering in different tiles or on the results of earlier operations being preserved can be very slow. As
## a result, the Viewport texture utilized by creatures offers poor performance on mobile and web targets.
func _default_creature_detail() -> int:
	return CreatureDetail.LOW if OS.has_feature("web") or OS.has_feature("mobile") else CreatureDetail.HIGH


## Returns the default 'use vsync' value.
##
## VSync defaults to true because it ensures the game looks its best for most players out of the box, and matches the
## expectations of casual and new players who may not know what vsync does.
func _default_use_vsync() -> bool:
	return true
