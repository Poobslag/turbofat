class_name MiscSettings
## Manages miscellaneous settings such as language.

signal save_slot_changed

## Different save slots where the player can save/load their progress
enum SaveSlot {
	SLOT_A,
	SLOT_B,
	SLOT_C,
	SLOT_D,
}

## Human-readable prefixes for the save slots. These are shown to the user in menus
const SAVE_SLOT_PREFIXES := {
	SaveSlot.SLOT_A: "A",
	SaveSlot.SLOT_B: "B",
	SaveSlot.SLOT_C: "C",
	SaveSlot.SLOT_D: "D",
}

## The current save slot for saving/loading progress
var save_slot: int = SaveSlot.SLOT_A setget set_save_slot

## Whether cutscenes should play by default.
var cutscene_force: int = Levels.CutsceneForce.NONE

## Resets the miscellaneous settings to their default values.
func reset() -> void:
	from_json_dict({})


func set_save_slot(new_save_slot: int) -> void:
	if save_slot == new_save_slot:
		return
	save_slot = new_save_slot
	emit_signal("save_slot_changed")


func to_json_dict() -> Dictionary:
	return {
		"locale": TranslationServer.get_locale(),
		"cutscene_force": cutscene_force,
		"save_slot": save_slot,
	}


func from_json_dict(json: Dictionary) -> void:
	cutscene_force = int(json.get("cutscene_force", Levels.CutsceneForce.NONE))
	save_slot = int(json.get("save_slot", SaveSlot.SLOT_A))
	
	if json.has("locale"):
		TranslationServer.set_locale(json.get("locale"))
	else:
		# resetting the locale sets it to the OS locale unless the 'locale/test' property is set.
		var default_locale: String
		if ProjectSettings.get_setting("locale/test"):
			default_locale = ProjectSettings.get_setting("locale/test")
		else:
			default_locale = OS.get_locale()
		TranslationServer.set_locale(default_locale)
