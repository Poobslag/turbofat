extends Node
## Demonstrates the restaurant view.
##
## Keys:
## 	[D]: Ring the doorbell
## 	[F]: Feed the customer
## 	[I]: Launch an idle animation
## 	[V]: Say something
## 	[N]: Change the nametag names
## 	[1-9,0]: Change the customer's size from 10% to 100%
## 	[O]: Increase customer's size by 10%
## 	[P]: Change the customer's size to 1000%
## 	Shift + [1-9,0]: Change the customer's comfort from 0.0 -> 1.0 -> -1.0
## 	[Q,W,E,R]: Switch to the 1st, 2nd, 3rd or 4th customer.
## 	Shift + [,/.]: Swoop the customer/chef to be onscreen
## 	Shift + [,/.]: Swoop the customer/chef to be offscreen
## 	Arrows: Change the customer's orientation
## 	Brace keys: Change the customer's appearance

const FATNESS_KEYS := [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]
const NAMES := [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore" \
		+ " magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea" \
		+ " commodo consequat.",
	"",
	"Lo",
	"Lorem",
	"Lorem ipsum",
	"Lorem ipsum dolor",
	"Lorem ipsum dolor sit amet",
	"Lorem ipsum dolor sit amet, consectetur",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidid",
]

var _current_name_index := 4

onready var _view: RestaurantView = $RestaurantView
onready var _restaurant_scene := $RestaurantView/RestaurantViewport/Scene

func _ready() -> void:
	for i in range(_view.get_customers().size()):
		_view.summon_customer(i)


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_D: _restaurant_scene.play_door_chime()
		KEY_F: _customer().feed(Foods.FoodType.BROWN_0)
		KEY_I: _customer().creature_visuals.get_node("Animations/IdleTimer").start(0.01)
		KEY_N:
			_current_name_index = (_current_name_index + 1) % NAMES.size()
			_customer().creature_name = NAMES[_current_name_index]
			_chef().creature_name = NAMES[_current_name_index]
		KEY_V:
			_customer().get_node("CreatureSfx").play_goodbye_voice()
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			if Input.is_key_pressed(KEY_SHIFT):
				# shift pressed; change customer's comfort
				match Utils.key_scancode(event):
					KEY_1: _view.get_customer().set_comfort(0.00) # hasn't eaten
					KEY_2: _view.get_customer().set_comfort(0.30)
					KEY_3: _view.get_customer().set_comfort(0.60)
					KEY_4: _view.get_customer().set_comfort(1.00) # ate enough
					KEY_5: _view.get_customer().set_comfort(-0.10) # starting to overeat
					KEY_6: _view.get_customer().set_comfort(-0.30)
					KEY_7: _view.get_customer().set_comfort(-0.50) # ate too much
					KEY_8: _view.get_customer().set_comfort(-0.70)
					KEY_9: _view.get_customer().set_comfort(-0.90)
					KEY_0: _view.get_customer().set_comfort(-1.00) # ate way too much
			else:
				# shift not pressed; change customer's fatness
				_view.get_customer().fatness = FATNESS_KEYS[Utils.key_num(event)]
		KEY_O:
			_view.get_customer().fatness += 1.0
		KEY_P:
			_view.get_customer().fatness = 100.0
		KEY_Q: _view.set_current_customer_index(0)
		KEY_W: _view.set_current_customer_index(1)
		KEY_E: _view.set_current_customer_index(2)
		KEY_R: _view.set_current_customer_index(3)
		KEY_BRACKETLEFT, KEY_BRACKETRIGHT:
			_view.summon_customer()
		KEY_RIGHT:
			_view.get_customer().set_orientation(Creatures.SOUTHEAST)
		KEY_DOWN:
			_view.get_customer().set_orientation(Creatures.SOUTHWEST)
		KEY_LEFT:
			_view.get_customer().set_orientation(Creatures.NORTHWEST)
		KEY_UP:
			_view.get_customer().set_orientation(Creatures.NORTHEAST)
		KEY_COMMA:
			if Input.is_key_pressed(KEY_SHIFT):
				_view.swoop_customer_bubble_offscreen()
			else:
				_view.swoop_customer_bubble_onscreen()
		KEY_PERIOD:
			if Input.is_key_pressed(KEY_SHIFT):
				_view.swoop_chef_bubble_offscreen()
			else:
				_view.swoop_chef_bubble_onscreen()


func _customer() -> Creature:
	return _restaurant_scene.get_customer()


func _chef() -> Creature:
	return _restaurant_scene.get_chef()
