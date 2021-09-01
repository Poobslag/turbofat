class_name VolumeSettings
"""
Manages settings which control the game audio volume.
"""

enum VolumeType { MASTER, MUSIC, SOUND, VOICE }

const MASTER := VolumeType.MASTER
const MUSIC := VolumeType.MUSIC
const SOUND := VolumeType.SOUND
const VOICE := VolumeType.VOICE

"""
Returns the volume of the specified bus as a linear energy value.
"""
func get_bus_volume_linear(volume_type: int) -> float:
	var volume_linear: float
	var bus_index := _bus_index(volume_type)
	if AudioServer.is_bus_mute(bus_index):
		volume_linear = 0.0
	else:
		var volume_db := AudioServer.get_bus_volume_db(bus_index)
		volume_linear = db2linear(volume_db)
	return volume_linear


"""
Sets the volume of the specified bus with a linear energy value.
"""
func set_bus_volume_linear(volume_type: int, new_value: float) -> void:
	var bus_index := _bus_index(volume_type)
	AudioServer.set_bus_volume_db(bus_index, linear2db(new_value))
	AudioServer.set_bus_mute(bus_index, new_value <= 0)


func is_bus_mute(volume_type: int) -> bool:
	var bus_index := _bus_index(volume_type)
	return AudioServer.is_bus_mute(bus_index)


"""
Resets the sound, music and voice volumes to their default values.
"""
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"master": get_bus_volume_linear(MASTER),
		"music": get_bus_volume_linear(MUSIC),
		"sound": get_bus_volume_linear(SOUND),
		"voice": get_bus_volume_linear(VOICE),
	}


func from_json_dict(json: Dictionary) -> void:
	set_bus_volume_linear(MASTER, json.get("master", 0.7))
	set_bus_volume_linear(MUSIC, json.get("music", 0.7))
	set_bus_volume_linear(SOUND, json.get("sound", 0.7))
	set_bus_volume_linear(VOICE, json.get("voice", 0.7))


func _bus_index(volume_type: int) -> int:
	var bus_name: String
	match volume_type:
		MASTER: bus_name = "Master"
		MUSIC: bus_name = "Music Bus"
		SOUND: bus_name = "Sound Bus"
		VOICE: bus_name = "Voice Bus"
	return AudioServer.get_bus_index(bus_name)
