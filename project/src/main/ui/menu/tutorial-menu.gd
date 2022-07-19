extends Control
## Scene which lets the player launch tutorials.

export (NodePath) var level_buttons_path

onready var level_buttons: PagedLevelButtons = get_node(level_buttons_path)

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()
	
	var tutorial_region := _find_tutorial_region()
	_populate_level_buttons(tutorial_region)


func _find_tutorial_region() -> OtherRegion:
	var tutorial_region: OtherRegion
	for region in OtherLevelLibrary.regions:
		if region.id == OtherRegion.ID_TUTORIAL:
			tutorial_region = region
			break
	return tutorial_region


func _populate_level_buttons(tutorial_region: OtherRegion) -> void:
	if not tutorial_region or not tutorial_region.level_ids:
		push_warning("No tutorial levels found.")
		return
	
	var focused_level: String = tutorial_region.level_ids.back()
	for level_id in tutorial_region.level_ids:
		if not PlayerData.level_history.is_level_finished(level_id):
			focused_level = level_id
			break
	
	level_buttons.set_region(tutorial_region)
	level_buttons.set_level_ids(tutorial_region.level_ids)
	level_buttons.focus_level(focused_level)


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _on_BackButton_pressed() -> void:
	SceneTransition.pop_trail(true)


func _on_LevelButtons_level_started(settings: LevelSettings) -> void:
	CurrentLevel.set_launched_level(settings.id)
	CurrentLevel.push_level_trail()
