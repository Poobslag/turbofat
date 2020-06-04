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

"""
Returns a random creature definition.
"""
static func random_def() -> Dictionary:
	return DEFINITIONS[randi() % DEFINITIONS.size()]


"""
Loads all the appropriate resources and property definitions for a creature. The resulting textures are stored back in
the 'creature_def' parameter which is passed in.

This can also be invoked with an empty creature definition, in which case the creature definition will be populated
with the property definitions needed to unload all of their textures and colors.

Parameters:
	'creature_def': Describes some high-level information about the creature's appearance, such as 'she has red
		eyes'. The response includes granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030'.
"""
func load_details(creature_def: Dictionary) -> void:
	_load_ear(creature_def)
	_load_horn(creature_def)
	_load_mouth(creature_def)
	_load_eye(creature_def)
	_load_body(creature_def)
	_load_colors(creature_def)


"""
Loads a creature texture based on a creature_def key/value pair.

The input creature_def contains key/value pairs which we need to map to a texture to load, such as {'ear': '0'}. We map
this key/value pair to a resource such as res://assets/main/world/creature/0/ear-z1.png. The input parameters include
the dictionary of key/value pairs, which specific key/value pair we should look up, and the filename to associate with
the key/value pair.

Parameters:
	'creature_def': The dictionary of key/value pairs defining a set of textures to load. 
	
	'key': The specific key/value pair to be looked up.
	
	'filename': The stripped-down filename of the resource to look up. All creature texture files have a path of
		res://assets/main/world/creature/0/{something}.png, so this parameter only specifies the {something}.
"""
func _load_texture(creature_def: Dictionary, node_path: String, key: String, filename: String) -> void:
	# load the texture resource
	var resource: Resource;
	if not creature_def.has(key):
		# The key was not specified in the creature definition. This is not an error condition, a creature might not
		# have an 'ear' key if she doesn't have ears.
		pass
	else:
		var resource_path := "res://assets/main/world/creature/%s/%s.png" % [creature_def[key], filename]
		if !ResourceLoader.exists(resource_path):
			# Avoid loading non-existent resources. Loading a non-existent resource returns null which is what we want,
			# but also throws an error.
			pass
		else:
			resource = load(resource_path)
	
	# assign the texture properties
	creature_def["property:%s:texture" % node_path] = resource
	if resource:
		creature_def["property:%s:vframes" % node_path] = max(1, int(round(resource.get_height() / 1025)))
		creature_def["property:%s:hframes" % node_path] = max(1, int(round(resource.get_width() / 1025)))


"""
Loads the resources for a creature's ears based on a creature definition.
"""
func _load_ear(creature_def: Dictionary) -> void:
	_load_texture(creature_def, "Neck0/HeadBobber/EarZ0", "ear", "ear-z0-sheet")
	_load_texture(creature_def, "Neck0/HeadBobber/EarZ1", "ear", "ear-z1-sheet")
	_load_texture(creature_def, "Neck0/HeadBobber/EarZ2", "ear", "ear-z2-sheet")


"""
Loads the resources for a creature's horn based on a creature definition.
"""
func _load_horn(creature_def: Dictionary) -> void:
	_load_texture(creature_def, "Neck0/HeadBobber/HornZ0", "horn", "horn-z0-sheet")
	_load_texture(creature_def, "Neck0/HeadBobber/HornZ1", "horn", "horn-z1-sheet")


"""
Loads the resources for a creature's mouth based on a creature definition.
"""
func _load_mouth(creature_def: Dictionary) -> void:
	_load_texture(creature_def, "Neck0/HeadBobber/Mouth", "mouth", "mouth-sheet")
	_load_texture(creature_def, "Neck0/HeadBobber/Food", "mouth", "food-sheet")
	_load_texture(creature_def, "Neck0/HeadBobber/FoodLaser", "mouth", "food-laser-sheet")


"""
Loads the resources for a creature's eyes based on a creature definition.
"""
func _load_eye(creature_def: Dictionary) -> void:
	_load_texture(creature_def, "Neck0/HeadBobber/Eyes", "eye", "eyes-sheet")


