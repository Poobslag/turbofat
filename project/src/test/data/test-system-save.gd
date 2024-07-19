extends GutTest

const TEMP_PLAYER_FILENAME := "user://test253.save"
const TEMP_SYSTEM_FILENAME := "user://test254.json"
const TEMP_LEGACY_FILENAME := "user://test255.save"

func before_each() -> void:
	PlayerSave.data_filename = TEMP_PLAYER_FILENAME
	SystemSave.data_filename = TEMP_SYSTEM_FILENAME
	SystemSave.legacy_filename = TEMP_LEGACY_FILENAME
	SystemData.reset()


func after_each() -> void:
	var dir := Directory.new()
	dir.remove(TEMP_SYSTEM_FILENAME)
	dir.remove(TEMP_LEGACY_FILENAME)
	for backup in [
			RollingBackups.CURRENT,
			RollingBackups.THIS_HOUR, RollingBackups.PREV_HOUR,
			RollingBackups.THIS_DAY, RollingBackups.PREV_DAY,
			RollingBackups.THIS_WEEK, RollingBackups.PREV_WEEK,
			RollingBackups.LEGACY]:
		dir.remove(PlayerSave.rolling_backups.rolling_filename(backup))


func test_save_and_load() -> void:
	SystemData.volume_settings.set_bus_volume_linear(VolumeSettings.MASTER, 0.841)
	SystemData.volume_settings.set_bus_volume_linear(VolumeSettings.MUSIC, 0.695)
	SystemData.volume_settings.set_bus_volume_linear(VolumeSettings.SOUND, 0.279)
	SystemData.volume_settings.set_bus_volume_linear(VolumeSettings.VOICE, 0.405)
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.FASTEST
	SystemSave.save_system_data()
	SystemData.reset()
	SystemSave.load_system_data()
	assert_almost_eq(SystemData.volume_settings.get_bus_volume_linear(VolumeSettings.MASTER), 0.841, 0.001)
	assert_almost_eq(SystemData.volume_settings.get_bus_volume_linear(VolumeSettings.MUSIC), 0.695, 0.001)
	assert_almost_eq(SystemData.volume_settings.get_bus_volume_linear(VolumeSettings.SOUND), 0.279, 0.001)
	assert_almost_eq(SystemData.volume_settings.get_bus_volume_linear(VolumeSettings.VOICE), 0.405, 0.001)
	assert_eq(SystemData.gameplay_settings.speed, GameplaySettings.Speed.FASTEST)
