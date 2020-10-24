extends Control
"""
A toaster popup which shows the current song title.
"""

# the bgm which was last shown in this popup
var _shown_bgm: CheckpointSong

func _ready() -> void:
	MusicPlayer.connect("current_bgm_changed", self, "_on_MusicPlayer_current_bgm_changed")
	_refresh_panel(MusicPlayer.current_bgm)


"""
Update the popup's appearance based on the current song, and maybe show it.

The popup is only shown if the song changes, and if the song is audible.

Parameters:
	'value': The song to show in the popup
"""
func _refresh_panel(value: CheckpointSong) -> void:
	if _shown_bgm == value or not is_inside_tree():
		return
	
	# if no music is audible, don't show a music popup
	if PlayerData.volume_settings.is_bus_mute(VolumeSettings.MUSIC) \
			or PlayerData.volume_settings.is_bus_mute(VolumeSettings.MASTER):
		_shown_bgm = null
	else:
		_shown_bgm = value
	
	# show the appropriate popup
	if _shown_bgm:
		$Panel/HBoxContainer/Label.text = _shown_bgm.song_title
		
		# wait a frame for any volume adjustments, and for the label to resize.
		# we use a one-shot listener method instead of a yield statement to avoid 'class instance is gone' errors.
		get_tree().connect("idle_frame", self, "_refresh_panel_part_two")


"""
Workaround for bug where Godot reports 'class instance is gone' from yield statements.

We want to run some code after an idle frame. This can be done with a yield statement, but it causes 'class instance
is gone' errors if the class is freed before the yield statement resolves.

As a workaround, we split out this one-shot listener method which is essentially the second half of _refresh_panel.
"""
func _refresh_panel_part_two() -> void:
	# disconnect our one-shot method
	get_tree().disconnect("idle_frame", self, "_refresh_panel_part_two")
	
	# we delay a few seconds if the music is fading in slowly
	var pop_in_delay := 2.0 if MusicPlayer.is_fading_in() else 0.0
	$PopupTween.pop_in_and_out(pop_in_delay)
	
	# after the label resizes, resize the music panel to accommodate it
	$Panel.rect_size.x = $Panel/HBoxContainer/Label.rect_size.x + 64
	$Panel.rect_position.x = rect_size.x / 2 - $Panel.rect_size.x / 2
	$Panel.get("custom_styles/panel").set("bg_color", _shown_bgm.song_color)


func _on_MusicPlayer_current_bgm_changed(value: CheckpointSong) -> void:
	_refresh_panel(value)
