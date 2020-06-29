extends Node
"""
A demo which shows off the creature's range of emotions

Keys:
	[1]: Default mood
	[Q, W, E, R]: Smile0 (Happy), Smile1 (Love), Laugh0 (Tickled), Laugh1 (Laughing)
	[A, S, D, F]: Think0 (Pensive), Think1 (Confused), Cry0 (Disappointed), Cry1 (Distraught)
	[Z, X, C, V]: Sweat0 (Nervous), Sweat1 (Fidgety), Rage0 (Upset), Rage1 (Rage)
"""

func _input(event: InputEvent) -> void:
	match(Utils.key_scancode(event)):
		KEY_1: $Creature2D.play_mood(ChatEvent.Mood.DEFAULT)
		KEY_Q: $Creature2D.play_mood(ChatEvent.Mood.SMILE0)
		KEY_W: $Creature2D.play_mood(ChatEvent.Mood.SMILE1)
		KEY_E: $Creature2D.play_mood(ChatEvent.Mood.LAUGH0)
		KEY_R: $Creature2D.play_mood(ChatEvent.Mood.LAUGH1)
		KEY_A: $Creature2D.play_mood(ChatEvent.Mood.THINK0)
		KEY_S: $Creature2D.play_mood(ChatEvent.Mood.THINK1)
		KEY_D: $Creature2D.play_mood(ChatEvent.Mood.CRY0)
		KEY_F: $Creature2D.play_mood(ChatEvent.Mood.CRY1)
		KEY_Z: $Creature2D.play_mood(ChatEvent.Mood.SWEAT0)
		KEY_X: $Creature2D.play_mood(ChatEvent.Mood.SWEAT1)
		KEY_C: $Creature2D.play_mood(ChatEvent.Mood.RAGE0)
		KEY_V: $Creature2D.play_mood(ChatEvent.Mood.RAGE1)
