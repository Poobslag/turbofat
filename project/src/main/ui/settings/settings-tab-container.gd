extends TabContainer
## Top-level tab container for the settings menu.

## Override the default tab names with localized names.
##
## By default, Godot uses node names for tab titles. Node names don't get extracted with pybabel and can't be
## translated with gettext. Explicitly setting the tab titles addresses both of these problems.
func _ready() -> void:
	set_tab_title(0, tr("Sound + Graphics"))
	set_tab_title(1, tr("Gameplay"))
	set_tab_title(2, tr("Controls"))
	set_tab_title(3, tr("Touch"))
	set_tab_title(4, tr("Miscellaneous"))
