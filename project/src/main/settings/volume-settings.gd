class_name VolumeSettings
## Manages settings which control the game audio volume.

enum VolumeType { MASTER, MUSIC, SOUND, VOICE }

## Maximum volume level for each volume type.
##
## When the player adjusts the volume to 100% or 50%, we actually adjust the bus to a decreased value like 80% or 40%.
const MAX_LINEAR_VOLUME_BY_TYPE := {
	VolumeType.MASTER: 0.80, # 100% volume is too loud, so we limit the user to 80% volume
	VolumeType.MUSIC: 0.66, # the music overpowers other sounds at max volume, so we nudge it down
}

const MASTER := VolumeType.MASTER
const MUSIC := VolumeType.MUSIC
const SOUND := VolumeType.SOUND
const VOICE := VolumeType.VOICE

## 'false' if chewing sounds should be replaced with alternate sounds
var chewing_sounds := true

## Returns the volume of the specified bus as a linear energy value.
##
## This returns a player-friendly energy value which always scales from 0.0 to 1.0, even if internally we limit a bus
## to 80% volume.
func get_bus_volume_linear(volume_type: int) -> float:
	var user_volume_linear: float
	var bus_index := _bus_index(volume_type)
	if AudioServer.is_bus_mute(bus_index):
		user_volume_linear = 0.0
	else:
		var volume_db := AudioServer.get_bus_volume_db(bus_index)
		var bus_volume_linear: float = db2linear(volume_db)
		user_volume_linear = bus_volume_linear / MAX_LINEAR_VOLUME_BY_TYPE.get(volume_type, 1.0)
		user_volume_linear = clamp(user_volume_linear, 0.0, 1.0)
	return user_volume_linear


## Sets the volume of the specified bus with a linear energy value.
##
## This accepts a player-friendly energy value which always scales from 0.0 to 1.0, but internally we reduce the value
## before assigning it to the bus.
func set_bus_volume_linear(volume_type: int, new_user_volume_linear: float) -> void:
	var bus_index := _bus_index(volume_type)
	var bus_volume_linear: float = new_user_volume_linear * MAX_LINEAR_VOLUME_BY_TYPE.get(volume_type, 1.0)
	AudioServer.set_bus_volume_db(bus_index, linear2db(bus_volume_linear))
	AudioServer.set_bus_mute(bus_index, new_user_volume_linear <= 0)


func is_bus_mute(volume_type: int) -> bool:
	var bus_index := _bus_index(volume_type)
	return AudioServer.is_bus_mute(bus_index)


## Resets the sound, music and voice volumes to their default values.
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"master": get_bus_volume_linear(MASTER),
		"music": get_bus_volume_linear(MUSIC),
		"sound": get_bus_volume_linear(SOUND),
		"voice": get_bus_volume_linear(VOICE),
		"chewing_sounds": chewing_sounds,
	}


func from_json_dict(json: Dictionary) -> void:
	set_bus_volume_linear(MASTER, float(json.get("master", 0.7)))
	set_bus_volume_linear(MUSIC, float(json.get("music", 0.7)))
	set_bus_volume_linear(SOUND, float(json.get("sound", 0.7)))
	set_bus_volume_linear(VOICE, float(json.get("voice", 0.7)))
	chewing_sounds = json.get("chewing_sounds", true)


func _bus_index(volume_type: int) -> int:
	var bus_name: String
	match volume_type:
		MASTER: bus_name = "Master"
		MUSIC: bus_name = "Music Bus"
		SOUND: bus_name = "Sound Bus"
		VOICE: bus_name = "Voice Bus"
	return AudioServer.get_bus_index(bus_name)
