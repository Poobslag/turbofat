extends ColorRect
## Popup window which is shown if there is a problem loading the save data.

func _ready() -> void:
	hide()


## Displays a popup window describing the problem loading the save data.
##
## The popup window is populated based on PlayerSave's current state.
func popup() -> void:
	show()
	$Popup.popup()
	
	# Construct a message to show the player. The tone is informal and sympathetic. Hopefully this endears the player
	# toward us because they're going to have a bad day. (Hopefully the backups worked.)
	var message := ""
	if PlayerSave.loaded_backup == -1:
		message += "So... I had some kind of problem loading your save data."
		message += " Unfortunately, none of the backups worked either, so I don't really know how to fix it."
	else:
		message += "So... I had some kind of problem loading your save data,"
		message += " which means you're going to lose some progress."
		match PlayerSave.loaded_backup:
			RollingBackups.THIS_HOUR:
				message += " There was a backup, so at least you'll only lose the last half-hour or so."
			RollingBackups.PREV_HOUR:
				message += " There was a backup, so at least you'll only lose the last hour or so."
			RollingBackups.THIS_DAY:
				message += " There was a backup, but you'll lose everything from the last few hours."
			RollingBackups.PREV_DAY:
				message += " There was a backup, but you'll lose everything from the last day or so."
			RollingBackups.THIS_WEEK:
				message += " There was a backup, but it was pretty old. You'll lose everything from the last few days."
			RollingBackups.PREV_WEEK:
				message += " There was a backup, but it was very old. You'll lose everything from the last week or so."
	message += "\n\n"
	message += "The invalid save data is available in the following path:"
	message += "\n\n"
	
	# convert the 'user://foo1.txt' paths into a useful message like 'C:/abc/def (foo1.txt, foo2.txt)'
	var corrupt_filenames := []
	for corrupt_filename in PlayerSave.corrupt_filenames:
		corrupt_filenames.append(StringUtils.substring_after(corrupt_filename, "user://"))
	message += "%s (%s)" % [OS.get_user_data_dir(), PoolStringArray(corrupt_filenames).join(", ")]
	message += "\n\n"
	message += "I'm really sorry."
	
	$Popup/VBoxContainer/Label.text = message


func _on_Button_pressed() -> void:
	hide()
	$Popup.hide()
