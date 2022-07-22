extends Node
## Manages data for levels not used in career mode. This includes tutorials and training levels.
##
## Levels are stored as json resources. This class parses those json resources into OtherRegions so they can be used
## by the menu code.

## Path to the json file with the list of levels. Can be changed for tests.
const DEFAULT_OTHER_REGIONS_PATH := "res://assets/main/puzzle/other-regions.json"

const BEGINNER_TUTORIAL := "tutorial/basics_0"

## Path to the json file with the list of levels. Can be changed for tests.
var other_regions_path := DEFAULT_OTHER_REGIONS_PATH setget set_other_regions_path

## List of OtherRegion instances containing region and level data
var regions: Array = []

## Loads the list of levels from JSON
func _ready() -> void:
	_load_raw_json_data()


func set_other_regions_path(new_other_regions_path: String) -> void:
	other_regions_path = new_other_regions_path
	_load_raw_json_data()


## Loads the list of levels from JSON.
func _load_raw_json_data() -> void:
	regions.clear()
	
	var other_regions_text := FileUtils.get_file_as_text(other_regions_path)
	var other_regions_json: Dictionary = parse_json(other_regions_text)
	for region_json in other_regions_json.get("regions", []):
		var region := OtherRegion.new()
		region.from_json_dict(region_json)
		regions.append(region)
