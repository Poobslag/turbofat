extends Node
"""
A demo which shows off the creature's range of emotions and idle animations

Keys:
	[1]: Default mood
	[Q, W, E, R]: Smile0 (Happy), Smile1 (Love), Laugh0 (Tickled), Laugh1 (Laughing)
	[A, S, D, F]: Think0 (Pensive), Think1 (Confused), Cry0 (Disappointed), Cry1 (Distraught)
	[Z, X, C, V]: Sweat0 (Nervous), Sweat1 (Fidgety), Rage0 (Upset), Rage1 (Rage)
	[=]: Make the creature fat
	[brace keys]: Change the creature's appearance
	
	[Shift + Q, W]: Look over shoulder
	[Shift + E, R]: Yawn
	[Shift + A, S]: Close eyes
	[Shift + D, F]: Wiggle ears
"""

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		match(Utils.key_scancode(event)):
			KEY_Q: $Creature.creature_visuals.play_idle_animation("idle-look-over-shoulder0")
			KEY_W: $Creature.creature_visuals.play_idle_animation("idle-look-over-shoulder1")
			KEY_E: $Creature.creature_visuals.play_idle_animation("idle-yawn0")
			KEY_R: $Creature.creature_visuals.play_idle_animation("idle-yawn1")
			KEY_A: $Creature.creature_visuals.play_idle_animation("idle-close-eyes0")
			KEY_S: $Creature.creature_visuals.play_idle_animation("idle-close-eyes1")
			KEY_D: $Creature.creature_visuals.play_idle_animation("idle-ear-wiggle0")
			KEY_F: $Creature.creature_visuals.play_idle_animation("idle-ear-wiggle1")
	else:
		match(Utils.key_scancode(event)):
			KEY_BRACELEFT, KEY_BRACERIGHT: $Creature.dna = DnaUtils.fill_dna(DnaUtils.random_creature_palette())
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
			KEY_EQUAL: $Creature.set_fatness(3)
