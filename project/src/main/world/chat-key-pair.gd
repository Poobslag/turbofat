class_name ChatKeyPair
## Defines chat keys for cutscenes which play before or after a level.

## chat key for cutscene which plays before a level
var preroll: String

## chat key for cutscene which plays after a level
var postroll: String

## Returns 'true' if this ChatKeyPair does not define any cutscenes.
func empty() -> bool:
	return not preroll and not postroll


## Returns an ordered list of all cutscenes defined by this ChatKeyPair.
func chat_keys() -> Array:
	var result := []
	if preroll: result.append(preroll)
	if postroll: result.append(postroll)
	return result


func from_json_dict(json: Dictionary) -> void:
	preroll = json.get("preroll", "")
	postroll = json.get("postroll", "")


func to_json_dict() -> Dictionary:
	return {
		"preroll": preroll,
		"postroll": postroll,
	}
