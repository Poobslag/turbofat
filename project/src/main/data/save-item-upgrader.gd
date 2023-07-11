class_name SaveItemUpgrader
## Provides backwards compatibility with older save formats.
##
## SaveItemUpgrader can update the 'version' tag, but any other version-specific updates must be defined externally.
## These version-specific updates can be incorporated via SaveItemUpgrader's 'add_upgrade_method' method.

## Externally defined method which provides version-specific updates.
class UpgradeMethod:
	## Object containing the method
	var object: Object
	
	## Name of the method which performs the upgrade
	var method: String
	
	## Old save data version which the method upgrades from
	var old_version: String
	
	## New save data version which the method upgrades to
	var new_version: String

## Newest version which everything should upgrade to.
var current_version := ""

## Externally defined methods which provide version-specific updates.
## key: (String) old save data version from which the method upgrades
## value: (UpgradeMethod) method to call
var _upgrade_methods := {}

## Adds a new externally defined method which provides version-specific updates.
##
## SaveItemUpgrader does not have logic for upgrading specific save data versions. This upgrade logic must be defined
## on an external object and incorporated via this 'add_upgrade_method' method.
##
## The specified upgrade method should accept an Array of source data and a SaveData object, and return a modified
## SaveData object. The upgrade method can also return null, in which case SaveItemUpgrader will omit the SaveData
## object from the list of upgraded save items.
##
## Parameters:
## 	'object': The object containing the method
##
## 	'method': The name of the method which performs the upgrade. This method should accept a SaveData object and
## 		return a modified SaveData object.
##
## 	'old_version': The old save data version which the method upgrades from
##
## 	'new_version': The new save data version which the method upgrades to
func add_upgrade_method(object: Object, method: String, old_version: String, new_version: String) -> void:
	var upgrade_method: UpgradeMethod = UpgradeMethod.new()
	upgrade_method.object = object
	upgrade_method.method = method
	upgrade_method.old_version = old_version
	upgrade_method.new_version = new_version
	_upgrade_methods[old_version] = upgrade_method


## Returns 'true' if the specified json save items are from an older version of the game.
func needs_upgrade(json_save_items: Array) -> bool:
	var result: bool = false
	var version := _get_version_string(json_save_items)
	if version == current_version:
		result = false
	elif _upgrade_methods.has(version):
		result = true
	else:
		push_warning("Unrecognized save data version: '%s'" % version)
	return result


## Transforms the specified json save items to the newest format.
func upgrade(json_save_items: Array) -> Array:
	var new_save_items := json_save_items
	while needs_upgrade(new_save_items):
		# upgrade the old save file to a new format
		var old_version := _get_version_string(new_save_items)
		
		if not _upgrade_methods.has(old_version):
			push_warning("Couldn't upgrade old save data version '%s'" % old_version)
			break
		
		var upgrade_method: UpgradeMethod = _upgrade_methods[old_version]
		var old_save_items := new_save_items
		new_save_items = []
		for json_save_item_obj in old_save_items:
			var save_item: SaveItem = SaveItem.new()
			save_item.from_json_dict(json_save_item_obj)
			match save_item.type:
				"version":
					save_item.value = upgrade_method.new_version
				_:
					save_item = upgrade_method.object.call(upgrade_method.method, old_save_items, save_item)
			
			if save_item:
				new_save_items.append(save_item.to_json_dict())
		
		if _get_version_string(new_save_items) == old_version:
			# failed to upgrade, but the data might still load
			push_warning("Couldn't upgrade old save data version '%s'" % old_version)
			break
	
	return new_save_items


## Extracts a version string from the specified json save items.
static func _get_version_string(json_save_items: Array) -> String:
	var version: SaveItem
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		if save_item.type == "version":
			version = save_item
			break
	return version.value if version else ""
