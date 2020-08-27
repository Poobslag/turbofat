#tool #uncomment to view creature in editor
extends Node

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

# AnimationPlayer scenes with animations for each type of mouth
var _mouth_player_scenes := {
	"1": preload("res://src/main/world/creature/Mouth1Player.tscn"),
	"2": preload("res://src/main/world/creature/Mouth2Player.tscn"),
	"3": preload("res://src/main/world/creature/Mouth3Player.tscn"),
}

# AnimationPlayer scenes with animations for each type of ear
var _ear_player_scenes := {
	"1": preload("res://src/main/world/creature/Ear1Player.tscn"),
	"2": preload("res://src/main/world/creature/Ear2Player.tscn"),
	"3": preload("res://src/main/world/creature/Ear3Player.tscn"),
}

"""
Returns a random creature definition.
"""
func random_def() -> Dictionary:
	return DnaUtils.random_creature_palette()


"""
Returns an AnimationPlayer for the specified type type of mouth.
"""
func new_mouth_player(mouth_key: String) -> AnimationPlayer:
	var result: AnimationPlayer
	if _mouth_player_scenes.has(mouth_key):
		result = _mouth_player_scenes[mouth_key].instance()
	return result


"""
Returns an AnimationPlayer for the specified type of ear.
"""
func new_ear_player(ear_key: String) -> AnimationPlayer:
	var result: AnimationPlayer
	if _ear_player_scenes.has(ear_key):
		result = _ear_player_scenes[ear_key].instance()
	return result


"""
Loads all the appropriate resources and property definitions for a creature. The resulting textures are stored back in
the 'dna' parameter which is passed in.

This can also be invoked with an empty creature definition, in which case the creature definition will be populated
with the property definitions needed to unload all of their textures and colors.

Parameters:
	'dna': Defines high-level information about the creature's appearance, such as 'she has red eyes'. The response
		includes granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030'.
"""
func load_details(dna: Dictionary) -> void:
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
func _load_texture(dna: Dictionary, node_path: String, key: String, filename: String) -> void:
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
func _load_head(dna: Dictionary) -> void:
	_load_texture(dna, "Collar", "collar", "collar-packed")
	_load_texture(dna, "Neck0/HeadBobber/Head", "head", "head-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/CheekZ0", "cheek", "cheek-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/CheekZ1", "cheek", "cheek-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/CheekZ2", "cheek", "cheek-z2-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/EarZ0", "ear", "ear-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/EarZ1", "ear", "ear-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/EarZ2", "ear", "ear-z2-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/EyeZ0", "eye", "eye-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/EyeZ1", "eye", "eye-z1-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/HairZ0", "hair", "hair-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/HairZ1", "hair", "hair-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/HairZ2", "hair", "hair-z2-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/HornZ0", "horn", "horn-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/HornZ1", "horn", "horn-z1-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/Mouth", "mouth", "mouth-packed")
	_load_texture(dna, "Neck0/HeadBobber/Food", "mouth", "food-packed")
	_load_texture(dna, "Neck0/HeadBobber/FoodLaser", "mouth", "food-laser-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/Nose", "nose", "nose-packed")


"""
Loads the resources for a creature's arms, legs and torso based on a creature definition.
"""
func _load_body(dna: Dictionary) -> void:
	# All creatures have a body, but this class supports passing in an empty creature definition to unload the
	# textures from creature sprites. So we leave those textures as null if we're not explicitly told to draw the
	# creature's body.
	_load_texture(dna, "Sprint", "body", "sprint-z0-packed")
	_load_texture(dna, "FarArm", "body", "arm-z0-packed")
	_load_texture(dna, "FarLeg", "body", "leg-z0-packed")
	_load_texture(dna, "Body/Viewport/Body/NeckBlend", "body", "neck-blend-packed")
	_load_texture(dna, "NearLeg", "body", "leg-z1-packed")
	_load_texture(dna, "NearArm", "body", "arm-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/Chin", "body", "chin-packed")
	
	_load_texture(dna, "TailZ0", "tail", "tail-z0-packed")
	_load_texture(dna, "TailZ1", "tail", "tail-z1-packed")
	
	dna["property:BodyColors:belly"] = dna.get("belly", 0)


