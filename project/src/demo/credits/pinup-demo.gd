extends Node
## Keys:
## 	[0-9]: Change the creature's fatness
## 	[B]: Assign a random background color
## 	[R]: Reset
## 	[T]: Transform
## 	[C]: Load a random creature
## 	[M]: Play a random mood
## 	Arrows: Change the creature's orientation
## 	Brace keys: Change the creature's appearance

const FATNESS_KEYS := [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]

export (String) var creature_id: String

onready var _pinup := $Pinup

func _ready() -> void:
	if creature_id:
		_pinup.creature.suppress_fatness = true
		_pinup.creature_id = creature_id
	else:
		_randomize_creature()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_B:
			var random_color := Color.from_hsv(
					Utils.rand_value([0.02, 0.10, 0.18, 0.24, 0.47, 0.55, 0.67, 0.79]),
					Utils.rand_value([0.3, 0.4, 0.5, 0.6]),
					Utils.rand_value([0.5, 0.7, 0.9]),
					1.0)
			_pinup.bg_color = random_color
		KEY_C:
			_pinup.creature_id = Utils.rand_value([
					"alyssa",
					"chelle",
					"goldfince",
					"goris",
					"jaco",
					"mcgoat",
					"rice",
					"shirts",
			])
		KEY_M:
			_pinup.play_mood(Utils.rand_value([
					Creatures.Mood.CRY0,
					Creatures.Mood.LAUGH0,
					Creatures.Mood.LOVE0,
					Creatures.Mood.RAGE0,
					Creatures.Mood.RAGE2,
					Creatures.Mood.SMILE0,
					Creatures.Mood.SWEAT1,
					Creatures.Mood.WAVE0,
					]))
		KEY_R:
			_pinup.reset()
		KEY_T:
			_pinup.transform()
		KEY_LEFT:
			_pinup.orientation = Creatures.Orientation.SOUTHWEST
		KEY_RIGHT:
			_pinup.orientation = Creatures.Orientation.SOUTHEAST
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			_pinup.creature.fatness = FATNESS_KEYS[Utils.key_num(event)]
		KEY_BRACKETLEFT, KEY_BRACKETRIGHT:
			_randomize_creature()


func _randomize_creature() -> void:
	_pinup.creature.creature_name = NameGeneratorLibrary.generate_name()
	_pinup.creature.dna = DnaUtils.random_dna()
	_pinup.creature.chat_theme = CreatureLoader.chat_theme(_pinup.creature.dna)
	_pinup.creature.fatness = Utils.rand_value(Global.FATNESSES)
	_pinup.creature.visual_fatness = _pinup.creature.fatness
