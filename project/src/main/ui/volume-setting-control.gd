extends Control
"""
UI control for adjusting volume.

Updates the player's stored settings, and also updates the audio server.
"""

# The type of volume which is controlled by this slider: music, sounds or voices
export (VolumeSettings.VolumeType) var volume_type: int setget set_volume_type

func _ready() -> void:
	$HBoxContainer/HSlider.value = PlayerData.volume_settings.get_bus_volume_linear(volume_type)
	_refresh_setting_label()
	_refresh_percent_label()
	
	# don't play sample sounds during initialization
	$SampleTimer.stop()
	
	$HBoxContainer/HSlider.connect("value_changed", self, "_on_HSlider_value_changed")
	$SampleTimer.connect("timeout", self, "_on_SampleTimer_timeout")


func set_volume_type(new_volume_type: int) -> void:
	volume_type = new_volume_type
	if is_inside_tree():
		_refresh_setting_label()


func _refresh_percent_label() -> void:
	if $HBoxContainer/HSlider.value > 0:
		$HBoxContainer/Percent.text = "%d%%" % int($HBoxContainer/HSlider.value * 100)
	else:
		$HBoxContainer/Percent.text = "Mute"


func _refresh_setting_label() -> void:
	var label_text: String
	match volume_type:
		VolumeSettings.MASTER: label_text = "Master"
		VolumeSettings.MUSIC: label_text = "Music"
		VolumeSettings.SOUND: label_text = "Sounds"
		VolumeSettings.VOICE: label_text = "Voices"
	$Label.text = label_text


func _on_HSlider_value_changed(value: float) -> void:
	_refresh_percent_label()
	PlayerData.volume_settings.set_bus_volume_linear(volume_type, value)
	$SampleTimer.start()


func _on_SampleTimer_timeout() -> void:
	match volume_type:
		VolumeSettings.MASTER: $SampleSound.play()
		VolumeSettings.SOUND: $SampleSound.play()
		VolumeSettings.VOICE: $SampleVoice.play()
