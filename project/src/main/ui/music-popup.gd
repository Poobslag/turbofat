extends Control
## Toaster popup which shows the current song title.

## bgm which was last shown in this popup
var _shown_bgm: CheckpointSong

@onready var _music_label := $Panel/HBoxContainer/Label
@onready var _music_panel := $Panel
@onready var _popup_tween := $PopupTween

func _ready() -> void:
	MusicPlayer.current_bgm_changed.connect(_on_MusicPlayer_current_bgm_changed)
	_refresh_panel(MusicPlayer.current_bgm)
	_music_label.item_rect_changed.connect(_on_Label_item_rect_changed)


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
		_popup_tween.pop_in_and_out(pop_in_delay)
		_music_panel.get("theme_override_styles/panel").set("bg_color", _shown_bgm.song_color)


func _on_MusicPlayer_current_bgm_changed(value: CheckpointSong) -> void:
	_refresh_panel(value)


func _on_Label_item_rect_changed() -> void:
	# wait for a frame; it takes a frame for Label.rect_size to update
	await get_tree().process_frame
	
	# resize the music panel to accommodate the label
	_music_panel.size.x = _music_label.size.x + 64
	_music_panel.position.x = size.x / 2 - _music_panel.size.x / 2
