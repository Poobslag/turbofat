"""
Handles animations and audio/visual effects for a customer.
"""
extends Node2D

var tex_ear_z0_1: Texture = preload("res://art/customer/ear-z0-1.png")
var tex_ear_z0_2: Texture = preload("res://art/customer/ear-z0-2.png")
var tex_ear_z1_0: Texture = preload("res://art/customer/ear-z1-0.png")
var tex_ear_z1_1: Texture = preload("res://art/customer/ear-z1-1.png")
var tex_ear_z1_2: Texture = preload("res://art/customer/ear-z1-2.png")
var tex_ear_z2_0: Texture = preload("res://art/customer/ear-z2-0.png")
var tex_ear_z2_1: Texture = preload("res://art/customer/ear-z2-1.png")
var tex_ear_z2_2: Texture = preload("res://art/customer/ear-z2-2.png")
var tex_ear_z2_outline_0: Texture = preload("res://art/customer/ear-z2-outline-0.png")
var tex_ear_z2_outline_1: Texture = preload("res://art/customer/ear-z2-outline-1.png")
var tex_ear_z2_outline_2: Texture = preload("res://art/customer/ear-z2-outline-2.png")

var tex_horn_outline_2: Texture = preload("res://art/customer/horn-outline-2.png")
var tex_horn_1: Texture = preload("res://art/customer/horn-1.png")
var tex_horn_2: Texture = preload("res://art/customer/horn-2.png")

var tex_mouth_0: Texture = preload("res://art/eat-anim/mouth-sheet-0.png")
var tex_mouth_outline_0: Texture = preload("res://art/eat-anim/mouth-outline-sheet-0.png")
var tex_food_0: Texture = preload("res://art/eat-anim/food-sheet-0.png")
var tex_food_laser_0: Texture = preload("res://art/eat-anim/food-laser-sheet-0.png")
var tex_mouth_1: Texture = preload("res://art/eat-anim/mouth-sheet-1.png")
var tex_mouth_outline_1: Texture = preload("res://art/eat-anim/mouth-outline-sheet-1.png")
var tex_food_1: Texture = preload("res://art/eat-anim/food-sheet-1.png")
var tex_food_laser_1: Texture = preload("res://art/eat-anim/food-laser-sheet-1.png")

var tex_eye_0: Texture = preload("res://art/eat-anim/eyes-sheet-0.png")
var tex_eye_1: Texture = preload("res://art/eat-anim/eyes-sheet-1.png")
var tex_eye_2: Texture = preload("res://art/eat-anim/eyes-sheet-2.png")
var tex_eye_outline_0: Texture = preload("res://art/eat-anim/eyes-outline-sheet-0.png")
var tex_eye_outline_1: Texture = preload("res://art/eat-anim/eyes-outline-sheet-1.png")
var tex_eye_outline_2: Texture = preload("res://art/eat-anim/eyes-outline-sheet-2.png")

# food colors for the food which gets hurled into the customer's mouth
const FOOD_COLORS: Array = [
	Color("a4470b"), # brown
	Color("ff5d68"), # pink
	Color("ffa357"), # bread
	Color("fff6eb") # white
]

# signal emitted on the frame when the food is launched into the customer's mouth
signal food_eaten

# sounds which get played when the customer eats
onready var _munch_sounds:Array = [
	$Munch0,
	$Munch1,
	$Munch2,
	$Munch3,
	$Munch4
]

# the food object which should be animated and recolored when we eat
onready var _food = get_node("../KludgeCustomer/KludgeNeck0/KludgeNeck1/Food")
onready var _food_laser = get_node("../KludgeCustomer/KludgeNeck0/KludgeNeck1/FoodLaser")

# the total number of seconds which have elapsed since the object was created
var _total_seconds := 0.0

# the creature's head bobs up and down slowly, these fields control how much it bobs
var _head_bob_seconds := 6.5
var _head_bob_pixels := 2

# the index of the previously launched food color. stored to avoid showing the same color twice consecutively
var _food_color_index := 0

onready var _mouth_animation_player := $Mouth1Anims
onready var _eye_animation_player := $Eye0Anims

