extends "res://addons/gut/test.gd"
"""
Unit test demonstrating the rolling backup behavior.
"""

const TEMP_FILENAME := "test837.save"

var _backups := RollingBackups.new()

func before_each() -> void:
	_backups.current_filename = "user://%s" % TEMP_FILENAME


func after_each() -> void:
	var dir := Directory.new()
	dir.remove(_backups.rolling_filename(RollingBackups.CURRENT))
	dir.remove(_backups.rolling_filename(RollingBackups.THIS_HOUR))
	dir.remove(_backups.rolling_filename(RollingBackups.PREV_HOUR))
	dir.remove(_backups.rolling_filename(RollingBackups.THIS_DAY))
	dir.remove(_backups.rolling_filename(RollingBackups.PREV_DAY))
	dir.remove(_backups.rolling_filename(RollingBackups.THIS_WEEK))
	dir.remove(_backups.rolling_filename(RollingBackups.PREV_WEEK))


func test_rolling_filename() -> void:
	assert_eq(_backups.rolling_filename(RollingBackups.CURRENT), "user://test837.save")
	assert_eq(_backups.rolling_filename(RollingBackups.THIS_HOUR), "user://test837.this-hour.save.bak")
	assert_eq(_backups.rolling_filename(RollingBackups.PREV_HOUR), "user://test837.prev-hour.save.bak")
	assert_eq(_backups.rolling_filename(RollingBackups.THIS_DAY), "user://test837.this-day.save.bak")
	assert_eq(_backups.rolling_filename(RollingBackups.PREV_DAY), "user://test837.prev-day.save.bak")
	assert_eq(_backups.rolling_filename(RollingBackups.THIS_WEEK), "user://test837.this-week.save.bak")
	assert_eq(_backups.rolling_filename(RollingBackups.PREV_WEEK), "user://test837.prev-week.save.bak")


func test_corrupt_filename() -> void:
	assert_eq(_backups.corrupt_filename("user://test837.save"), "user://test837.save.corrupt")
	assert_eq(_backups.corrupt_filename("user://test837.this-day.save.bak"),
			"user://test837.this-day.save.corrupt")
	
	# invalid input should produce non-harmful output
	assert_eq(_backups.corrupt_filename("abcd"), "abcd.save.corrupt")


func test_rotate_backups_none_exist() -> void:
	FileUtils.write_file(_backups.current_filename, "")
	_backups.rotate_backups()
	var file := File.new()
	
	# current save still exists
	assert_true(file.file_exists(_backups.rolling_filename(RollingBackups.CURRENT)), "RollingBackups.CURRENT")
	
	# newest backups were created
	assert_true(file.file_exists(_backups.rolling_filename(RollingBackups.THIS_HOUR)), "RollingBackups.THIS_HOUR")
	assert_true(file.file_exists(_backups.rolling_filename(RollingBackups.THIS_DAY)), "RollingBackups.THIS_DAY")
	assert_true(file.file_exists(_backups.rolling_filename(RollingBackups.THIS_WEEK)), "RollingBackups.THIS_WEEK")
	
	# old backups weren't created yet
	assert_false(file.file_exists(_backups.rolling_filename(RollingBackups.PREV_HOUR)), "RollingBackups.PREV_HOUR")
	assert_false(file.file_exists(_backups.rolling_filename(RollingBackups.PREV_DAY)), "RollingBackups.PREV_DAY")
	assert_false(file.file_exists(_backups.rolling_filename(RollingBackups.PREV_WEEK)), "RollingBackups.PREV_WEEK")


"""
Don't overwrite the 'this_xxx' backups if they already exist
"""
func test_rotate_backups_dont_overwrite_thisxxx() -> void:
	FileUtils.write_file(_backups.current_filename, "new-920")
	FileUtils.write_file(_backups.rolling_filename(RollingBackups.THIS_HOUR), "old-920")
	_backups.rotate_backups()
	
	assert_eq(FileUtils.get_file_as_text(_backups.rolling_filename(RollingBackups.THIS_HOUR)), "old-920")


"""
Move the 'this_xxx' backups out of the way if they're old
"""
func test_move_backups() -> void:
	FileUtils.write_file(_backups.rolling_filename(RollingBackups.THIS_HOUR), "")
	var file: File = File.new()
	file.close()
