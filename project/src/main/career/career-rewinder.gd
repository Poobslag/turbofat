class_name CareerRewinder
extends Node
## Changes the player's current career mode chapter in response to cheat codes.

## List of chapter cheats we should recognize. The chapter cheat array index corresponds 1:1 to the region index.
const CHAPTER_CHEATS := [
	"chap01",
	"chap02",
	"chap03",
	"chap04",
	"chap05",
]

export (NodePath) var cheat_code_detector_path: NodePath

onready var _cheat_code_detector: CheatCodeDetector = get_node(cheat_code_detector_path)

func _ready() -> void:
	for chapter_cheat in CHAPTER_CHEATS:
		if not chapter_cheat in _cheat_code_detector.codes:
			_cheat_code_detector.codes.append(chapter_cheat)
	if not _cheat_code_detector.is_connected("cheat_detected", self, "_on_CheatCodeDetector_cheat_detected"):
		_cheat_code_detector.connect("cheat_detected", self, "_on_CheatCodeDetector_cheat_detected")


## Skips forward or backward to the specified region.
##
## Updates the player's career mode progress as though they just started the specified chapter. Also purges any
## cutscene history for the specified chapter.
func skip_to_region(region_index: int) -> bool:
	if region_index >= CareerLevelLibrary.regions.size():
		return false
	
	# end current career day
	PlayerData.career.advance_calendar()

	# rewind to start of chapter
	var region: CareerRegion = CareerLevelLibrary.regions[region_index]
	PlayerData.career.distance_travelled = region.start
	PlayerData.career.best_distance_travelled = region.start

	# remove chapter cutscene history
	for key in PlayerData.chat_history.history_index_by_chat_key.duplicate():
		if region.cutscene_path and key.begins_with(region.cutscene_path + "/"):
			PlayerData.chat_history.delete_history_item(key)
	
	return true


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if not cheat in CHAPTER_CHEATS:
		return
	
	var region_index := CHAPTER_CHEATS.find(cheat)
	var cheat_successful := skip_to_region(region_index)
	
	if cheat_successful:
		# Drop the player back at the career select screen
		Breadcrumb.trail = [
			Global.SCENE_CAREER_REGION_SELECT_MENU,
			Global.SCENE_MAIN_MENU,
			Global.SCENE_SPLASH,
		]

		SceneTransition.change_scene()
	
	detector.play_cheat_sound(cheat_successful)
