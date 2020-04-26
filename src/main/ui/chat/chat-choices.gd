extends GridContainer
"""
Shows buttons corresponding to dialog branches the player can choose.
"""

# The most branches we can display at once. Branches beyond this will not be displayed.
const MAX_LABELS := 6

export (PackedScene) var ChatOptionButton

# Strings to show the player for each dialog branch.
var _choices := []

# Moods corresponding to each dialog branch; -1 for branches with no mood.
var _moods := []

func _ready() -> void:
	# Remove placeholder buttons
	_refresh_child_buttons()


"""
Repositions the buttons based on the amount of dialog shown.

If a lot of dialog is displayed, the buttons are flush against the right side of the window and narrow. If less dialog
is displayed, the buttons are closer to the center and wider.

Parameters:
	'sentence_size': An enum from ChatAppearance.SentenceSize corresponding to the amount of dialog displayed.
"""
func reposition(sentence_size: int) -> void:
	match(sentence_size):
		ChatAppearance.SentenceSize.SMALL:
			rect_position = Vector2(659, 355)
			rect_size = Vector2(325, 240)
		ChatAppearance.SentenceSize.MEDIUM, ChatAppearance.SentenceSize.LARGE:
			rect_position = Vector2(729, 355)
			rect_size = Vector2(280, 240)
		ChatAppearance.SentenceSize.EXTRA_LARGE:
			rect_position = Vector2(819, 355)
			rect_size = Vector2(200, 240)


"""
Displays a set of buttons corresponding to dialog options.

Parameters:
	'choices': Strings to show the player for each dialog branch.
	
	'moods': An array of ChatEvent.Mood instances for each dialog branch
"""
func show_choices(choices: Array, moods: Array) -> void:
	_choices = choices
	_moods = moods
	
	if _choices.size() > MAX_LABELS:
		push_warning("Too many chat choices: %s > %s" % [choices.size(), MAX_LABELS])
		_choices = choices.slice(0, MAX_LABELS - 1)
	
	columns = 1 if _choices.size() <= 3 else 2
	_refresh_child_buttons()
	
	if choices:
		get_child(0).grab_focus()


"""
Removes all chat option buttons.
"""
func hide_choices() -> void:
	_choices = []
	_refresh_child_buttons()


"""
Returns the player's currently selected choice.
"""
func get_choice() -> int:
	var _choice := -1
	for i in range(_choices.size()):
		var button: ChatOptionButton = get_child(i)
		if button.has_focus():
			_choice = i
	return _choice


"""
Removes and recreates all chat option buttons.
"""
func _refresh_child_buttons() -> void:
	for button in get_children():
		button.queue_free()
	for i in range(_choices.size()):
		var button: ChatOptionButton = ChatOptionButton.instance()
		button.visible = true
		button.set_choice_text(_choices[i])
		button.set_mood(_moods[i])
		button.set_mood_right(i % 2 == 1)
		add_child(button)
