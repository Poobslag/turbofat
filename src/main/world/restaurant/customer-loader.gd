tool
extends Node
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

func _exit_tree() -> void:
	# wait until all threads are done to dispose of them
	wait_to_finish()


"""
Loads all the appropriate resources and property definitions for a customer in a background thread. This involves
loading 20-30 textures and animations, many of which are quite large. The resulting textures are stored back in the
'customer_def' parameter which is passed in.

Loading these textures can take several seconds. Progress can be monitored by calling 'is_customer_ready'.

This can also be invoked with an empty customer definition, in which case the customer definition will be populated
with the property definitions needed to unload all of their textures and colors.

Parameters:
	'customer_def': Describes some high-level information about the customer's appearance, such as 'she has red
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


"""
Prunes inactive threads from our thread pool.
"""
func _prune_inactive_threads() -> void:
	var i := 0
	while i < _threads.size():
		var thread: Thread = _threads[i]
		if not thread.is_active():
			_threads.remove(i)
		else:
			i += 1


"""
Loads a customer resource, such as an image or texture based on a customer_def key/value pair.

The input customer_def contains key/value pairs which we need to map to a texture to load, such as {'ear': '0'}. We map
this key/value pair to a resource such as res://assets/world/customer/0/ear-z1.png. The input parameters include the
dictionary of key/value pairs, which specific key/value pair we should look up, and the filename to associate with the
key/value pair.

This operation is locked with a mutex to avoid 'possible cyclic resource inclusion' errors from loading the same
resource in multiple threads concurrently.

Parameters:
	'customer_def': The dictionary of key/value pairs defining a set of textures to load. 
	
	'key': The specific key/value pair to be looked up.
	
	'filename': The stripped-down filename of the resource to look up. All customer texture files have a path of
		res://assets/world/customer/0/{something}.png, so this parameter only specifies the {something}.
