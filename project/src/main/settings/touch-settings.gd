class_name TouchSettings
## Manages settings which affect the touch controls.

signal settings_changed

## control schemes that decide which buttons appear where
enum ControlScheme {
	EASY_CONSOLE,
	EASY_DESKTOP,
	AMBI_CONSOLE,
	AMBI_DESKTOP,
	LOCO_CONSOLE,
	LOCO_DESKTOP,
}

const EASY_CONSOLE := ControlScheme.EASY_CONSOLE
const EASY_DESKTOP := ControlScheme.EASY_DESKTOP
const AMBI_CONSOLE := ControlScheme.AMBI_CONSOLE
const AMBI_DESKTOP := ControlScheme.AMBI_DESKTOP
const LOCO_CONSOLE := ControlScheme.LOCO_CONSOLE
const LOCO_DESKTOP := ControlScheme.LOCO_DESKTOP

## how easy it is to mash two buttons with one finger; 0.0 = impossible, 1.0 = very easy
var fat_finger := 0.66 setget set_fat_finger

## control scheme that decides which buttons appear where
var scheme: int = ControlScheme.EASY_CONSOLE setget set_scheme

## how large the buttons appear on screen
var size := 1.00 setget set_size

func reset() -> void:
	from_json_dict({})


func set_size(new_size: float) -> void:
	size = new_size
	emit_signal("settings_changed")


func set_scheme(new_scheme: int) -> void:
	scheme = new_scheme
	emit_signal("settings_changed")


func set_fat_finger(new_fat_finger: float) -> void:
	fat_finger = new_fat_finger
	emit_signal("settings_changed")


func to_json_dict() -> Dictionary:
	return {
		"fat_finger": fat_finger,
		"scheme": scheme,
		"size": size,
	}


func from_json_dict(json: Dictionary) -> void:
	fat_finger = float(json.get("fat_finger", 0.66))
	scheme = int(json.get("scheme", 0))
	size = float(json.get("size", 1.00))
	emit_signal("settings_changed")
