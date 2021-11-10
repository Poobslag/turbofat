class_name LevelSettingsUpgrader

## An externally defined method which provides version-specific updates.
class UpgradeMethod:
	## The name of the method which performs the upgrade
	var method: String
	
	## The old save data version which the method upgrades from
	var old_version: String
	
	## The new save data version which the method upgrades to
	var new_version: String

## Internally defined methods which provide version-specific updates.
## key: old save data version from which the method upgrades
## value: a UpgradeMethod corresponding to the method to call
var _upgrade_methods := {}

func _init() -> void:
	_add_upgrade_method("_upgrade_19c5", "19c5", "297a")
	_add_upgrade_method("_upgrade_1922", "1922", "19c5")


## Upgrades the specified json settings to the newest format.
func upgrade(json_settings: Dictionary) -> Dictionary:
	var new_json := json_settings
	while needs_upgrade(new_json):
		# upgrade the old save file to a new format
		var old_version := _get_version_string(new_json)
		
		if not _upgrade_methods.has(old_version):
			push_warning("Couldn't upgrade old settings version '%s'" % old_version)
			break
		
		var upgrade_method: UpgradeMethod = _upgrade_methods[old_version]
		var old_json := new_json
		new_json = {}
		for old_key in old_json:
			match old_key:
				"version":
					new_json["version"] = upgrade_method.new_version
				_:
					call(upgrade_method.method, old_json, old_key, new_json)
		
		if _get_version_string(new_json) == old_version:
			# failed to upgrade, but the data might still load
			push_warning("Couldn't upgrade old settings '%s'" % old_version)
			break
	
	return new_json


## Returns 'true' if the specified json settings are from an older version of the game.
func needs_upgrade(json_settings: Dictionary) -> bool:
	var result: bool = false
	var version := _get_version_string(json_settings)
	if version == Levels.LEVEL_DATA_VERSION:
		result = false
	elif _upgrade_methods.has(version):
		result = true
	else:
		push_warning("Unrecognized settings version: '%s'" % version)
	return result


## Adds a new internally defined method which provides version-specific updates.
##
## Upgrade methods include three parameters:
## 	'old_json': (Dictionary) Old parsed level settings from which data should be upgraded
##
## 	'old_key': (String) A key corresponding to a key/value pair in the old_json dictionary which should be upgraded
##
## 	'new_json': (Dictionary) Destination dictionary to which upgraded data should be written
##
## Parameters:
## 	'method': The name of the method which performs the upgrade.
##
## 	'old_version': The old settings version which the method upgrades from
##
## 	'new_version': The new settings version which the method upgrades to
func _add_upgrade_method(method: String, old_version: String, new_version: String) -> void:
	var upgrade_method: UpgradeMethod = UpgradeMethod.new()
	upgrade_method.method = method
	upgrade_method.old_version = old_version
	upgrade_method.new_version = new_version
	_upgrade_methods[old_version] = upgrade_method


func _upgrade_19c5(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"blocks_start":
			new_json["tiles"] = {"start": old_json[old_key].get("tiles", [])}
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


func _upgrade_1922(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"start_level":
			new_json["start_speed"] = old_json[old_key]
		"level_ups":
			var new_value := []
			for old_level_up in old_json[old_key]:
				var new_level_up: Dictionary = old_level_up.duplicate()
				new_level_up["speed"] = new_level_up.get("level")
				new_level_up.erase("level")
				new_value.append(new_level_up)
			new_json["speed_ups"] = new_value
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


## Extracts a version string from the specified json settings.
static func _get_version_string(json_settings: Dictionary) -> String:
	return json_settings.get("version")