"""
func _resource(customer_def: Dictionary, key: String, filename: String) -> Resource:
	var resource: Resource;
	if not customer_def.has(key):
		# The key was not specified in the customer definition. This is not an error condition, a customer might not
		# have an 'ear' key if she doesn't have ears.
		pass
	else:
		var resource_path := "res://assets/world/customer/%s/%s.png" % [customer_def[key], filename]
		if !ResourceLoader.exists(resource_path):
			# Avoid loading non-existent resources. Loading a non-existent resource returns null which is what we want,
			# but also throws an error.
			pass
		else:
			_load_mutex.lock()
			resource = load(resource_path)
			_load_mutex.unlock()
	return resource


"""
Loads the resources for a customer's ears based on a customer definition.
"""
func _load_ear(customer_def: Dictionary) -> void:
	customer_def["property:Neck0/Neck1/EarZ0:texture"] = _resource(customer_def, "ear", "ear-z0-sheet")
	customer_def["property:Neck0/Neck1/EarZ1:texture"] = _resource(customer_def, "ear", "ear-z1-sheet")
	customer_def["property:Neck0/Neck1/EarZ2:texture"] = _resource(customer_def, "ear", "ear-z2-sheet")


"""
Loads the resources for a customer's horn based on a customer definition.
"""
func _load_horn(customer_def: Dictionary) -> void:
	customer_def["property:Neck0/Neck1/HornZ0:texture"] = _resource(customer_def, "horn", "horn-z0-sheet")
	customer_def["property:Neck0/Neck1/HornZ1:texture"] = _resource(customer_def, "horn", "horn-z1-sheet")


"""
Loads the resources for a customer's mouth based on a customer definition.
"""
func _load_mouth(customer_def: Dictionary) -> void:
	customer_def["property:Neck0/Neck1/Mouth:texture"] = _resource(customer_def, "mouth", "mouth-sheet")
	customer_def["property:Neck0/Neck1/Food:texture"] = _resource(customer_def, "mouth", "food-sheet")
	customer_def["property:Neck0/Neck1/FoodLaser:texture"] = _resource(customer_def, "mouth", "food-laser-sheet")


"""
Loads the resources for a customer's eyes based on a customer definition.
"""
func _load_eye(customer_def: Dictionary) -> void:
	customer_def["property:Neck0/Neck1/Eyes:texture"] = _resource(customer_def, "eye", "eyes-sheet")


"""
Loads the resources for a customer's arms, legs and torso based on a customer definition.
"""
func _load_body(customer_def: Dictionary) -> void:
	# All customers have a body, but this class supports passing in an empty customer definition to unload the
	# textures from customer sprites. So we leave those textures as null if we're not explicitly told to draw the
	# customer's body.
	customer_def["property:FarArm:texture"] = _resource(customer_def, "body", "arm-z0-sheet")
	customer_def["property:FarLeg:texture"] = _resource(customer_def, "body", "leg-z0-sheet")
	customer_def["property:Body/NeckBlend:texture"] = _resource(customer_def, "body", "neck-sheet")
	customer_def["property:NearLeg:texture"] = _resource(customer_def, "body", "leg-z1-sheet")
	customer_def["property:NearArm:texture"] = _resource(customer_def, "body", "arm-z1-sheet")
	customer_def["property:Neck0/Neck1/Head:texture"] = _resource(customer_def, "body", "head-sheet")


"""
Assigns the customer's colors based on a customer definition.
"""
func _load_colors(customer_def: Dictionary) -> void:
	var line_color: Color
	if customer_def.has("line_rgb"):
		line_color = Color(customer_def.line_rgb)
	customer_def["shader:FarArm/Outline:black"] = line_color
	customer_def["shader:FarLeg/Outline:black"] = line_color
	customer_def["property:Body/Outline:line_color"] = line_color
	customer_def["shader:NearLeg/Outline:black"] = line_color
	customer_def["shader:NearArm/Outline:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ0/Outline:black"] = line_color
	customer_def["shader:Neck0/Neck1/HornZ0/Outline:black"] = line_color
	customer_def["shader:Neck0/Neck1/Head/Outline:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ1/Outline:black"] = line_color
	customer_def["shader:Neck0/Neck1/HornZ1/Outline:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ2/Outline:black"] = line_color
	customer_def["shader:Neck0/Neck1/Mouth/Outline:black"] = line_color
	customer_def["shader:Neck0/Neck1/Eyes/Outline:black"] = line_color
	customer_def["shader:FarArm:black"] = line_color
	customer_def["shader:FarLeg:black"] = line_color
	customer_def["property:Body:line_color"] = line_color
	customer_def["shader:Body/NeckBlend:black"] = line_color
	customer_def["shader:NearArm:black"] = line_color
	customer_def["shader:NearLeg:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ0:black"] = line_color
	customer_def["shader:Neck0/Neck1/HornZ0:black"] = line_color
	customer_def["shader:Neck0/Neck1/Head:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ1:black"] = line_color
	customer_def["shader:Neck0/Neck1/HornZ1:black"] = line_color
	customer_def["shader:Neck0/Neck1/EarZ2:black"] = line_color
	customer_def["shader:Neck0/Neck1/Mouth:black"] = line_color
	customer_def["shader:Neck0/Neck1/Eyes:black"] = line_color
	
	var body_color: Color
	if customer_def.has("body_rgb"):
		body_color = Color(customer_def.body_rgb)
	customer_def["shader:FarArm:red"] = body_color
	customer_def["shader:FarLeg:red"] = body_color
	customer_def["shader:Body/NeckBlend:red"] = body_color
	customer_def["shader:NearLeg:red"] = body_color
	customer_def["shader:NearArm:red"] = body_color
	customer_def["shader:Neck0/Neck1/EarZ0:red"] = body_color
	customer_def["shader:Neck0/Neck1/HornZ0:red"] = body_color
	customer_def["shader:Neck0/Neck1/Head:red"] = body_color
	customer_def["shader:Neck0/Neck1/EarZ1:red"] = body_color
	customer_def["shader:Neck0/Neck1/HornZ1:red"] = body_color
	customer_def["shader:Neck0/Neck1/EarZ2:red"] = body_color
	customer_def["shader:Neck0/Neck1/Mouth:red"] = body_color
	customer_def["shader:Neck0/Neck1/Eyes:red"] = body_color
	
	var body_fill_color: Color
	if line_color and body_color:
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
	customer_def["shader:Neck0/Neck1/HornZ0:green"] = horn_color
	customer_def["shader:Neck0/Neck1/HornZ1:green"] = horn_color


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
