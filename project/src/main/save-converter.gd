class_name SaveConverter
"""
Provides backwards compatibility with older save formats.

SaveConverter can update the 'version' tag, but any other version-specific updates must be defined externally. These
version-specific updates can be incorporated via SaveConverter's 'add_method' method.
"""

"""
An externally defined method which provides version-specific updates.
"""
class ConversionMethod:
	var object: Object # The object containing the method
	var method: String # The name of the method which performs the conversion
	var old_version: String # The old save data version which the method converts from
	var new_version: String # The new save data version which the method converts to

# Externally defined methods which provide version-specific updates.
# key: old save data version from which the method converts
# value: a ConversionMethod corresponding to the method to call
var conversion_methods := {}

"""
Adds a new externally defined method which provides version-specific updates.

SaveConverter does not have logic for converting specific save data versions. This conversion logic must be defined on
an external object and incorporated via this 'add_method' method.

The specified conversion method should accept a SaveData object and return a modified SaveData object. The conversion
method can also returns null, in which case SaveConverter will omit the SaveData object from the list of transformed
save items.

Parameters:
	'object': The object containing the method
	
	'method': The name of the method which performs the conversion. This method should accept a SaveData object and
		return a modified SaveData object.
	
	'old_version': The old save data version which the method converts from
	
	'new_version': The new save data version which the method converts to
"""
func add_method(object: Object, method: String, old_version: String, new_version: String) -> void:
	var conversion_method: ConversionMethod = ConversionMethod.new()
	conversion_method.object = object
	conversion_method.method = method
	conversion_method.old_version = old_version
	conversion_method.new_version = new_version
	conversion_methods[old_version] = conversion_method


"""
Returns 'true' if the specified json save items are from an older version of the game.
"""
func is_old_save_items(json_save_items: Array) -> bool:
	var is_old: bool = false
	var version := get_version_string(json_save_items)
	if version == PlayerSave.PLAYER_DATA_VERSION:
		is_old = false
	elif conversion_methods.has(version):
		is_old = true
	else:
		push_warning("Unrecognized save data version: '%s'" % version)
	return is_old


"""
Transforms the specified json save items to the latest format.
"""
func transform_old_save_items(json_save_items: Array) -> Array:
	var old_version := get_version_string(json_save_items)
	if not conversion_methods.has(old_version):
		push_warning("Couldn't convert old save data version '%s'" % old_version)
		return json_save_items
	
	var conversion_method: ConversionMethod = conversion_methods[old_version]
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"version":
				save_item.value = conversion_method.new_version
			_:
				save_item = conversion_method.object.call(conversion_method.method, save_item)
		
		if save_item:
			new_save_items.append(save_item.to_json_dict())
	return new_save_items


"""
Extracts a version string from the specified json save items.
"""
static func get_version_string(json_save_items: Array) -> String:
	var version: SaveItem
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		if save_item.type == "version":
			version = save_item
			break
	return version.value if version else ""
