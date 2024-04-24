extends TabContainer
## Top-level tab container for the settings menu.

export (bool) var loop_selection: bool = true
var focused: bool = false


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
	
	focus_mode = Control.FOCUS_ALL
	get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")
	
	_on_focus_changed(get_focus_owner())


func _on_focus_changed(node):
	if node == self:
		focused = true
		set("custom_colors/font_color_fg", Color("f0f0f0"))
		get("custom_styles/tab_fg").bg_color = Color("2d5e73")
	else:
		if focused:
			focused = false
			set("custom_colors/font_color_fg", null)
			get("custom_styles/tab_fg").bg_color = Color("332d2d")


func _unhandled_input(event):
	if focused:
		var tab = current_tab
		if event.is_action_pressed("ui_left"):
			tab -= 1
		elif event.is_action_pressed("ui_right"):
			tab += 1
		
		if loop_selection:
			current_tab = (get_child_count() + tab) % get_child_count()
		else:
			current_tab = clamp(tab, 0, get_child_count())