"""
Loads the resources for a creature's arms, legs and torso based on a creature definition.
"""
func _load_body(creature_def: Dictionary) -> void:
	# All creatures have a body, but this class supports passing in an empty creature definition to unload the
	# textures from creature sprites. So we leave those textures as null if we're not explicitly told to draw the
	# creature's body.
	_load_texture(creature_def, "FarArm", "body", "arm-z0-sheet")
	_load_texture(creature_def, "FarLeg", "body", "leg-z0-sheet")
	_load_texture(creature_def, "Body/NeckBlend", "body", "neck-sheet")
	_load_texture(creature_def, "NearLeg", "body", "leg-z1-sheet")
	_load_texture(creature_def, "NearArm", "body", "arm-z1-sheet")
	_load_texture(creature_def, "Neck0/HeadBobber/Head", "body", "head-sheet")


"""
Assigns the creature's colors based on a creature definition.
"""
func _load_colors(creature_def: Dictionary) -> void:
	var line_color: Color
	if creature_def.has("line_rgb"):
		line_color = Color(creature_def.line_rgb)
	creature_def["shader:FarArm/Outline:black"] = line_color
	creature_def["shader:FarLeg/Outline:black"] = line_color
	creature_def["property:Body/Outline:line_color"] = line_color
	creature_def["shader:NearLeg/Outline:black"] = line_color
	creature_def["shader:NearArm/Outline:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EarZ0/Outline:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/HornZ0/Outline:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/Head/Outline:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EarZ1/Outline:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/HornZ1/Outline:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EarZ2/Outline:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/Mouth/Outline:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/Eyes/Outline:black"] = line_color
	creature_def["shader:FarArm:black"] = line_color
	creature_def["shader:FarLeg:black"] = line_color
	creature_def["property:Body:line_color"] = line_color
	creature_def["shader:Body/NeckBlend:black"] = line_color
	creature_def["shader:NearArm:black"] = line_color
	creature_def["shader:NearLeg:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EarZ0:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/HornZ0:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/Head:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EarZ1:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/HornZ1:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EarZ2:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/Mouth:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/Eyes:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EmoteArms:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EmoteEyes:black"] = line_color
	creature_def["shader:Neck0/HeadBobber/EmoteBrain:black"] = line_color
	creature_def["shader:EmoteBody:black"] = line_color
	
	var body_color: Color
	if creature_def.has("body_rgb"):
		body_color = Color(creature_def.body_rgb)
	creature_def["shader:FarArm:red"] = body_color
	creature_def["shader:FarLeg:red"] = body_color
	creature_def["shader:Body/NeckBlend:red"] = body_color
	creature_def["shader:NearLeg:red"] = body_color
	creature_def["shader:NearArm:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/EarZ0:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/HornZ0:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/Head:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/EarZ1:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/HornZ1:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/EarZ2:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/Mouth:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/Eyes:red"] = body_color
	creature_def["shader:Neck0/HeadBobber/EmoteArms:red"] = body_color
	
	var body_fill_color: Color
	if line_color and body_color:
		body_fill_color = body_color.blend(Color(line_color.r, line_color.g, line_color.b, 0.25))
	creature_def["property:Body:fill_color"] = body_fill_color
	
	var eye_color: Color
	var eye_shine_color: Color
	if creature_def.has("eye_rgb"):
		eye_color = Color(creature_def.eye_rgb.split(" ")[0])
		eye_shine_color = Color(creature_def.eye_rgb.split(" ")[1])
	creature_def["shader:Neck0/HeadBobber/Eyes:green"] = eye_color
	creature_def["shader:Neck0/HeadBobber/Eyes:blue"] = eye_shine_color

	var horn_color: Color
	if creature_def.has("horn_rgb"):
		horn_color = Color(creature_def.horn_rgb)
	creature_def["shader:Neck0/HeadBobber/HornZ0:green"] = horn_color
	creature_def["shader:Neck0/HeadBobber/HornZ1:green"] = horn_color
