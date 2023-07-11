class_name GraphicsSettings
## Manages settings which control the graphics.

signal creature_detail_changed(value)

enum CreatureDetail {
	LOW,
	HIGH,
}

enum FeedingAnimation {
	LINEAR,
	BOUNCY,
}

## enum from CreatureDetail describing how detailed the creatures should look
var creature_detail: int = _default_creature_detail() setget set_creature_detail

var feeding_animation: int = _default_feeding_animation()

var use_vsync: bool = _default_use_vsync() setget set_use_vsync

func set_creature_detail(new_creature_detail: int) -> void:
	if creature_detail == new_creature_detail:
		return
	creature_detail = new_creature_detail
	emit_signal("creature_detail_changed", new_creature_detail)


func set_use_vsync(new_use_vsync: bool) -> void:
	use_vsync = new_use_vsync
	OS.set_use_vsync(new_use_vsync)


## Resets the gameplay settings to their default values.
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"creature_detail": creature_detail,
		"use_vsync": use_vsync,
		"feeding_animation": feeding_animation
	}


func from_json_dict(json: Dictionary) -> void:
	set_creature_detail(json.get("creature_detail", _default_creature_detail()))
	set_use_vsync(json.get("use_vsync", _default_use_vsync()))
	feeding_animation = json.get("feeding_animation", _default_feeding_animation())


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
## Many platforms enforce vsync regardless of this value (such as mobile platforms and HTML5), so we default it to
## 'true' on those platforms. However, it makes stuttering more noticable during puzzles.
func _default_use_vsync() -> bool:
	return true if OS.has_feature("web") or OS.has_feature("mobile") else false


## Retuns the default feeding animation setting value.
func _default_feeding_animation() -> int:
	return FeedingAnimation.BOUNCY
