"""
Loads customer resources based on customer definitions. For example, a customer definition might describe high-level
information about the customer's appearance, such as 'she has red eyes' or 'she has a star on her forehead'. This
class converts that information into granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030', and also
loads resource files specific to each customer.

Customers can have many large resources associated with them, so these resources are loaded in threads. They're loaded
in threads because preloading them would cause a significant delay in launching the game, and loading them during
scene transitions or during gameplay would cause long pauses. CustomerLoader handles launching and cleaning up these
threads and other concurrency issues.

CustomerLoader is loaded as a singleton in this project to ensure the same resource isn't loaded multiple times.
"""
extends Node

# How large customers can grow; 5.0 = 5x normal size
const MAX_FATNESS := 10.0

# How long it takes a customer to grow to a new size
const GROWTH_SECONDS := 0.12

# Palettes used for recoloring customers
const DEFINITIONS := [
	{"line_rgb": "6c4331", "body_rgb": "b23823", "eye_rgb": "282828 dedede", "horn_rgb": "f1e398"}, # dark red
	{"line_rgb": "6c4331", "body_rgb": "eeda4d", "eye_rgb": "c0992f f1e398", "horn_rgb": "f1e398"}, # yellow
	{"line_rgb": "6c4331", "body_rgb": "41a740", "eye_rgb": "c09a2f f1e398", "horn_rgb": "f1e398"}, # dark green
	{"line_rgb": "6c4331", "body_rgb": "b47922", "eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398"}, # brown
	{"line_rgb": "6c4331", "body_rgb": "6f83db", "eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398"}, # light blue
	{"line_rgb": "6c4331", "body_rgb": "a854cb", "eye_rgb": "4fa94e dbe28e", "horn_rgb": "f1e398"}, # purple
	{"line_rgb": "6c4331", "body_rgb": "f57e7d", "eye_rgb": "7ac252 e9f4dc", "horn_rgb": "f1e398"}, # light red
	{"line_rgb": "6c4331", "body_rgb": "f9bb4a", "eye_rgb": "f9a74c fff6df", "horn_rgb": "b47922"}, # orange
	{"line_rgb": "6c4331", "body_rgb": "8fea40", "eye_rgb": "f5d561 fcf3cd", "horn_rgb": "b47922"}, # light green
	{"line_rgb": "6c4331", "body_rgb": "feceef", "eye_rgb": "ffddf4 ffffff", "horn_rgb": "ffffff"}, # pink
	{"line_rgb": "6c4331", "body_rgb": "b1edee", "eye_rgb": "c1f1f2 ffffff", "horn_rgb": "ffffff"}, # cyan
	{"line_rgb": "6c4331", "body_rgb": "f9f7d9", "eye_rgb": "91e6ff ffffff", "horn_rgb": "ffffff"}, # white
	{"line_rgb": "3c3c3d", "body_rgb": "1a1a1e", "eye_rgb": "b8260b f45e40", "horn_rgb": "282828"}, # black
	{"line_rgb": "6c4331", "body_rgb": "7a8289", "eye_rgb": "f5f0d1 ffffff", "horn_rgb": "282828"}, # grey
	{"line_rgb": "41281e", "body_rgb": "0b45a6", "eye_rgb": "fad541 ffffff", "horn_rgb": "282828"}  # dark blue
]

# pool of threads which are currently loading resources
var _threads := [];

# list of customer definitions which are loaded, but haven't been asked about
var _ready_customer_definitions := {}

# mutex which ensures we don't load multiple resources concurrently
var _load_mutex := Mutex.new()

"""
Loads all the appropriate resources and property definitions for a customer in a background thread. This involves
loading 20-30 textures and animations, many of which are quite large. The resulting textures are stored back in the
'customer_def' parameter which is passed in.

Loading these textures can take several seconds. Progress can be monitored by calling 'is_customer_ready'.

This can also be invoked with an empty customer definition, in which case the customer definition will be populated
with the property definitions needed to unload all of their textures and colors.

Parameter: 'customer_def' describes some high-level information about the customer's appearance, such as 'she has red
	eyes'. The response includes granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030'.
"""
func summon_customer(customer_def: Dictionary) -> void:
	_prune_inactive_threads()
	var thread := Thread.new()
	_threads.append(thread)
	thread.start(self, "_load_all", customer_def)

"""
Returns 'true' if the specified customer_def has been fully populated with the necessary textures and metadata to
draw the customer.

After returning true, this method also purges the customer_def from its cache.

Parameter: 'customer_def' is a customer definition which has been previously passed to the 'summon_customer' method.
"""
func is_customer_ready(customer_def: Dictionary) -> bool:
	return _ready_customer_definitions.erase(customer_def)

