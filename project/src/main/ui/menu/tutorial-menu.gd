extends Control
## Scene which lets the player launch tutorials.

export (NodePath) var level_buttons_path

onready var level_buttons: PagedLevelButtons = get_node(level_buttons_path)

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()
	
	var tutorial_region = _find_tutorial_region()
	if tutorial_region:
		_assign_default_recent_data(tutorial_region)
		_populate_level_buttons(tutorial_region)


func _find_tutorial_region() -> OtherRegion:
	var tutorial_region: OtherRegion
	for region in OtherLevelLibrary.regions:
		if region.id == OtherRegion.ID_TUTORIAL:
			tutorial_region = region
			break
	
	if not tutorial_region or not tutorial_region.level_ids:
		push_warning("No tutorial levels found.")
	
	return tutorial_region


## Assign a tutorial level if this is the first time launching the tutorial menu
func _assign_default_recent_data(tutorial_region: OtherRegion) -> void:
	if PlayerData.practice.tutorial_level_id:
		# player has already launched the tutorial menu
		return
	
	PlayerData.practice.tutorial_level_id = _tutorial_region.level_ids.front()


func _populate_level_buttons(tutorial_region: OtherRegion) -> void:
	level_buttons.set_region(_tutorial_region)
	level_buttons.set_level_ids(_tutorial_region.level_ids)
	level_buttons.focus_level(PlayerData.practice.tutorial_level_id)


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _on_BackButton_pressed() -> void:
	SceneTransition.pop_trail(true)


func _on_LevelButtons_level_started(settings: LevelSettings) -> void:
	PlayerData.practice.tutorial_level_id = settings.id
	CurrentLevel.set_launched_level(settings.id)
	CurrentLevel.push_level_trail()
