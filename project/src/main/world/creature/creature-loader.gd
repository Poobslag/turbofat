class_name CreatureLoader
"""
Loads creature resources based on creature definitions. For example, a creature definition might describe high-level
information about the creature's appearance, such as 'she has red eyes' or 'she has a star on her forehead'. This
class converts that information into granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030', and also
loads resource files specific to each creature.
"""

# How large creatures can grow; 5.0 = 5x normal size
const MAX_FATNESS := 10.0

# How long it takes a creature to grow to a new size
const GROWTH_SECONDS := 0.12

# Palettes used for recoloring creatures
const DEFINITIONS := [
	{"line_rgb": "6c4331", "body_rgb": "b23823", "belly_rgb": "c9442a",
			"eye_rgb": "282828 dedede", "horn_rgb": "f1e398"}, # dark red
	{"line_rgb": "6c4331", "body_rgb": "eeda4d", "belly_rgb": "f7f0cc",
			"eye_rgb": "c0992f f1e398", "horn_rgb": "f1e398"}, # yellow
	{"line_rgb": "6c4331", "body_rgb": "41a740", "belly_rgb": "4fa94e",
			"eye_rgb": "c09a2f f1e398", "horn_rgb": "f1e398"}, # dark green
	{"line_rgb": "6c4331", "body_rgb": "b47922", "belly_rgb": "d0ec5c",
			"eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398"}, # brown
	{"line_rgb": "6c4331", "body_rgb": "6f83db", "belly_rgb": "92d8e5",
			"eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398"}, # light blue
	{"line_rgb": "6c4331", "body_rgb": "a854cb", "belly_rgb": "bb73dd",
			"eye_rgb": "4fa94e dbe28e", "horn_rgb": "f1e398"}, # purple
	{"line_rgb": "6c4331", "body_rgb": "f57e7d", "belly_rgb": "fde8c9",
			"eye_rgb": "7ac252 e9f4dc", "horn_rgb": "f1e398"}, # light red
	{"line_rgb": "6c4331", "body_rgb": "f9bb4a", "belly_rgb": "fff4b2",
			"eye_rgb": "f9a74c fff6df", "horn_rgb": "b47922"}, # orange
	{"line_rgb": "6c4331", "body_rgb": "8fea40", "belly_rgb": "e8fa95",
			"eye_rgb": "f5d561 fcf3cd", "horn_rgb": "b47922"}, # light green
	{"line_rgb": "6c4331", "body_rgb": "feceef", "belly_rgb": "ffeffc",
			"eye_rgb": "ffddf4 ffffff", "horn_rgb": "ffffff"}, # pink
	{"line_rgb": "6c4331", "body_rgb": "b1edee", "belly_rgb": "dff2f0",
			"eye_rgb": "c1f1f2 ffffff", "horn_rgb": "ffffff"}, # cyan
	{"line_rgb": "6c4331", "body_rgb": "f9f7d9", "belly_rgb": "d7c2a4",
			"eye_rgb": "91e6ff ffffff", "horn_rgb": "ffffff"}, # white
	{"line_rgb": "3c3c3d", "body_rgb": "1a1a1e", "belly_rgb": "433028",
			"eye_rgb": "b8260b f45e40", "horn_rgb": "282828"}, # black
	{"line_rgb": "6c4331", "body_rgb": "7a8289", "belly_rgb": "c8c3b5",
			"eye_rgb": "f5f0d1 ffffff", "horn_rgb": "282828"}, # grey
	{"line_rgb": "41281e", "body_rgb": "0b45a6", "belly_rgb": "eec086",
			"eye_rgb": "fad541 ffffff", "horn_rgb": "282828"}  # dark blue
]

"""
Returns a random creature definition.
"""
static func random_def() -> Dictionary:
	return DEFINITIONS[randi() % DEFINITIONS.size()]


"""
Loads all the appropriate resources and property definitions for a creature. The resulting textures are stored back in
the 'dna' parameter which is passed in.

This can also be invoked with an empty creature definition, in which case the creature definition will be populated
with the property definitions needed to unload all of their textures and colors.

Parameters:
	'dna': Defines high-level information about the creature's appearance, such as 'she has red eyes'. The response
		includes granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030'.
"""
static func load_details(dna: Dictionary) -> void:
	_load_ear(dna)
	_load_horn(dna)
	_load_mouth(dna)
	_load_eye(dna)
	_load_body(dna)
	_load_colors(dna)


