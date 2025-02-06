class_name RollingBackups
## Manages a set of rolling backups.
##
## Save data is first copied into an hourly, daily, and weekly temporary file which are never overwritten. Once those
## files reach a certain age, the corresponding rolling backup file is deleted and replaced with the temporary file.
##
## In other words, here is the lifecycle of the hourly backup file:
##
## 1. 'file.sav' is written, and copied to 'file.this-hour.sav.bak'
## 2. 'file.sav' is written again, but nothing happens until 'file.this-hour.sav.bak' is an hour old
## 3. 'file.sav' is written again. If 'file.this-hour.sav.bak' is an hour old...
## 	3a. 'file.prev-hour.sav.bak' is deleted (if it exists)
## 	3b. 'file.this-hour.sav.bak' is renamed to 'file.prev-hour.sav.bak'
## 	3c. 'file.sav' is copied to 'file.this-hour.sav.bak'

## Categories of rolling backups for save data.
enum Backup {
	CURRENT, # the current save data
	THIS_HOUR, # a temporary file which will eventually become the hourly backup
	PREV_HOUR, # a backup which is 1-2 hours old
	THIS_DAY, # a temporary file which will eventually become the daily backup
	PREV_DAY, # a backup which is 1-2 days old
	THIS_WEEK, # a temporary file which will eventually become the weekly backup
	PREV_WEEK, # a backup which is 1-2 weeks old
	LEGACY, # old save data from before July 2021
}

const CURRENT := Backup.CURRENT
const THIS_HOUR := Backup.THIS_HOUR
const PREV_HOUR := Backup.PREV_HOUR
const THIS_DAY := Backup.THIS_DAY
const PREV_DAY := Backup.PREV_DAY
const THIS_WEEK := Backup.THIS_WEEK
const PREV_WEEK := Backup.PREV_WEEK
const LEGACY := Backup.LEGACY

const SECONDS_PER_MINUTE := 60
const SECONDS_PER_HOUR := 60 * SECONDS_PER_MINUTE
const SECONDS_PER_DAY := 24 * SECONDS_PER_HOUR

## Filename for the current save. Backup filenames are derived based on this filename
var data_filename: String

## Filename for save data older than July 2021
var legacy_filename: String

## Enum from Backup for the backup which was successfully loaded, 'Backup.CURRENT' if the current file worked.
var loaded_backup := -1

## Newly renamed save files which couldn't be loaded
var corrupt_filenames: Array

## Attempts to load the newest save file, falling back to older and older backups if necessary.
##
## Loading is handled by a callback method. This callback accepts a filename parameter and returns 'true' if
## successful.
##
## Parameters:
## 	'target': the object containing the callback method responsible for loading.
##
## 	'method': the callback method responsible for loading.
func load_newest_save(target: Object, method: String) -> void:
	loaded_backup = -1
	corrupt_filenames = []
	var bad_filenames := [] # save filenames which couldn't be loaded
	
	var load_successful := false
	for backup in [CURRENT, THIS_HOUR, PREV_HOUR, THIS_DAY, PREV_DAY, THIS_WEEK, PREV_WEEK, LEGACY]:
		var rolling_filename := rolling_filename(backup)
		if not FileUtils.file_exists(rolling_filename):
			# file not found; try next file
			continue
		
		var success: bool = target.call(method, rolling_filename)
		if not success:
			# couldn't load; try next file
			bad_filenames.append(rolling_filename)
			continue
		
		# loaded successfully; don't load any more files
		loaded_backup = backup
		load_successful = true
		break
	
	if bad_filenames:
		var dir := Directory.new()
		# loaded successfully, but there were some save files that couldn't be loaded
		for bad_filename in bad_filenames:
			# copy each bad file to a filename like 'foo.save.corrupt'
			var corrupt_filename := corrupt_filename(bad_filename)
			dir.copy(bad_filename, corrupt_filename)
			dir.remove(bad_filename)
			corrupt_filenames.append(corrupt_filename)
		
		if load_successful:
			# copy the good file back to 'foo.save'
			dir.copy(rolling_filename(loaded_backup), data_filename)


## Deletes any old backup saves, replacing it with newer data.
func rotate_backups() -> void:
	_rotate_backup(THIS_HOUR, PREV_HOUR, SECONDS_PER_HOUR)
	_rotate_backup(THIS_DAY, PREV_DAY, SECONDS_PER_DAY)
	_rotate_backup(THIS_WEEK, PREV_WEEK, 7 * SECONDS_PER_DAY)


## Returns a filename with a '.corrupt' suffix to flag saves which couldn't be loaded.
func corrupt_filename(in_filename: String) -> String:
	return StringUtils.substring_before_last(in_filename, ".save") + ".save.corrupt"


## Returns a filename with a '.save' or '.bak' suffix to differentiate backup saves.
##
## Parameters:
## 	'backup': Enum from Backup for the filename to return.
func rolling_filename(backup: int) -> String:
	if backup == Backup.LEGACY:
		return legacy_filename
	
	var suffix := StringUtils.substring_after_last(data_filename, ".")
	var middle := "."
	var prefix := StringUtils.substring_before_last(data_filename, ".")
	match backup:
		Backup.THIS_HOUR: middle += "this-hour."
		Backup.PREV_HOUR: middle += "prev-hour."
		Backup.THIS_DAY: middle += "this-day."
		Backup.PREV_DAY: middle += "prev-day."
		Backup.THIS_WEEK: middle += "this-week."
		Backup.PREV_WEEK: middle += "prev-week."
	if backup != Backup.CURRENT:
		suffix += ".bak"
	return prefix + middle + suffix


## Deletes an old backup file, replacing it with a newer save file.
##
## If the newer 'this-xxx' backup file is older than the specified rotation time, it replaces the older 'prev-xxx'
## backup file.
##
## Afterwards, if the 'this-xxx' backup file does not exist or was just rotated, it's replaced with the current save
## file.
func _rotate_backup(this_save: int, prev_save: int, rotate_millis: int) -> void:
	if not FileUtils.file_exists(data_filename):
		return
	
	var dir := Directory.new()
	var this_filename := rolling_filename(this_save)
	var prev_filename := rolling_filename(prev_save)
	
	var file_age := 0
	if dir.file_exists(this_filename):
		file_age = OS.get_unix_time() - File.new().get_modified_time(this_filename)
	if file_age >= rotate_millis:
		# replace the 'prev-xxx' backup with the 'this-xxx' backup
		if dir.file_exists(prev_filename):
			dir.remove(prev_filename)
		dir.rename(this_filename, prev_filename)
	if not dir.file_exists(this_filename):
		# populate the 'this-xxx' backup from the current save
		dir.copy(data_filename, this_filename)


## Delete the current save and all backups.
func delete_all_backups() -> void:
	for backup in [CURRENT, THIS_HOUR, PREV_HOUR, THIS_DAY, PREV_DAY, THIS_WEEK, PREV_WEEK]:
		var rolling_filename := rolling_filename(backup)
		Directory.new().remove(rolling_filename)