"""
Waits for all threads to become inactive. Threads must be disposed (or 'joined') for portability.
"""
func wait_to_finish() -> void:
	for thread in _threads:
		thread.wait_to_finish()

func _exit_tree() -> void:
	# wait until all threads are done to dispose of them
	wait_to_finish()

"""
Prunes inactive threads from our thread pool.
"""
func _prune_inactive_threads() -> void:
	var i := 0
	while i < _threads.size():
		var thread: Thread = _threads[i]
		if !thread.is_active():
			_threads.remove(i)
		else:
			i += 1

"""
Loads a customer resource, such as an image or texture.

This operation is locked with a mutex to avoid 'possible cyclic resource inclusion' errors from loading the same
resource in multiple threads concurrently.
"""
func _resource(path:String) -> Resource:
	_load_mutex.lock()
	var result = load("res://art/customer/" + path)
	_load_mutex.unlock()
	return result

"""
Loads the resources for a customer's ears based on a customer definition.
"""
func _load_ear(customer_def: Dictionary) -> void:
	var z0: Texture
	var z1: Texture
	var z2: Texture
	var z0_outline: Texture
	var z1_outline: Texture
	var z2_outline: Texture
	if customer_def.has("ear"):
		if customer_def.ear == "0":
			z1 = _resource("ear-z1-0.png")
			z2 = _resource("ear-z2-0.png")
			z2_outline = _resource("ear-z2-outline-0.png")
		elif customer_def.ear == "1":
			z0 = _resource("ear-z0-1.png")
			z1 = _resource("ear-z1-1.png")
			z2 = _resource("ear-z2-1.png")
			z2_outline = _resource("ear-z2-outline-1.png")
		elif customer_def.ear == "2":
			z0 = _resource("ear-z0-2.png")
			z1 = _resource("ear-z1-2.png")
			z2 = _resource("ear-z2-2.png")
			z2_outline = _resource("ear-z2-outline-2.png")
		else:
			print("Invalid ear: %s" % customer_def.ear)
	customer_def["property:Neck0/Neck1/EarZ0:texture"] = z0
	customer_def["property:Neck0/Neck1/EarZ1:texture"] = z1
	customer_def["property:Neck0/Neck1/EarZ2:texture"] = z2
	customer_def["property:Neck0Outline/Neck1Outline/EarZ0Outline:texture"] = z0_outline
	customer_def["property:Neck0Outline/Neck1Outline/EarZ1Outline:texture"] = z1_outline
	customer_def["property:Neck0Outline/Neck1Outline/EarZ2Outline:texture"] = z2_outline

"""
Loads the resources for a customer's horn based on a customer definition.
"""
func _load_horn(customer_def: Dictionary) -> void:
	var horn: Texture
	var horn_outline: Texture
	if customer_def.has("horn"):
		if customer_def.horn == "0":
			pass
		elif customer_def.horn == "1":
			horn = _resource("horn-1.png")
		elif customer_def.horn == "2":
			horn = _resource("horn-2.png")
			horn_outline = _resource("horn-outline-2.png")
		else:
			print("Invalid horn: %s" % customer_def.horn)
	customer_def["property:Neck0/Neck1/Horn:texture"] = horn
	customer_def["property:Neck0Outline/Neck1Outline/HornOutline:texture"] = horn_outline

"""
Loads the resources for a customer's mouth based on a customer definition.
"""
func _load_mouth(customer_def: Dictionary) -> void:
	var mouth: Texture
	var mouth_outline: Texture
	var food: Texture
	var food_laser: Texture
	if customer_def.has("mouth"):
		if customer_def.mouth == "0":
			mouth = _resource("mouth-sheet-0.png")
			mouth_outline = _resource("mouth-outline-sheet-0.png")
			food = _resource("food-sheet-0.png")
			food_laser = _resource("food-laser-sheet-0.png")
		elif customer_def.mouth == "1":
			mouth = _resource("mouth-sheet-1.png")
			mouth_outline = _resource("mouth-outline-sheet-1.png")
			food = _resource("food-sheet-1.png")
			food_laser = _resource("food-laser-sheet-1.png")
		else:
			print("Invalid mouth: %s" % customer_def.mouth)
	customer_def["property:Neck0/Neck1/Mouth:texture"] = mouth
	customer_def["property:Neck0Outline/Neck1Outline/MouthOutline:texture"] = mouth_outline
	customer_def["property:../KludgeCustomer/KludgeNeck0/KludgeNeck1/Food:texture"] = food
	customer_def["property:../KludgeCustomer/KludgeNeck0/KludgeNeck1/FoodLaser:texture"] = food_laser