"""
Loads a creature texture based on a dna key/value pair.

The input dna contains key/value pairs which we need to map to a texture to load, such as {'ear': '0'}. We map
this key/value pair to a resource such as res://assets/main/world/creature/0/ear-z1.png. The input parameters include
the dictionary of key/value pairs, which specific key/value pair we should look up, and the filename to associate with
the key/value pair.

Parameters:
	'dna': The dictionary of key/value pairs defining a set of textures to load.
	
	'key': The specific key/value pair to be looked up.
	
	'filename': The stripped-down filename of the resource to look up. All creature texture files have a path of
		res://assets/main/world/creature/0/{something}.png, so this parameter only specifies the {something}.
"""
static func _load_texture(dna: Dictionary, node_path: String, key: String, filename: String) -> void:
	# load the texture resource
	var resource_path: String
	var frame_data: String
	var resource: Resource
	if not dna.has(key):
		# The key was not specified in the creature definition. This is not an error condition, a creature might not
		# have an 'ear' key if she doesn't have ears.
		pass
	else:
		resource_path = "res://assets/main/world/creature/%s/%s.png" % [dna[key], filename]
		frame_data = "res://assets/main/world/creature/%s/%s.json" % [dna[key], filename]
		if not ResourceLoader.exists(resource_path):
			# Avoid loading non-existent resources. Loading a non-existent resource returns null which is what we want,
			# but also throws an error.
			pass
		else:
			resource = load(resource_path)
	
	if resource:
		dna["property:%s:texture" % node_path] = resource
		dna["property:%s:frame_data" % node_path] = frame_data
	else:
		dna.erase("property:%s:texture" % node_path)
		dna.erase("property:%s:frame_data" % node_path)


"""
Loads the resources for a creature's ears based on a creature definition.
"""
static func _load_ear(dna: Dictionary) -> void:
	_load_texture(dna, "Neck0/HeadBobber/EarZ0", "ear", "ear-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/EarZ1", "ear", "ear-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/EarZ2", "ear", "ear-z2-packed")


"""
Loads the resources for a creature's horn based on a creature definition.
"""
static func _load_horn(dna: Dictionary) -> void:
	_load_texture(dna, "Neck0/HeadBobber/HornZ0", "horn", "horn-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/HornZ1", "horn", "horn-z1-packed")


"""
Loads the resources for a creature's mouth based on a creature definition.
"""
static func _load_mouth(dna: Dictionary) -> void:
	_load_texture(dna, "Neck0/HeadBobber/Mouth", "mouth", "mouth-packed")
	_load_texture(dna, "Neck0/HeadBobber/Food", "mouth", "food-packed")
	_load_texture(dna, "Neck0/HeadBobber/FoodLaser", "mouth", "food-laser-packed")


"""
Loads the resources for a creature's eyes based on a creature definition.
"""
static func _load_eye(dna: Dictionary) -> void:
	_load_texture(dna, "Neck0/HeadBobber/Eyes", "eye", "eyes-packed")


"""
Loads the resources for a creature's arms, legs and torso based on a creature definition.
"""
static func _load_body(dna: Dictionary) -> void:
	# All creatures have a body, but this class supports passing in an empty creature definition to unload the
	# textures from creature sprites. So we leave those textures as null if we're not explicitly told to draw the
	# creature's body.
	_load_texture(dna, "FarMovement", "body", "movement-z0-packed")
	_load_texture(dna, "FarArm", "body", "arm-z0-packed")
	_load_texture(dna, "FarLeg", "body", "leg-z0-packed")
	_load_texture(dna, "Body/Viewport/Body/NeckBlend", "body", "neck-packed")
	_load_texture(dna, "NearLeg", "body", "leg-z1-packed")
	_load_texture(dna, "NearArm", "body", "arm-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/Head", "body", "head-packed")
	
	dna["property:BodyColors:belly"] = dna.get("belly", 0)


