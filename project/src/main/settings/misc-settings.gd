class_name MiscSettings
## Manages miscellaneous settings such as language.

## Emitted when the MiscSettings.locale property is assigned.
signal locale_changed(value)

signal save_slot_changed

## Different save slots where the player can save/load their progress
enum SaveSlot {
	SLOT_A,
	SLOT_B,
	SLOT_C,
	SLOT_D,
}

## Human-readable prefixes for the save slots. These are shown to the player in menus
const SAVE_SLOT_PREFIXES := {
	SaveSlot.SLOT_A: "A",
	SaveSlot.SLOT_B: "B",
	SaveSlot.SLOT_C: "C",
	SaveSlot.SLOT_D: "D",
}

## Current save slot for saving/loading progress
var save_slot: int = SaveSlot.SLOT_A setget set_save_slot

## Current locale. This is redundant with TranslationServer.locale, but exposing a setter lets us provide a signal
## to notify when the locale changes.
var locale := "en" setget set_locale

## Resets the miscellaneous settings to their default values.
func reset() -> void:
	from_json_dict({})


func set_locale(new_locale: String) -> void:
	locale = new_locale
	TranslationServer.set_locale(new_locale)
	emit_signal("locale_changed", locale)


## Advance to the next locale.
##
## In the game, the user selects the locale from a menu, but some demos just want a fast and dirty way to change
## locales without a UI.
func advance_locale() -> void:
	var old_locale := TranslationServer.get_locale()
	var locales := TranslationServer.get_loaded_locales()
	var new_locale_index := (locales.find(old_locale) + 1) % locales.size()
	var new_locale: String = locales[new_locale_index]
	SystemData.misc_settings.set_locale(new_locale)


func set_save_slot(new_save_slot: int) -> void:
	if save_slot == new_save_slot:
		return
	save_slot = new_save_slot
	emit_signal("save_slot_changed")


func to_json_dict() -> Dictionary:
	return {
		"locale": locale,
		"save_slot": save_slot,
	}


func from_json_dict(json: Dictionary) -> void:
	set_save_slot(int(json.get("save_slot", SaveSlot.SLOT_A)))
	
	var new_locale: String
	if json.has("locale"):
		new_locale = json.get("locale")
	else:
		# resetting the locale sets it to the OS locale unless the 'locale/test' property is set.
		if ProjectSettings.get_setting("locale/test"):
			new_locale = ProjectSettings.get_setting("locale/test")
		else:
			new_locale = OS.get_locale()
	set_locale(new_locale)