"""
Loads the resources for a customer's eyes based on a customer definition.
"""
func _load_eye(customer_def: Dictionary) -> void:
	var eyes:Texture
	var eyes_outline:Texture
	if customer_def.has("eye"):
		if customer_def.eye == "0":
			eyes = _resource("eyes-sheet-0.png")
			eyes_outline = _resource("eyes-outline-sheet-0.png")
		elif customer_def.eye == "1":
			eyes = _resource("eyes-sheet-1.png")
			eyes_outline = _resource("eyes-outline-sheet-1.png")
		elif customer_def.eye == "2":
			eyes = _resource("eyes-sheet-2.png")
			eyes_outline = _resource("eyes-outline-sheet-2.png")
		else:
			print("Invalid eye: %s" % customer_def.eye)
	customer_def["property:Neck0/Neck1/Eyes:texture"] = eyes
	customer_def["property:Neck0Outline/Neck1Outline/EyesOutline:texture"] = eyes_outline

"""
Loads the resources for a customer's arms, legs and torso based on a customer definition.
"""
func _load_body(customer_def: Dictionary) -> void:
	var far_arm_outline: Texture
	var far_leg_outline: Texture
	var near_leg_outline: Texture
	var near_arm_outline: Texture
	var head_outline: Texture
	var far_arm: Texture
	var near_arm: Texture
	var near_leg: Texture
	var far_leg: Texture
	var head: Texture
	
	# All customers have a body, but this class supports passing in an empty customer definition to unload the
	# textures from customer sprites. So we leave those textures as null if we're not explicitly told to draw the
	# customer's body.
	if customer_def.has("body"):
		far_arm_outline = _resource("arm-z0-outline.png")
		far_leg_outline = _resource("leg-z0-outline.png")
		near_leg_outline = _resource("leg-z1-outline.png")
		near_arm_outline = _resource("arm-z1-outline.png")
		head_outline = _resource("head-outline.png")
		far_arm = _resource("arm-z0.png")
		far_leg = _resource("leg-z0.png")
		near_leg = _resource("leg-z1.png")
		near_arm = _resource("arm-z1.png")
		head = _resource("head.png")
	customer_def["property:FarArmOutline:texture"] = far_arm_outline
	customer_def["property:FarLegOutline:texture"] = far_leg_outline
	customer_def["property:NearLegOutline:texture"] = near_leg_outline
	customer_def["property:NearArmOutline:texture"] = near_arm_outline
	customer_def["property:Neck0Outline/Neck1Outline/HeadOutline:texture"] = head_outline
	customer_def["property:FarArm:texture"] = far_arm
	customer_def["property:FarLeg:texture"] = far_leg
	customer_def["property:NearLeg:texture"] = near_leg
	customer_def["property:NearArm:texture"] = near_arm
	customer_def["property:Neck0/Neck1/Head:texture"] = head

"""
Assigns the customer's colors based on a customer definition.
"""
func _load_colors(customer_def: Dictionary) -> void:
	var line_color: Color
	if customer_def.has("line_rgb"):
		line_color = Color(customer_def.line_rgb)
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
	
	var body_color: Color
	if customer_def.has("body_rgb"):
		body_color = Color(customer_def.body_rgb)
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
	
	var body_fill_color: Color
	if line_color && body_color:
		body_fill_color = body_color.blend(Color(line_color.r, line_color.g, line_color.b, 0.25))
	customer_def["property:Body:fill_color"] = body_fill_color
	
	var eye_color: Color
	var eye_shine_color: Color
	if customer_def.has("eye_rgb"):
		eye_color = Color(customer_def.eye_rgb.split(" ")[0])
		eye_shine_color = Color(customer_def.eye_rgb.split(" ")[1])
	customer_def["shader:Neck0/Neck1/Eyes:green"] = eye_color
	customer_def["shader:Neck0/Neck1/Eyes:blue"] = eye_shine_color

	var horn_color: Color
	if customer_def.has("horn_rgb"):
		horn_color = Color(customer_def.horn_rgb)
	customer_def["shader:Neck0/Neck1/Horn:green"] = horn_color

"""
Loads all the appropriate resources and property definitions based on a customer definition.
"""
func _load_all(customer_def: Dictionary) -> void:
	_load_ear(customer_def)
	_load_horn(customer_def)
	_load_mouth(customer_def)
	_load_eye(customer_def)
	_load_body(customer_def)
	_load_colors(customer_def)
	_ready_customer_definitions[customer_def] = true