"""
Assigns the creature's colors based on a creature definition.
"""
static func _load_colors(dna: Dictionary) -> void:
	var line_color: Color
	if dna.has("line_rgb"):
		line_color = Color(dna.line_rgb)
	dna["shader:FarArm:black"] = line_color
	dna["shader:FarLeg:black"] = line_color
	dna["shader:Body:black"] = line_color
	dna["shader:NearArm:black"] = line_color
	dna["shader:NearLeg:black"] = line_color
	dna["shader:Neck0/HeadBobber/EarZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/HornZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/Head:black"] = line_color
	dna["shader:Neck0/HeadBobber/EarZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/HornZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/EarZ2:black"] = line_color
	dna["shader:Neck0/HeadBobber/Mouth:black"] = line_color
	dna["shader:Neck0/HeadBobber/Eyes:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteArms:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteEyes:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteBrain:black"] = line_color
	dna["shader:EmoteBody:black"] = line_color
	
	var body_color: Color
	if dna.has("body_rgb"):
		body_color = Color(dna.body_rgb)
	dna["shader:FarArm:red"] = body_color
	dna["shader:FarLeg:red"] = body_color
	dna["shader:Body:red"] = body_color
	dna["shader:NearLeg:red"] = body_color
	dna["shader:NearArm:red"] = body_color
	dna["shader:Neck0/HeadBobber/EarZ0:red"] = body_color
	dna["shader:Neck0/HeadBobber/HornZ0:red"] = body_color
	dna["shader:Neck0/HeadBobber/Head:red"] = body_color
	dna["shader:Neck0/HeadBobber/EarZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/HornZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/EarZ2:red"] = body_color
	dna["shader:Neck0/HeadBobber/Mouth:red"] = body_color
	dna["shader:Neck0/HeadBobber/Eyes:red"] = body_color
	dna["shader:Neck0/HeadBobber/EmoteArms:red"] = body_color
	
	var belly_color: Color
	if dna.has("belly_rgb"):
		belly_color = Color(dna.belly_rgb)
	dna["shader:Body:green"] = belly_color
	
	var eye_color: Color
	var eye_shine_color: Color
	if dna.has("eye_rgb"):
		eye_color = Color(dna.eye_rgb.split(" ")[0])
		eye_shine_color = Color(dna.eye_rgb.split(" ")[1])
	dna["shader:Neck0/HeadBobber/Eyes:green"] = eye_color
	dna["shader:Neck0/HeadBobber/Eyes:blue"] = eye_shine_color

	var horn_color: Color
	if dna.has("horn_rgb"):
		horn_color = Color(dna.horn_rgb)
	dna["shader:Neck0/HeadBobber/HornZ0:green"] = horn_color
	dna["shader:Neck0/HeadBobber/HornZ1:green"] = horn_color


static func load_creature_def(id: String) -> CreatureDef:
	var creature_def_text: String = FileUtils.get_file_as_text("res://assets/main/dialog/%s/creature.json" % id)
	var json_creature_def: Dictionary = parse_json(creature_def_text)
	var creature_def := CreatureDef.new()
	creature_def.from_json_dict(json_creature_def)
	return creature_def


"""
If the specified key is not associated with a value, this method associates it with the given value.
"""
static func put_if_absent(dna: Dictionary, key: String, value) -> void:
	dna[key] = dna.get(key, value)


"""
Fill in the creature's missing traits with random values.

Otherwise, missing values will be left empty, leading to invisible body parts or strange colors.
"""
static func fill_dna(dna: Dictionary) -> Dictionary:
	# duplicate the dna so that we don't modify the original
	var result := dna.duplicate()
	put_if_absent(result, "line_rgb", "6c4331")
	put_if_absent(result, "body_rgb", "b23823")
	put_if_absent(result, "belly_rgb", "ffa86d")
	put_if_absent(result, "eye_rgb", "282828 dedede")
	put_if_absent(result, "horn_rgb", "f1e398")
	
	if ResourceCache.minimal_resources:
		# avoid loading unnecessary resources for things like the level editor
		pass
	else:
		put_if_absent(result, "eye", ["1", "1", "1", "2", "3"][randi() % 5])
		put_if_absent(result, "ear", ["1", "1", "1", "2", "3"][randi() % 5])
		put_if_absent(result, "horn", ["0", "0", "0", "1", "2"][randi() % 5])
		put_if_absent(result, "mouth", ["1", "1", "2"][randi() % 3])
		put_if_absent(result, "belly", ["0", "0", "1", "1", "2"][randi() % 5])
	put_if_absent(result, "body", "1")
	return result
