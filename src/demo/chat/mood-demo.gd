extends Spatial
"""
A demo which shows off the creature's range of emotions

Keys:
	[1]: Default mood
	[Q, W, E, R]: Smile0 (Happy), Smile1 (Love), Laugh0 (Tickled), Laugh1 (Laughing)
	[A, S, D, F]: Think0 (Pensive), Think1 (Confused), Cry0 (Disappointed), Cry1 (Distraught)
	[Z, X, C, V]: Sweat0 (Nervous), Sweat1 (Fidgety), Rage0 (Upset), Rage1 (Rage)
"""

func _input(event: InputEvent) -> void:
	match(Global.key_scancode(event)):
		KEY_1: $Creature.play_mood(ChatEvent.Mood.DEFAULT)
		KEY_Q: $Creature.play_mood(ChatEvent.Mood.SMILE0)
		KEY_W: $Creature.play_mood(ChatEvent.Mood.SMILE1)
		KEY_E: $Creature.play_mood(ChatEvent.Mood.LAUGH0)
		KEY_R: $Creature.play_mood(ChatEvent.Mood.LAUGH1)
		KEY_A: $Creature.play_mood(ChatEvent.Mood.THINK0)
		KEY_S: $Creature.play_mood(ChatEvent.Mood.THINK1)
		KEY_D: $Creature.play_mood(ChatEvent.Mood.CRY0)
		KEY_F: $Creature.play_mood(ChatEvent.Mood.CRY1)
		KEY_Z: $Creature.play_mood(ChatEvent.Mood.SWEAT0)
		KEY_X: $Creature.play_mood(ChatEvent.Mood.SWEAT1)
		KEY_C: $Creature.play_mood(ChatEvent.Mood.RAGE0)
		KEY_V: $Creature.play_mood(ChatEvent.Mood.RAGE1)
