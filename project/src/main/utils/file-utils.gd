class_name FileUtils
## Utility class for file operations.
##
## Many of these were adopted from the Gut library.

static func file_exists(path: String) -> bool:
	return FileAccess.file_exists(path)


static func get_file_as_text(path: String) -> String:
	if not file_exists(path):
		push_error("File not found: %s" % path)
		return ""
	
	return FileAccess.get_file_as_string(path)


static func write_file(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
