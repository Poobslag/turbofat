extends Node
## Demo which shows off the creature's range of emotions and idle animations
##
## Keys:
## 	[1]: Default mood
##
## 	[Q, W, E, R]: Awkward0 (Uncomfortable), Awkward1 (Embarrassed), Cry0 (Disappointed), Cry1 (Distraught)
## 	[T, Y, U, I, 8]: Laugh0 (Tickled), Laugh1 (Laughing), Love0 (Heart Eyes), Love1 (Dreamy Love), Love1 Forever
## 	[O, P]: No0 (Head Shake), No1 (More Shakes)
##
## 	[A, S, D, F, G]: Rage0 (Annoyed), Rage1 (Angry), Rage2 (Murderous), Sigh0 (Ugh), Sigh1 (Eyeroll)
## 	[H, J, K, L]: Sly0 (Scheming), Sly1 (Malicious), Smile0 (Happy), Smile1 (Sweet)
##
## 	[Z, X, C, V]: Sweat0 (Nervous), Sweat1 (Fidgety), Think0 (Pensive), Think1 (Confused)
## 	[B, N, M, comma, period]: Wave0 (neutral), Wave1 (Polite), Wave2 (Friendly), Yes0 (Nod), Yes1 (More Nods)
##
## 	[Shift + T]: Talk
## 	[=]: Make the creature fat
## 	[space bar]: Feed
## 	[brace keys]: Change the creature's appearance
## 	[Shift + /]: Print DNA
##
## 	[Shift + Q, W]: Look over shoulder
## 	[Shift + E, R]: Yawn
## 	[Shift + A, S]: Close eyes
## 	[Shift + D, F]: Wiggle ears
##
## 	[Ctrl + 0]: Change the creature's demographic to 'default'
## 	[Ctrl + 1]: Change the creature's demographic to 'squirrel'

var _creature_type: int = Creatures.Type.DEFAULT

## local path to a json creature resource to demo
@export (String, FILE, "*.json") var creature_path: String

@onready var _creature := $Creature
@onready var _creature_animations: CreatureAnimations = $Creature.creature_visuals.get_node("Animations")

func _ready() -> void:
	if creature_path:
		_creature.creature_def = CreatureDef.new().from_json_path(creature_path)


func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_CTRL):
		match Utils.key_scancode(event):
			KEY_0: _change_demographic(Creatures.Type.DEFAULT)
			KEY_1: _change_demographic(Creatures.Type.SQUIRREL)
	elif Input.is_key_pressed(KEY_SHIFT):
		match Utils.key_scancode(event):
			KEY_Q: _creature_animations.play_idle_animation("idle-look-over-shoulder0")
			KEY_W: _creature_animations.play_idle_animation("idle-look-over-shoulder1")
			KEY_E: _creature_animations.play_idle_animation("idle-yawn0")
			KEY_R: _creature_animations.play_idle_animation("idle-yawn1")
			KEY_A: _creature_animations.play_idle_animation("idle-close-eyes0")
			KEY_S: _creature_animations.play_idle_animation("idle-close-eyes1")
			KEY_D: _creature_animations.play_idle_animation("idle-ear-wiggle0")
			KEY_F: _creature_animations.play_idle_animation("idle-ear-wiggle1")
			KEY_T: _creature.talk()
			KEY_SLASH: print(JSON.new().stringify(_creature.dna))
	else:
		match Utils.key_scancode(event):
			KEY_BRACKETLEFT, KEY_BRACKETRIGHT:
				_creature.dna = DnaUtils.random_dna(_creature_type)
				_randomize_creature()
			
			KEY_1: _creature.play_mood(Creatures.Mood.DEFAULT)
			KEY_Q: _creature.play_mood(Creatures.Mood.AWKWARD0)
			KEY_W: _creature.play_mood(Creatures.Mood.AWKWARD1)
			KEY_E: _creature.play_mood(Creatures.Mood.CRY0)
			KEY_R: _creature.play_mood(Creatures.Mood.CRY1)
			KEY_T: _creature.play_mood(Creatures.Mood.LAUGH0)
			KEY_Y: _creature.play_mood(Creatures.Mood.LAUGH1)
			KEY_U: _creature.play_mood(Creatures.Mood.LOVE0)
			KEY_I: _creature.play_mood(Creatures.Mood.LOVE1)
			KEY_8: _creature.play_mood(Creatures.Mood.LOVE1_FOREVER)
			KEY_O: _creature.play_mood(Creatures.Mood.NO0)
			KEY_P: _creature.play_mood(Creatures.Mood.NO1)
			KEY_A: _creature.play_mood(Creatures.Mood.RAGE0)
			KEY_S: _creature.play_mood(Creatures.Mood.RAGE1)
			KEY_D: _creature.play_mood(Creatures.Mood.RAGE2)
			KEY_F: _creature.play_mood(Creatures.Mood.SIGH0)
			KEY_G: _creature.play_mood(Creatures.Mood.SIGH1)
			KEY_H: _creature.play_mood(Creatures.Mood.SLY0)
			KEY_J: _creature.play_mood(Creatures.Mood.SLY1)
			KEY_K: _creature.play_mood(Creatures.Mood.SMILE0)
			KEY_L: _creature.play_mood(Creatures.Mood.SMILE1)
			KEY_Z: _creature.play_mood(Creatures.Mood.SWEAT0)
			KEY_X: _creature.play_mood(Creatures.Mood.SWEAT1)
			KEY_C: _creature.play_mood(Creatures.Mood.THINK0)
			KEY_V: _creature.play_mood(Creatures.Mood.THINK1)
			KEY_B: _creature.play_mood(Creatures.Mood.WAVE0)
			KEY_N: _creature.play_mood(Creatures.Mood.WAVE1)
			KEY_M: _creature.play_mood(Creatures.Mood.WAVE2)
			KEY_COMMA: _creature.play_mood(Creatures.Mood.YES0)
			KEY_PERIOD: _creature.play_mood(Creatures.Mood.YES1)
			KEY_SPACE: _creature.feed(Foods.FoodType.BROWN_0)
			KEY_EQUAL: _creature.set_fatness(3)


func _change_demographic(demographic_type: int) -> void:
	_creature_type = demographic_type
	_randomize_creature()


func _randomize_creature() -> void:
	_creature.dna = DnaUtils.random_dna(_creature_type)
	_creature.set_fatness(Utils.rand_value(Global.FATNESSES))
