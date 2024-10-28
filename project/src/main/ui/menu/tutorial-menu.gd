extends Control
## Scene which lets the player launch tutorials.

onready var _paged_level_panel := $Panel

func _ready() -> void:
	MusicPlayer.play_menu_track()
	
	var tutorial_region := OtherLevelLibrary.region_for_id(OtherRegion.ID_TUTORIAL)
	if tutorial_region:
		_assign_default_recent_data(tutorial_region)
		_populate_level_buttons(tutorial_region)


## Assign a tutorial level if this is the first time launching the tutorial menu
func _assign_default_recent_data(tutorial_region: OtherRegion) -> void:
	if PlayerData.practice.tutorial_level_id:
		# player has already launched the tutorial menu
		return
	
	PlayerData.practice.tutorial_level_id = tutorial_region.level_ids.front()


func _populate_level_buttons(tutorial_region: OtherRegion) -> void:
	_paged_level_panel.populate(tutorial_region, PlayerData.practice.tutorial_level_id)


func _on_BackButton_pressed() -> void:
	SceneTransition.pop_trail({SceneTransition.FLAG_TYPE: SceneTransition.TYPE_NONE})


func _on_Panel_level_chosen(settings: LevelSettings) -> void:
	PlayerData.practice.tutorial_level_id = settings.id
	CurrentLevel.set_launched_level(settings.id)
	CurrentLevel.push_level_trail()
