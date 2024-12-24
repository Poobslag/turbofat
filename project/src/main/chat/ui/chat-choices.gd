class_name ChatChoices
extends GridContainer
## Shows buttons corresponding to chat branches the player can choose.

signal chat_choice_chosen(choice_index)

## Maximum branches we can display at once. Branches beyond this will not be displayed.
const MAX_LABELS := 6

## Time in seconds for all of the chat choices to pop up.
const TOTAL_POP_IN_DELAY := 0.3

export (PackedScene) var ChatChoiceButtonScene

## Strings to show the player for each chat branch.
var _choices := []

## Moods corresponding to each chat branch; -1 for branches with no mood.
var _moods := []

func _ready() -> void:
	# Remove placeholder buttons
	_refresh_child_buttons()


## Repositions the buttons based on the amount of chat text shown.
##
## If a lot of chat text is displayed, the buttons are flush against the right side of the window and narrow. If less
## chat is displayed, the buttons are closer to the center and wider.
##
## Parameters:
## 	'chat_line_size': Enum from ChatTheme.ChatLineSize corresponding to the amount of chat text displayed.
func reposition(chat_line_size: int) -> void:
	match chat_line_size:
		ChatTheme.LINE_SMALL:
			rect_position = Vector2(659, 355)
			rect_size = Vector2(325, 240)
		ChatTheme.LINE_MEDIUM, ChatTheme.LINE_LARGE:
			rect_position = Vector2(729, 355)
			rect_size = Vector2(280, 240)
		ChatTheme.LINE_XL:
			rect_position = Vector2(819, 355)
			rect_size = Vector2(200, 240)


## Displays a set of buttons corresponding to chat choices.
##
## Parameters:
## 	'choices': Strings to show the player for each chat branch.
##
## 	'moods': An array of Creatures.Mood instances for each chat branch
##
## 	'new_columns': (Optional) Number of columns to organize the chat events into.
func show_choices(choices: Array, moods: Array, new_columns: int = 0) -> void:
	visible = true
	_choices = choices
	_moods = moods
	
	if _choices.size() > MAX_LABELS:
		push_warning("Too many chat choices: %s > %s" % [choices.size(), MAX_LABELS])
		_choices = choices.slice(0, MAX_LABELS - 1)
	
	if new_columns:
		columns = new_columns
	else:
		columns = 1 if _choices.size() <= 3 else 2
	_refresh_child_buttons()
	
	if choices:
		# briefly disable input to prevent the player from mashing through chat choices accidentally
		$EnableInputTimer.start()
		
		# wait for old chat choices to be deleted before grabbing focus
		if is_inside_tree():
			yield(get_tree(), "idle_frame")
		grab_focus()


## Steals the focus from another control and becomes the focused control.
##
## This control itself doesn't have focus, so we delegate to a child control.
func grab_focus() -> void:
	if not is_inside_tree():
		return
	
	for button in get_tree().get_nodes_in_group("chat_choices"):
		button.grab_focus()
		break


func is_showing_choices() -> bool:
	return not _choices.empty()


## Makes all the chat choice buttons disappear.
##
## The chat choice buttons are immediately deleted without any sort of animation.
func hide_choices() -> void:
	visible = false
	_choices = []
	_refresh_child_buttons()


func _delete_old_buttons(old_buttons: Array) -> void:
	var chosen_button: ChatChoiceButton
	for button_object in old_buttons:
		var button: ChatChoiceButton = button_object
		if button.has_focus():
			chosen_button = button
			break
	if chosen_button:
		yield(chosen_button, "pop_choose_completed")
	for button_object in old_buttons:
		var button: ChatChoiceButton = button_object
		button.queue_free()


func _button(node: Node) -> ChatChoiceButton:
	var result: ChatChoiceButton = node if node is Button else null
	return result


## Removes and recreates all chat choice buttons.
func _refresh_child_buttons() -> void:
	if not is_inside_tree():
		return
	
	for child in get_tree().get_nodes_in_group("chat_choices"):
		child.queue_free()
	
	var new_buttons := []
	
	for i in range(_choices.size()):
		var button: ChatChoiceButton = ChatChoiceButtonScene.instance()
		var choice_text: String = _choices[i]
		choice_text = PlayerData.creature_library.substitute_variables(choice_text)
		button.set_choice_text(choice_text)
		button.set_mood(_moods[i])
		button.set_mood_right(i % 2 == 1)
		button.connect("focus_entered", self, "_on_ChatChoiceButton_focus_entered")
		button.connect("pressed", self, "_on_ChatChoiceButton_pressed")
		add_child(button)
		new_buttons.append(button)
	
	var pop_in_delay := TOTAL_POP_IN_DELAY / (new_buttons.size() - 1) if new_buttons.size() >= 2 else 0.0
	if new_buttons.size() >= 4:
		# with four or more buttons, it looks cute if they pop up out-of-order
		new_buttons.shuffle()
	
	for button_object in new_buttons:
		# The button we created could already be deleted if refresh_child_buttons was called again. Surprisingly, it
		# also sometimes randomly changes types, resulting in a transient error: "Trying to assign value of type
		# 'chat-choice-label.gd' to a variable of type 'chat-choice-button.gd'"
		#
		# For these two reasons, we check the type of the object, and check that it's not null
		if is_instance_valid(button_object) and button_object.is_class("ChatChoiceButton"):
			var button: ChatChoiceButton = button_object
			button.pop_in()
			$PopSound.play()
			if is_inside_tree():
				yield(get_tree().create_timer(pop_in_delay), "timeout")


func _on_ChatChoiceButton_focus_entered() -> void:
	$PopSound.play()


## Makes all the chat choice buttons disappear and emits a signal with the player's selected choice.
##
## The chat choice buttons remain as children of this node so they can be animated away.
func _on_ChatChoiceButton_pressed() -> void:
	if not is_inside_tree():
		return
	
	if not $EnableInputTimer.is_stopped():
		# don't let the player mash through chat choices accidentally
		return
	
	var old_buttons := get_tree().get_nodes_in_group("chat_choices")

	# determine the currently selected choice
	var choice_index := -1
	for i in range(old_buttons.size()):
		var button: ChatChoiceButton = old_buttons[i]
		if button.has_focus():
			choice_index = i
			break
	
	# make the buttons animate and disappear
	for button_object in old_buttons:
		var button: ChatChoiceButton = button_object
		if button.has_focus():
			$ChooseSound.play()
			button.pop_choose()
		else:
			button.pop_out()
	
	# delete the buttons after their animations finish, otherwise they steal keyboard focus
	_delete_old_buttons(old_buttons)
	_choices = []
	
	emit_signal("chat_choice_chosen", choice_index)
	if is_inside_tree():
		get_tree().set_input_as_handled()