"""
Assigns the creature's colors based on a creature definition.
"""
func _load_colors(dna: Dictionary) -> void:
	var line_color: Color
	if dna.has("line_rgb"):
		line_color = Color(dna.line_rgb)
	dna["shader:Body:black"] = line_color
	dna["shader:Collar:black"] = line_color
	dna["shader:EmoteBody:black"] = line_color
	dna["shader:FarArm:black"] = line_color
	dna["shader:FarLeg:black"] = line_color
	dna["shader:NearArm:black"] = line_color
	dna["shader:NearLeg:black"] = line_color
	
	dna["shader:TailZ0:black"] = line_color
	dna["shader:TailZ1:black"] = line_color
	
	dna["shader:Neck0/HeadBobber/CheekZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/CheekZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/CheekZ2:black"] = line_color
	dna["shader:Neck0/HeadBobber/Chin:black"] = line_color
	dna["shader:Neck0/HeadBobber/EarZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/EarZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/EarZ2:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteArmZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteArmZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteBrain:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteEyeZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/EmoteEyeZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/EyeZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/EyeZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/HairZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/HairZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/HairZ2:black"] = line_color
	dna["shader:Neck0/HeadBobber/Head:black"] = line_color
	dna["shader:Neck0/HeadBobber/HornZ0:black"] = line_color
	dna["shader:Neck0/HeadBobber/HornZ1:black"] = line_color
	dna["shader:Neck0/HeadBobber/Mouth:black"] = line_color
	dna["shader:Neck0/HeadBobber/Nose:black"] = line_color
	
	var hair_color: Color
	if dna.has("hair_rgb"):
		hair_color = Color(dna.hair_rgb)
	dna["shader:Neck0/HeadBobber/HairZ0:red"] = hair_color
	dna["shader:Neck0/HeadBobber/HairZ1:red"] = hair_color
	dna["shader:Neck0/HeadBobber/HairZ2:red"] = hair_color
	
	var cloth_color: Color
	if dna.has("cloth_rgb"):
		cloth_color = Color(dna.cloth_rgb)
	dna["shader:Collar:red"] = cloth_color
	dna["shader:Collar:green"] = hair_color
	
	var body_color: Color
	if dna.has("body_rgb"):
		body_color = Color(dna.body_rgb)
	var belly_color: Color
	if dna.has("belly_rgb"):
		belly_color = Color(dna.belly_rgb)
	
	dna["shader:Body:red"] = body_color
	dna["shader:Body:green"] = belly_color
	
	dna["shader:FarArm:red"] = body_color
	dna["shader:FarLeg:red"] = body_color
	dna["shader:NearArm:red"] = body_color
	dna["shader:NearLeg:red"] = body_color
	
	dna["shader:TailZ0:red"] = body_color
	dna["shader:TailZ0:green"] = belly_color
	dna["shader:TailZ0:blue"] = hair_color
	dna["shader:TailZ1:red"] = body_color
	dna["shader:TailZ1:green"] = belly_color
	dna["shader:TailZ1:blue"] = hair_color
	
	var cheek_skin_color := belly_color if dna.get("head") in ["2", "3", "5"] else body_color
	var cheek_eye_color := belly_color if dna.get("head") in ["2", "3", "4", "5"] else body_color
	dna["shader:Neck0/HeadBobber/CheekZ0:red"] = cheek_skin_color
	dna["shader:Neck0/HeadBobber/CheekZ0:green"] = cheek_eye_color
	dna["shader:Neck0/HeadBobber/CheekZ1:red"] = cheek_skin_color
	dna["shader:Neck0/HeadBobber/CheekZ1:green"] = cheek_eye_color
	dna["shader:Neck0/HeadBobber/CheekZ2:red"] = cheek_skin_color
	dna["shader:Neck0/HeadBobber/CheekZ2:green"] = cheek_eye_color
	
	var chin_skin_color := belly_color if dna.get("head") in ["2", "3", "5"] else body_color
	dna["shader:Neck0/HeadBobber/Chin:red"] = chin_skin_color
	
	dna["shader:Neck0/HeadBobber/EarZ0:red"] = body_color
	dna["shader:Neck0/HeadBobber/EarZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/EarZ2:red"] = body_color
	dna["shader:Neck0/HeadBobber/EmoteArmZ0:red"] = body_color
	dna["shader:Neck0/HeadBobber/EmoteArmZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/Head:red"] = body_color
	dna["shader:Neck0/HeadBobber/Head:green"] = belly_color
	
	var mouth_skin_color := belly_color if dna.get("head") in ["2", "3", "5"] else body_color
	dna["shader:Neck0/HeadBobber/Mouth:red"] = mouth_skin_color
	
	var nose_skin_color := belly_color if dna.get("head") in ["2", "3"] else body_color
	dna["shader:Neck0/HeadBobber/Nose:red"] = nose_skin_color
	
	var eye_color: Color
	var eye_shine_color: Color
	var eye_skin_color := belly_color if dna.get("head") in ["2", "4", "5"] else body_color
	if dna.has("eye_rgb"):
		eye_color = Color(dna.eye_rgb.split(" ")[0])
		eye_shine_color = Color(dna.eye_rgb.split(" ")[1])
	dna["shader:Neck0/HeadBobber/EyeZ0:red"] = eye_skin_color
	dna["shader:Neck0/HeadBobber/EyeZ0:green"] = eye_color
	dna["shader:Neck0/HeadBobber/EyeZ0:blue"] = eye_shine_color
	dna["shader:Neck0/HeadBobber/EyeZ1:red"] = eye_skin_color
	dna["shader:Neck0/HeadBobber/EyeZ1:green"] = eye_color
	dna["shader:Neck0/HeadBobber/EyeZ1:blue"] = eye_shine_color

	var horn_color: Color
	if dna.has("horn_rgb"):
		horn_color = Color(dna.horn_rgb)
	dna["shader:Neck0/HeadBobber/HornZ0:red"] = body_color
	dna["shader:Neck0/HeadBobber/HornZ0:green"] = horn_color
	dna["shader:Neck0/HeadBobber/HornZ1:red"] = body_color
	dna["shader:Neck0/HeadBobber/HornZ1:green"] = horn_color


func load_creature_def_by_id(id: String) -> CreatureDef:
	return load_creature_def("res://assets/main/dialog/%s/creature.json" % id)


func load_creature_def(path: String) -> CreatureDef:
	var creature_def_text: String = FileUtils.get_file_as_text(path)
	var parsed = parse_json(creature_def_text)
	var creature_def: CreatureDef
	if typeof(parsed) == TYPE_DICTIONARY:
		creature_def = CreatureDef.new()
		var json_creature_def: Dictionary = parsed
		creature_def.from_json_dict(json_creature_def)
		
		# populate default values when importing incomplete json
		for allele in ["line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb",
				"head", "cheek", "eye", "ear", "horn", "mouth", "nose", "hair", "belly"]:
			DnaUtils.put_if_absent(creature_def.dna, allele, CreatureLibrary.DEFAULT_DNA[allele])
		if not creature_def.creature_name:
			creature_def.creature_name = CreatureLibrary.DEFAULT_NAME
		if not creature_def.creature_short_name:
			creature_def.creature_short_name = CreatureLibrary.DEFAULT_NAME
		if not creature_def.chat_theme_def:
			creature_def.chat_theme_def = CreatureLibrary.DEFAULT_CHAT_THEME_DEF.duplicate()
	return creature_def
