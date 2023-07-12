extends Control
## Toaster popup which shows the current song title.

## bgm which was last shown in this popup
var _shown_bgm: CheckpointSong

onready var _music_label := $Panel/HBoxContainer/Label
onready var _music_panel := $Panel
onready var _popup_tween_manager := $PopupTweenManager

func _ready() -> void:
	MusicPlayer.connect("current_bgm_changed", self, "_on_MusicPlayer_current_bgm_changed")
	_refresh_panel(MusicPlayer.current_bgm)
	_music_label.connect("item_rect_changed", self, "_on_Label_item_rect_changed")


## Update the popup's appearance based on the current song, and maybe show it.
##
## The popup is only shown if the song changes, and if the song is audible.
##
## Parameters:
## 	'value': The song to show in the popup
func _refresh_panel(value: CheckpointSong) -> void:
	if _shown_bgm == value or not is_inside_tree():
		return
	
	# if no music is audible, don't show a music popup
	if SystemData.volume_settings.is_bus_mute(VolumeSettings.MUSIC) \
			or SystemData.volume_settings.is_bus_mute(VolumeSettings.MASTER):
		_shown_bgm = null
	else:
		_shown_bgm = value
	
	# show the appropriate popup
	if _shown_bgm:
		_music_label.text = _shown_bgm.song_title
		
		# we delay a few seconds if the music is fading in slowly
		var pop_in_delay := 2.0 if MusicPlayer.is_fading_in() else 0.0
		_popup_tween_manager.pop_in_and_out(pop_in_delay)
		_music_panel.get("custom_styles/panel").set("bg_color", _shown_bgm.song_color)


func _on_MusicPlayer_current_bgm_changed(value: CheckpointSong) -> void:
	_refresh_panel(value)


func _on_Label_item_rect_changed() -> void:
	# wait for a frame; it takes a frame for Label.rect_size to update
	yield(get_tree(), "idle_frame")
	
	# resize the music panel to accommodate the label
	_music_panel.rect_size.x = _music_label.rect_size.x + 64
	_music_panel.rect_position.x = rect_size.x / 2 - _music_panel.rect_size.x / 2
