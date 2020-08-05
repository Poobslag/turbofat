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

"""
Returns a random creature definition.
"""
static func random_def() -> Dictionary:
	return Utils.rand_value(DnaUtils.CREATURE_PALETTES)


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
	_load_head(dna)
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
Loads the resources for a creature's head based on a creature definition.
"""
static func _load_head(dna: Dictionary) -> void:
	_load_texture(dna, "Neck0/HeadBobber/CheekZ0", "cheek", "cheek-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/CheekZ1", "cheek", "cheek-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/CheekZ2", "cheek", "cheek-z2-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/EarZ0", "ear", "ear-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/EarZ1", "ear", "ear-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/EarZ2", "ear", "ear-z2-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/EyeZ0", "eye", "eye-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/EyeZ1", "eye", "eye-z1-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/HornZ0", "horn", "horn-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/HornZ1", "horn", "horn-z1-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/Mouth", "mouth", "mouth-packed")
	_load_texture(dna, "Neck0/HeadBobber/Food", "mouth", "food-packed")
	_load_texture(dna, "Neck0/HeadBobber/FoodLaser", "mouth", "food-laser-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/Nose", "nose", "nose-packed")


"""
Loads the resources for a creature's arms, legs and torso based on a creature definition.
"""
static func _load_body(dna: Dictionary) -> void:
	# All creatures have a body, but this class supports passing in an empty creature definition to unload the
	# textures from creature sprites. So we leave those textures as null if we're not explicitly told to draw the
	# creature's body.
	_load_texture(dna, "Sprint", "body", "sprint-z0-packed")
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
	dna["shader:Neck0/HeadBobber/CheekZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/Head:black"] = line_color
	dna["shader:Neck0/HeadBobber/EarZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/HornZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/CheekZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/EarZ2:black"] = line_color
	dna["shader:Neck0/HeadBobber/Mouth:black"] = line_color
	dna["shader:Neck0/HeadBobber/EyeZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/Nose:black"] = line_color
	dna["shader:Neck0/HeadBobber/EyeZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/CheekZ2:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteArmZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteArmZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteEyeZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteEyeZ1:black"] = line_color
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
	dna["shader:Neck0/HeadBobber/CheekZ0:red"] = body_color
	dna["shader:Neck0/HeadBobber/Head:red"] = body_color
	dna["shader:Neck0/HeadBobber/EarZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/HornZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/CheekZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/EarZ2:red"] = body_color
	dna["shader:Neck0/HeadBobber/Mouth:red"] = body_color
	dna["shader:Neck0/HeadBobber/EyeZ0:red"] = body_color
	dna["shader:Neck0/HeadBobber/Nose:red"] = body_color
	dna["shader:Neck0/HeadBobber/EyeZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/CheekZ2:red"] = body_color
	dna["shader:Neck0/HeadBobber/EmoteArmZ0:red"] = body_color
	dna["shader:Neck0/HeadBobber/EmoteArmZ1:red"] = body_color

	var belly_color: Color
	if dna.has("belly_rgb"):
		belly_color = Color(dna.belly_rgb)
	dna["shader:Body:green"] = belly_color
	
	var eye_color: Color
	var eye_shine_color: Color
	if dna.has("eye_rgb"):
		eye_color = Color(dna.eye_rgb.split(" ")[0])
		eye_shine_color = Color(dna.eye_rgb.split(" ")[1])
	dna["shader:Neck0/HeadBobber/EyeZ0:green"] = eye_color
	dna["shader:Neck0/HeadBobber/EyeZ1:green"] = eye_color
	dna["shader:Neck0/HeadBobber/EyeZ0:blue"] = eye_shine_color
	dna["shader:Neck0/HeadBobber/EyeZ1:blue"] = eye_shine_color

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