func _process(delta: float) -> void:
	_total_seconds += delta
	
	if !_mouth_animation_player.is_playing():
		_mouth_animation_player.play("Ambient")
	if !_eye_animation_player.is_playing():
		_eye_animation_player.play("Ambient")
	
	$Neck0/Neck1.position.y = -100 + _head_bob_pixels * sin((_total_seconds * 2 * PI) / _head_bob_seconds)

"""
Launches the 'feed' animation, hurling a piece of food at the customer and having them catch it.
"""
func feed() -> void:
	if _mouth_animation_player.current_animation == "Eat" || _mouth_animation_player.current_animation == "EatAgain":
		_mouth_animation_player.stop()
		_mouth_animation_player.play("EatAgain")
		_eye_animation_player.stop()
		_eye_animation_player.play("EatAgain")
		show_food_effects()
	else:
		_mouth_animation_player.play("Eat")
		_eye_animation_player.play("Eat")
		show_food_effects(0.066)

"""
If the specified key is not associated with a value, this method associates it with the given value.
"""
func put_if_absent(customer_def: Dictionary, key: String, value) -> void:
	if !customer_def.has(key):
		customer_def[key] = value

"""
Recolors the customer according to the specified color definition. This involves updating shaders and sprite
properties.

Parameter: 'customer_def' describes the sprites to recolor and how to recolor them.
"""
func recolor(customer_def: Dictionary) -> void:
	# duplicate the customer_def; we append to it and don't want to alter the original
	customer_def = customer_def.duplicate()

	# stop any AnimationPlayers, otherwise two AnimationPlayers might fight over control of the sprite
	_mouth_animation_player.stop()
	_eye_animation_player.stop()
	
	# reset the mouth/eye frames, otherwise we could have one strange transition frame
	$Neck0Outline/Neck1Outline/MouthOutline.frame = 0
	$Neck0/Neck1/Mouth.frame = 0
	$Neck0Outline/Neck1Outline/EyesOutline.frame = 0
	$Neck0/Neck1/Eyes.frame = 0
	
	put_if_absent(customer_def, "line_rgb", "6c4331")
	put_if_absent(customer_def, "body_rgb", "b23823")
	put_if_absent(customer_def, "eye_rgb", "282828 dedede")
	put_if_absent(customer_def, "horn_rgb", "f1e398")
	
	put_if_absent(customer_def, "eye", ["0", "0", "0", "1", "2"][randi() % 5])
	put_if_absent(customer_def, "ear", ["0", "0", "0", "1", "2"][randi() % 5])
	put_if_absent(customer_def, "horn", ["0", "0", "0", "1", "2"][randi() % 5])
	put_if_absent(customer_def, "mouth", ["0", "0", "1"][randi() % 3])
	
	print("recolor: %s" % customer_def)
	
	if customer_def.ear == "0":
		customer_def["property:Neck0/Neck1/EarZ0:texture"] = null
		customer_def["property:Neck0/Neck1/EarZ1:texture"] = tex_ear_z1_0
		customer_def["property:Neck0/Neck1/EarZ2:texture"] = tex_ear_z2_0
		customer_def["property:Neck0Outline/Neck1Outline/EarZ0Outline:texture"] = null
		customer_def["property:Neck0Outline/Neck1Outline/EarZ1Outline:texture"] = null
		customer_def["property:Neck0Outline/Neck1Outline/EarZ2Outline:texture"] = tex_ear_z2_outline_0
	elif customer_def.ear == "1":
		customer_def["property:Neck0/Neck1/EarZ0:texture"] = tex_ear_z0_1
		customer_def["property:Neck0/Neck1/EarZ1:texture"] = tex_ear_z1_1
		customer_def["property:Neck0/Neck1/EarZ2:texture"] = tex_ear_z2_1
		customer_def["property:Neck0Outline/Neck1Outline/EarZ0Outline:texture"] = null
		customer_def["property:Neck0Outline/Neck1Outline/EarZ1Outline:texture"] = null
		customer_def["property:Neck0Outline/Neck1Outline/EarZ2Outline:texture"] = tex_ear_z2_outline_1
	elif customer_def.ear == "2":
		customer_def["property:Neck0/Neck1/EarZ0:texture"] = tex_ear_z0_2
		customer_def["property:Neck0/Neck1/EarZ1:texture"] = tex_ear_z1_2
		customer_def["property:Neck0/Neck1/EarZ2:texture"] = tex_ear_z2_2
		customer_def["property:Neck0Outline/Neck1Outline/EarZ0Outline:texture"] = null
		customer_def["property:Neck0Outline/Neck1Outline/EarZ1Outline:texture"] = null
		customer_def["property:Neck0Outline/Neck1Outline/EarZ2Outline:texture"] = tex_ear_z2_outline_2
	else:
		print("Invalid ear: %s" % customer_def.ear)
	
	if customer_def.horn == "0":
		customer_def["property:Neck0/Neck1/Horn:texture"] = null
		customer_def["property:Neck0Outline/Neck1Outline/HornOutline:texture"] = null
	elif customer_def.horn == "1":
		customer_def["property:Neck0/Neck1/Horn:texture"] = tex_horn_1
		customer_def["property:Neck0Outline/Neck1Outline/HornOutline:texture"] = null
	elif customer_def.horn == "2":
		customer_def["property:Neck0/Neck1/Horn:texture"] = tex_horn_2
		customer_def["property:Neck0Outline/Neck1Outline/HornOutline:texture"] = tex_horn_outline_2
	else:
		print("Invalid horn: %s" % customer_def.horn)
	
	if customer_def.mouth == "0":
		_mouth_animation_player = $Mouth0Anims
		customer_def["property:Neck0/Neck1/Mouth:texture"] = tex_mouth_0
		customer_def["property:Neck0Outline/Neck1Outline/MouthOutline:texture"] = tex_mouth_outline_0
		customer_def["property:../KludgeCustomer/KludgeNeck0/KludgeNeck1/Food:texture"] = tex_food_0
		customer_def["property:../KludgeCustomer/KludgeNeck0/KludgeNeck1/FoodLaser:texture"] = tex_food_laser_0
	elif customer_def.mouth == "1":
		_mouth_animation_player = $Mouth1Anims
		customer_def["property:Neck0/Neck1/Mouth:texture"] = tex_mouth_1
		customer_def["property:Neck0Outline/Neck1Outline/MouthOutline:texture"] = tex_mouth_outline_1
		customer_def["property:../KludgeCustomer/KludgeNeck0/KludgeNeck1/Food:texture"] = tex_food_1
		customer_def["property:../KludgeCustomer/KludgeNeck0/KludgeNeck1/FoodLaser:texture"] = tex_food_laser_1
	else:
		print("Invalid mouth: %s" % customer_def.mouth)
	
	if customer_def.eye == "0":
		customer_def["property:Neck0/Neck1/Eyes:texture"] = tex_eye_0
		customer_def["property:Neck0Outline/Neck1Outline/EyesOutline:texture"] = tex_eye_outline_0
	elif customer_def.eye == "1":
		customer_def["property:Neck0/Neck1/Eyes:texture"] = tex_eye_1
		customer_def["property:Neck0Outline/Neck1Outline/EyesOutline:texture"] = tex_eye_outline_1
	elif customer_def.eye == "2":
		customer_def["property:Neck0/Neck1/Eyes:texture"] = tex_eye_2
		customer_def["property:Neck0Outline/Neck1Outline/EyesOutline:texture"] = tex_eye_outline_2
	else:
		print("Invalid eye: %s" % customer_def.eye)
	
	var line_color = Color(customer_def.line_rgb)
	customer_def["shader:FarArmOutline:black"] = line_color
	customer_def["shader:FarLegOutline:black"] = line_color
	customer_def["property:BodyOutline:line_color"] = line_color
	customer_def["shader:NearLegOutline:black"] = line_color
	customer_def["shader:NearArmOutline:black"] = line_color
	customer_def["shader:Neck0Outline/Neck1Outline/EarZ0Outline:black"] = line_color
	customer_def["shader:Neck0Outline/Neck1Outline/HeadOutline:black"] = line_color
	customer_def["shader:Neck0Outline/Neck1Outline/EarZ1Outline:black"] = line_color
	customer_def["shader:Neck0Outline/Neck1Outline/HornOutline:black"] = line_color
	customer_def["shader:Neck0Outline/Neck1Outline/EarZ2Outline:black"] = line_color
	customer_def["shader:Neck0Outline/Neck1Outline/MouthOutline:black"] = line_color
	customer_def["shader:Neck0Outline/Neck1Outline/EyesOutline:black"] = line_color
	customer_def["shader:FarArm:black"] = line_color
	customer_def["shader:FarLeg:black"] = line_color
	customer_def["property:Body:line_color"] = line_color
	customer_def["shader:NearArm:black"] = line_color
	customer_def["shader:NearLeg:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ0:black"] = line_color
	customer_def["shader:Neck0/Neck1/Head:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ1:black"] = line_color
	customer_def["shader:Neck0/Neck1/Horn:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ2:black"] = line_color
	customer_def["shader:Neck0/Neck1/Mouth:black"] = line_color
	customer_def["shader:Neck0/Neck1/Eyes:black"] = line_color
	
	var body_color := Color(customer_def.body_rgb)
	customer_def["shader:FarArm:red"] = body_color
	customer_def["shader:FarLeg:red"] = body_color
	customer_def["shader:NearLeg:red"] = body_color
	customer_def["shader:NearArm:red"] = body_color
	customer_def["shader:Neck0/Neck1/EarZ0:red"] = body_color
	customer_def["shader:Neck0/Neck1/Head:red"] = body_color
	customer_def["shader:Neck0/Neck1/EarZ1:red"] = body_color
	customer_def["shader:Neck0/Neck1/Horn:red"] = body_color
	customer_def["shader:Neck0/Neck1/EarZ2:red"] = body_color
	customer_def["shader:Neck0/Neck1/Mouth:red"] = body_color
	customer_def["shader:Neck0/Neck1/Eyes:red"] = body_color
	customer_def["property:Body:fill_color"] = body_color.blend(Color(line_color.r, line_color.g, line_color.b, 0.25))
	
	customer_def["shader:Neck0/Neck1/Eyes:green"] = Color(customer_def.eye_rgb.split(" ")[0])
	customer_def["shader:Neck0/Neck1/Eyes:blue"] = Color(customer_def.eye_rgb.split(" ")[1])
	
	var horn_rgb := Color(customer_def.horn_rgb)
	customer_def["shader:Neck0/Neck1/Horn:green"] = horn_rgb
	
	# set the sprite's color/texture properties
	for key in customer_def.keys():
		if key.find("property:") == 0:
			var node_path: String = key.split(":")[1]
			var property_name: String = key.split(":")[2]
			get_node(node_path).set(property_name, customer_def[key])
			if property_name == "texture" && customer_def[key]:
				get_node(node_path).vframes = int(round(customer_def[key].get_height() / 1025))
				get_node(node_path).hframes = int(round(customer_def[key].get_width() / 1025))
			
		if key.find("shader:") == 0:
			var node_path: String = key.split(":")[1]
			var shader_param: String = key.split(":")[2]
			get_node(node_path).material.set_shader_param(shader_param, customer_def[key])
	
	$Body.update()

"""
The 'feed' animation causes a few side-effects. The customer's head recoils and some sounds play. This method controls
all of those secondary visual effects of the customer being fed.

Parameters: The 'delay' parameter causes the food effects to appear after the specified delay, in seconds.
"""
func show_food_effects(delay := 0.0) -> void:
	var munch_sound: AudioStreamPlayer = _munch_sounds[randi() % _munch_sounds.size()]
	munch_sound.pitch_scale = rand_range(0.96, 1.04)

	# avoid using the same color twice consecutively
	_food_color_index = (_food_color_index + 1 + randi() % (FOOD_COLORS.size() - 1)) % FOOD_COLORS.size()
	var food_color: Color = FOOD_COLORS[_food_color_index]
	_food.modulate = food_color
	_food_laser.modulate = food_color

	yield(get_tree().create_timer(delay), "timeout")
	munch_sound.play()
	$Tween.interpolate_property($Neck0/Neck1, "position:x", clamp($Neck0/Neck1.position.x - 6, -20, 0), 0, 0.5,
			Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	emit_signal("food_eaten")
