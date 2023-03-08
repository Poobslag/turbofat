extends Node
## A demo which shows off the restaurant scene.
##
## Keys:
## 	[F]: Feed the customer
## 	[1-9,0]: Change the customer's size from 10% to 100%
## 	[Q,W,E,R]: Switch to the 1st, 2nd, 3rd or 4th customer.
## 	brace keys: Change the customer's appearance

const FATNESS_KEYS := [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]

onready var _scene: RestaurantPuzzleScene = $RestaurantPuzzleScene

func _ready() -> void:
	for i in range(_scene.get_customers().size()):
		_scene.summon_customer(CreatureLoader.random_customer_def(), i)


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_F: _scene.get_customer().feed(Foods.FoodType.BROWN_0)
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			_scene.get_customer().set_fatness(FATNESS_KEYS[Utils.key_num(event)])
		KEY_BRACKETLEFT, KEY_BRACKETRIGHT:
			_scene.summon_customer(CreatureLoader.random_customer_def())
		KEY_Q: _scene.current_customer_index = 0
		KEY_W: _scene.current_customer_index = 1
		KEY_E: _scene.current_customer_index = 2
		KEY_R: _scene.current_customer_index = 3
