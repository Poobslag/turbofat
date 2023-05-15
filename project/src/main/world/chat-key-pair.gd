class_name ChatKeyPair
## Defines chat keys for cutscenes which play before or after a level.

enum ChatKeyPairType {
	NONE,
	INTRO_LEVEL,
	INTERLUDE,
	BOSS_LEVEL,
}

const NONE := ChatKeyPairType.NONE
const INTRO_LEVEL := ChatKeyPairType.INTRO_LEVEL
const INTERLUDE := ChatKeyPairType.INTERLUDE
const BOSS_LEVEL := ChatKeyPairType.BOSS_LEVEL

## chat key for cutscene which plays before a level
var preroll: String

## chat key for cutscene which plays after a level
var postroll: String

## Defines a cutscene type, such as intro, boss level or interlude
var type := NONE

## Returns 'true' if this ChatKeyPair does not define any cutscenes.
func is_empty() -> bool:
	return preroll.is_empty() and postroll.is_empty()


## Returns an ordered list of all cutscenes defined by this ChatKeyPair.
func chat_keys() -> Array:
	var result := []
	if preroll: result.append(preroll)
	if postroll: result.append(postroll)
	return result


func from_json_dict(json: Dictionary) -> void:
	preroll = json.get("preroll", "")
	postroll = json.get("postroll", "")
	type = Utils.enum_from_snake_case(ChatKeyPairType, json.get("type")) as ChatKeyPairType


func to_json_dict() -> Dictionary:
	return {
		"preroll": preroll,
		"postroll": postroll,
		"type": Utils.enum_to_snake_case(ChatKeyPairType, type)
	}
