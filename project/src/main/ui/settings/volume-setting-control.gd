extends Control
## UI control for adjusting volume.
##
## Updates the player's stored settings, and also updates the audio server.

## Type of volume which is controlled by this slider: music, sounds or voices
@export var volume_type: VolumeSettings.VolumeType: set = set_volume_type

## Text description of this volume setting, 'Master Volume'
@onready var _setting_label: Label = $Label

## UI controls for the volume slider
@onready var _slider: HSlider = $HBoxContainer/HSlider
@onready var _percent_label: Label = $HBoxContainer/Percent

## Timers and sounds to play an sfx sample after the slider is dragged
@onready var _sample_timer: Timer = $SampleTimer
@onready var _sample_sound: AudioStreamPlayer = $SampleSound
@onready var _sample_voice: AudioStreamPlayer = $SampleVoice

func _ready() -> void:
	_slider.value = SystemData.volume_settings.get_bus_volume_linear(volume_type)
	_refresh_setting_label()
	_refresh_percent_label()
	
	# don't play sample sounds during initialization
	_sample_timer.stop()
	
	_slider.value_changed.connect(_on_HSlider_value_changed)
	_sample_timer.timeout.connect(_on_SampleTimer_timeout)


func set_volume_type(new_volume_type: VolumeSettings.VolumeType) -> void:
	volume_type = new_volume_type
	_refresh_setting_label()


func _refresh_percent_label() -> void:
	if not is_inside_tree():
		return
	
	if _slider.value > 0:
		_percent_label.text = "%d%%" % int(_slider.value * 100)
	else:
		_percent_label.text = tr("Mute")


func _refresh_setting_label() -> void:
	if not is_inside_tree():
		return
	
	var label_text: String
	match volume_type:
		VolumeSettings.MASTER: label_text = tr("Master")
		VolumeSettings.MUSIC: label_text = tr("Music")
		VolumeSettings.SOUND: label_text = tr("Sounds")
		VolumeSettings.VOICE: label_text = tr("Voices")
	_setting_label.text = label_text


func _on_HSlider_value_changed(value: float) -> void:
	_refresh_percent_label()
	SystemData.volume_settings.set_bus_volume_linear(volume_type, value)
	_sample_timer.start()


func _on_SampleTimer_timeout() -> void:
	match volume_type:
		VolumeSettings.MASTER: _sample_sound.play()
		VolumeSettings.SOUND: _sample_sound.play()
		VolumeSettings.VOICE: _sample_voice.play()
