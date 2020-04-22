extends Spatial
"""
A demo which shows off the customer's range of emotions

Keys:
	[1]: DEFAULT
	[Q, W, E, R]: Smile0 (Happy), Smile1 (Love), Laugh0 (Tickled), Laugh1 (Laughing)
	[A, S, D, F]: Think0 (Pensive), Think1 (Confused), Cry0 (Disappointed), Cry1 (Distraught)
	[Z, X, C, V]: Sweat0 (Nervous), Sweat1 (Fidgety), Rage0 (Upset), Rage1 (Rage)
"""

func _input(event: InputEvent) -> void:
	var scancode: int
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	match(scancode):
		KEY_1: $Customer.play_mood(ChatEvent.Mood.DEFAULT)
		KEY_Q: $Customer.play_mood(ChatEvent.Mood.SMILE0)
		KEY_W: $Customer.play_mood(ChatEvent.Mood.SMILE1)
		KEY_E: $Customer.play_mood(ChatEvent.Mood.LAUGH0)
		KEY_R: $Customer.play_mood(ChatEvent.Mood.LAUGH1)
		KEY_A: $Customer.play_mood(ChatEvent.Mood.THINK0)
		KEY_S: $Customer.play_mood(ChatEvent.Mood.THINK1)
		KEY_D: $Customer.play_mood(ChatEvent.Mood.CRY0)
		KEY_F: $Customer.play_mood(ChatEvent.Mood.CRY1)
		KEY_Z: $Customer.play_mood(ChatEvent.Mood.SWEAT0)
		KEY_X: $Customer.play_mood(ChatEvent.Mood.SWEAT1)
		KEY_C: $Customer.play_mood(ChatEvent.Mood.RAGE0)
		KEY_V: $Customer.play_mood(ChatEvent.Mood.RAGE1)
