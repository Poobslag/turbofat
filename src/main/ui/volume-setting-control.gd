extends Control
"""
UI control for adjusting volume.

Updates the player's stored settings, and also updates the audio server.
"""

# The type of volume which is controlled by this slider: music, sounds or voices
export (VolumeSettings.VolumeType) var _volume_type: int setget set_volume_type

func _ready() -> void:
	_refresh_setting_label()
	_refresh_percent_label()
	$Control/HSlider.value = PlayerData.volume_settings.get_bus_volume_linear(_volume_type)
	
	# don't play sample sounds during initialization
	$SampleTimer.stop()


func set_volume_type(new_volume_type: int) -> void:
	_volume_type = new_volume_type
	if is_inside_tree():
		_refresh_setting_label()


func _refresh_percent_label() -> void:
	if $Control/HSlider.value > 0:
		$Control/Percent.text = "%d%%" % int($Control/HSlider.value * 100)
	else:
		$Control/Percent.text = "Mute"


func _refresh_setting_label() -> void:
	var label_text: String
	match _volume_type:
		VolumeSettings.MUSIC: label_text = "Music"
		VolumeSettings.SOUND: label_text = "Sounds"
		VolumeSettings.VOICE: label_text = "Voices"
	$Label.text = label_text


func _on_HSlider_value_changed(value: float) -> void:
	_refresh_percent_label()
	PlayerData.volume_settings.set_bus_volume_linear(_volume_type, value)
	$SampleTimer.start()


func _on_SampleTimer_timeout() -> void:
	match _volume_type:
		VolumeSettings.SOUND: $SampleSound.play()
		VolumeSettings.VOICE: $SampleVoice.play()
