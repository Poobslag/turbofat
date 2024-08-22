extends GutTest

const TEMP_FILENAME := "user://test837.save"

var _backups := RollingBackups.new()

func before_each() -> void:
	_backups.data_filename = TEMP_FILENAME


func after_each() -> void:
	_backups.delete_all_backups()


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
	FileUtils.write_file(_backups.data_filename, "")
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


## Don't overwrite the 'this_xxx' backups if they already exist
func test_rotate_backups_dont_overwrite_thisxxx() -> void:
	FileUtils.write_file(_backups.data_filename, "new-920")
	FileUtils.write_file(_backups.rolling_filename(RollingBackups.THIS_HOUR), "old-920")
	_backups.rotate_backups()
	
	assert_eq(FileUtils.get_file_as_text(_backups.rolling_filename(RollingBackups.THIS_HOUR)), "old-920")
