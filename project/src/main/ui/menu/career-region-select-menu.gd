extends Control
## Scene which lets the player select a career region to play.

export (NodePath) var region_buttons_path: NodePath

onready var _region_buttons := get_node(region_buttons_path)

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()
	
	_region_buttons.set_regions(CareerLevelLibrary.regions)
	
	var last_unlocked_region: CareerRegion = \
			CareerLevelLibrary.region_for_distance(PlayerData.career.best_distance_travelled)
	_region_buttons.focus_region(last_unlocked_region.id)


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _on_BackButton_pressed() -> void:
	SceneTransition.pop_trail({SceneTransition.FLAG_TYPE: SceneTransition.TYPE_NONE})


func _on_RegionButtons_region_chosen(region) -> void:
	PlayerData.career.distance_travelled = region.start
	PlayerData.career.remain_in_region = region.end < PlayerData.career.best_distance_travelled
	PlayerData.career.show_progress = Careers.ShowProgress.STATIC
	
	if Breadcrumb.trail.front() == Global.SCENE_CAREER_REGION_SELECT_MENU:
		Breadcrumb.trail.pop_front()
	Breadcrumb.trail.push_front(Global.SCENE_CAREER_MAP)
	PlayerData.career.push_career_trail()
