extends CanvasLayer
## Toaster popup which shows the current track title.

## track which was last shown in this popup
var _shown_track: CheckpointMusicTrack

onready var _music_label := $Panel/HBoxContainer/Label
onready var _music_panel := $Panel
onready var _popup_tween_manager := $PopupTweenManager

func _ready() -> void:
	MusicPlayer.connect("current_track_changed", self, "_on_MusicPlayer_current_track_changed")
	_refresh_panel(MusicPlayer.current_track)
	_music_label.connect("item_rect_changed", self, "_on_Label_item_rect_changed")


## Update the popup's appearance based on the current track, and maybe show it.
##
## The popup is only shown if the track changes, and if the track is audible.
##
## Parameters:
## 	'value': The track to show in the popup
func _refresh_panel(value: CheckpointMusicTrack) -> void:
	if _shown_track == value or not is_inside_tree():
		return
	
	# if no music is audible, don't show a music popup
	if SystemData.volume_settings.is_bus_mute(VolumeSettings.MUSIC) \
			or SystemData.volume_settings.is_bus_mute(VolumeSettings.MASTER):
		_shown_track = null
	else:
		_shown_track = value
	
	# show the appropriate popup
	if _shown_track:
		_music_label.text = _shown_track.track_title
		
		# we delay a few seconds if the music is fading in slowly
		var pop_in_delay := 2.0 if MusicPlayer.is_fading_in() else 0.0
		_popup_tween_manager.pop_in_and_out(pop_in_delay)
		_music_panel.get("custom_styles/panel").set("bg_color", _shown_track.track_color)


func _on_MusicPlayer_current_track_changed(value: CheckpointMusicTrack) -> void:
	_refresh_panel(value)


func _on_Label_item_rect_changed() -> void:
	# wait for a frame; it takes a frame for Label.rect_size to update
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
	
	# resize the music panel to accommodate the label
	_music_panel.rect_size.x = _music_label.rect_size.x + 64
	_music_panel.rect_position.x = get_viewport().get_visible_rect().size.x / 2 - _music_panel.rect_size.x / 2
