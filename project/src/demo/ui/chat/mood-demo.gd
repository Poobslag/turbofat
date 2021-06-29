extends Node
"""
A demo which shows off the creature's range of emotions and idle animations

Keys:
	[1]: Default mood
	
	[Q, W, E, R]: Awkward0 (Uncomfortable), Awkward1 (Embarrassed), Cry0 (Disappointed), Cry1 (Distraught)
	[T, Y, U, I, 8]: Laugh0 (Tickled), Laugh1 (Laughing), Love0 (Heart Eyes), Love1 (Dreamy Love), Love1 Forever
	[O, P]: No0 (Head Shake), No1 (More Shakes)
	
	[A, S, D, F, G]: Rage0 (Annoyed), Rage1 (Angry), Rage2 (Murderous), Sigh0 (Ugh), Sigh1 (Eyeroll)
	[H, J, K, L]: Smile0 (Happy), Smile1 (Sweet), Sweat0 (Nervous), Sweat1 (Fidgety)
	
	[Z, X, C, V]: Think0 (Pensive), Think1 (Confused), Wave0 (Polite), Wave1 (Friendly)
	[B, N]: Yes0 (Nod), Yes1 (More Nods)
	
	[Shift + T]: Talk
	[=]: Make the creature fat
	[space bar]: Feed
	[brace keys]: Change the creature's appearance
	[Shift + /]: Print DNA
	
	[Shift + Q, W]: Look over shoulder
	[Shift + E, R]: Yawn
	[Shift + A, S]: Close eyes
	[Shift + D, F]: Wiggle ears
"""

onready var _creature_animations: CreatureAnimations = $Creature.creature_visuals.get_node("Animations")

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		match Utils.key_scancode(event):
			KEY_Q: _creature_animations.play_idle_animation("idle-look-over-shoulder0")
			KEY_W: _creature_animations.play_idle_animation("idle-look-over-shoulder1")
			KEY_E: _creature_animations.play_idle_animation("idle-yawn0")
			KEY_R: _creature_animations.play_idle_animation("idle-yawn1")
			KEY_A: _creature_animations.play_idle_animation("idle-close-eyes0")
			KEY_S: _creature_animations.play_idle_animation("idle-close-eyes1")
			KEY_D: _creature_animations.play_idle_animation("idle-ear-wiggle0")
			KEY_F: _creature_animations.play_idle_animation("idle-ear-wiggle1")
			KEY_T: $Creature.talk()
			KEY_SLASH: print(to_json($Creature.dna))
	else:
		match Utils.key_scancode(event):
			KEY_BRACELEFT, KEY_BRACERIGHT: $Creature.dna = DnaUtils.random_dna()
			
			KEY_1: $Creature.play_mood(ChatEvent.Mood.DEFAULT)
			KEY_Q: $Creature.play_mood(ChatEvent.Mood.AWKWARD0)
			KEY_W: $Creature.play_mood(ChatEvent.Mood.AWKWARD1)
			KEY_E: $Creature.play_mood(ChatEvent.Mood.CRY0)
			KEY_R: $Creature.play_mood(ChatEvent.Mood.CRY1)
			KEY_T: $Creature.play_mood(ChatEvent.Mood.LAUGH0)
			KEY_Y: $Creature.play_mood(ChatEvent.Mood.LAUGH1)
			KEY_U: $Creature.play_mood(ChatEvent.Mood.LOVE0)
			KEY_I: $Creature.play_mood(ChatEvent.Mood.LOVE1)
			KEY_8: $Creature.play_mood(ChatEvent.Mood.LOVE1_FOREVER)
			KEY_O: $Creature.play_mood(ChatEvent.Mood.NO0)
			KEY_P: $Creature.play_mood(ChatEvent.Mood.NO1)
			KEY_A: $Creature.play_mood(ChatEvent.Mood.RAGE0)
			KEY_S: $Creature.play_mood(ChatEvent.Mood.RAGE1)
			KEY_D: $Creature.play_mood(ChatEvent.Mood.RAGE2)
			KEY_F: $Creature.play_mood(ChatEvent.Mood.SIGH0)
			KEY_G: $Creature.play_mood(ChatEvent.Mood.SIGH1)
			KEY_H: $Creature.play_mood(ChatEvent.Mood.SMILE0)
			KEY_J: $Creature.play_mood(ChatEvent.Mood.SMILE1)
			KEY_K: $Creature.play_mood(ChatEvent.Mood.SWEAT0)
			KEY_L: $Creature.play_mood(ChatEvent.Mood.SWEAT1)
			KEY_Z: $Creature.play_mood(ChatEvent.Mood.THINK0)
			KEY_X: $Creature.play_mood(ChatEvent.Mood.THINK1)
			KEY_C: $Creature.play_mood(ChatEvent.Mood.WAVE0)
			KEY_V: $Creature.play_mood(ChatEvent.Mood.WAVE1)
			KEY_B: $Creature.play_mood(ChatEvent.Mood.YES0)
			KEY_N: $Creature.play_mood(ChatEvent.Mood.YES1)
			KEY_SPACE: $Creature.feed(FoodItem.FoodType.BROWN_0)
			KEY_EQUAL: $Creature.set_fatness(3)
