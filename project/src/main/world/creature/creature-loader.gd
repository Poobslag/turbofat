#tool #uncomment to view creature in editor
extends Node

"""
Loads creature resources based on creature definitions. For example, a creature definition might describe high-level
information about the creature's appearance, such as 'she has red eyes' or 'she has a star on her forehead'. This
class converts that information into granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030', and also
loads resource files specific to each creature.
"""

# the creature id used for the instructor who leads the tutorials
const INSTRUCTOR_ID := "#instructor#"

# the creature definition path for the instructor who leads tutorials
const INSTRUCTOR_PATH := "res://assets/main/creatures/instructor/creature.json"

# How large creatures can grow; 5.0 = 5x normal size
const MAX_FATNESS := 10.0

# How long it takes a creature to grow to a new size
const GROWTH_SECONDS := 0.12

# The color inside a creature's mouth
const PINK_INSIDE_COLOR := Color("f39274")

# AnimationPlayer scenes with animations for each type of mouth
var _mouth_player_scenes := {
	"1": preload("res://src/main/world/creature/Mouth1Player.tscn"),
	"2": preload("res://src/main/world/creature/Mouth2Player.tscn"),
	"3": preload("res://src/main/world/creature/Mouth3Player.tscn"),
	"4": preload("res://src/main/world/creature/Mouth4Player.tscn"),
	"5": preload("res://src/main/world/creature/Mouth5Player.tscn"),
}

# AnimationPlayer scenes with animations for each type of ear
var _ear_player_scenes := {
	"1": preload("res://src/main/world/creature/Ear1Player.tscn"),
	"2": preload("res://src/main/world/creature/Ear2Player.tscn"),
	"3": preload("res://src/main/world/creature/Ear3Player.tscn"),
	"4": preload("res://src/main/world/creature/Ear4Player.tscn"),
	"5": preload("res://src/main/world/creature/Ear5Player.tscn"),
	"6": preload("res://src/main/world/creature/Ear6Player.tscn"),
	"7": preload("res://src/main/world/creature/EarPlayerDefault.tscn"),
	"8": preload("res://src/main/world/creature/EarPlayerDefault.tscn"),
	"9": preload("res://src/main/world/creature/EarPlayerDefault.tscn"),
	"10": preload("res://src/main/world/creature/EarPlayerDefault.tscn"),
	"11": preload("res://src/main/world/creature/Ear11Player.tscn"),
	"12": preload("res://src/main/world/creature/Ear12Player.tscn"),
}

# Scenes which draw different bodies
var _body_scenes := {
	"1": preload("res://src/main/world/creature/Body1.tscn"),
	"2": preload("res://src/main/world/creature/Body2.tscn"),
}

# Scenes which draw belly colors for different bodies
var _body_colors_scenes := {
	"1": preload("res://src/main/world/creature/Body1Colors.tscn"),
	"2": preload("res://src/main/world/creature/Body2Colors.tscn"),
}

# Scenes which draw body shadows for different bodies
var _body_shadows_scenes := {
	"1": preload("res://src/main/world/creature/Body1Shadows.tscn"),
	"2": preload("res://src/main/world/creature/Body2Shadows.tscn"),
}

# AnimationPlayers which rearrange body parts for different bodies
var _fat_sprite_mover_scenes := {
	"1": preload("res://src/main/world/creature/FatSpriteMover1.tscn"),
	"2": preload("res://src/main/world/creature/FatSpriteMover2.tscn"),
}

var _name_generator := NameGenerator.new()

var _dna_alternatives := DnaAlternatives.new()

func _ready() -> void:
	_name_generator.load_american_animals()


"""
Returns a random creature definition.
"""
func random_def() -> CreatureDef:
	var result: CreatureDef
	if PlayerData.creature_queue.has_secondary_creature() and randf() < 0.2:
		result = PlayerData.creature_queue.pop_secondary_creature()
	else:
		result = CreatureDef.new()
		result.dna = DnaUtils.random_creature_palette()
		result.creature_name = _name_generator.generate_name()
		result.creature_short_name = NameUtils.sanitize_short_name(result.creature_name)
		result.chat_theme_def = chat_theme_def(result.dna)
		# set the filler ID, but not the fatness. the fatness attribute in the CreatureDef is the creature's natural
		# fatness -- not their fatness after being stuffed
		result.creature_id = PlayerData.creature_library.next_filler_id()
	return result


"""
Returns a chat theme definition for a generated creature.
"""
func chat_theme_def(dna: Dictionary) -> Dictionary:
	var new_def: Dictionary = PlayerData.creature_library.player_def.chat_theme_def.duplicate()
	new_def.color = dna.body_rgb
	return new_def


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
Returns a CreatureCurve for drawing a type of body.
"""
func new_body(body_key: String) -> CreatureCurve:
	var result: CreatureCurve
	if _body_scenes.has(body_key):
		result = _body_scenes[body_key].instance()
	return result


"""
Returns a Node2D for drawing belly colors for a type of body.
"""
func new_body_colors(body_key: String) -> Node2D:
	var result: Node2D
	if _body_colors_scenes.has(body_key):
		result = _body_colors_scenes[body_key].instance()
	return result


"""
Returns a Node2D for drawing shadows for a type of body.
"""
func new_body_shadows(body_key: String) -> Node2D:
	var result: Node2D
	if _body_shadows_scenes.has(body_key):
		result = _body_shadows_scenes[body_key].instance()
	return result


"""
Returns an AnimationPlayer which rearranges body parts for a type of bodyq.
"""
func new_fat_sprite_mover(body_key: String) -> AnimationPlayer:
	var result: AnimationPlayer
	if _fat_sprite_mover_scenes.has(body_key):
		result = _fat_sprite_mover_scenes[body_key].instance()
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


func load_creature_def_by_id(id: String) -> CreatureDef:
	var path: String
	match id:
		INSTRUCTOR_ID:
			path = INSTRUCTOR_PATH
		_:
			path = "res://assets/main/creatures/primary/%s/creature.json" % id
	return CreatureDef.new().from_json_path(path) as CreatureDef


"""
Loads a creature texture based on a dna key/value pair.

The input dna contains key/value pairs which we need to map to a texture to load, such as {'ear': '0'}. We map
this key/value pair to a resource such as res://assets/main/world/creature/0/ear-z1.png. The input parameters include
the dictionary of key/value pairs, which specific key/value pair we should look up, and the filename to associate with
the key/value pair.

Parameters:
	'dna': The dictionary of key/value pairs defining a set of textures to load.
	
	'key': The specific key/value pair to be looked up. If the key is empty, the value will be hard-coded to '1'.
	
	'filename': The stripped-down filename of the resource to look up. All creature texture files have a path of
		res://assets/main/world/creature/0/{something}.png, so this parameter only specifies the {something}.
"""
func _load_texture(dna: Dictionary, node_path: String, key: String, filename: String) -> void:
	# load the texture resource
	var resource_path: String
	var frame_data: String
	var resource: Resource
	if key and not dna.has(key):
		# The key was not specified in the creature definition. This is not an error condition, a creature might not
		# have an 'ear' key if she doesn't have ears.
		pass
	else:
		var dna_value := _dna_value(dna, key)
		
		resource_path = "res://assets/main/world/creature/%s/%s.png" % [dna_value, filename]
		frame_data = "res://assets/main/world/creature/%s/%s.json" % [dna_value, filename]
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


func _dna_value(dna: Dictionary, key: String) -> String:
	var dna_value: String = dna[key] if key else "1"
	
	var alternative := _dna_alternatives.alternative(dna, key, dna_value)
	if alternative:
		dna_value = alternative
	
	return dna_value


"""
Loads the resources for a creature's head based on a creature definition.
"""
func _load_head(dna: Dictionary) -> void:
	_load_texture(dna, "Neck0/HeadBobber/Head", "head", "head-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/CheekZ0", "cheek", "cheek-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/CheekZ1", "cheek", "cheek-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/CheekZ2", "cheek", "cheek-z2-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/EarZ0", "ear", "ear-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/EarZ1", "ear", "ear-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/EarZ2", "ear", "ear-z2-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/EyeZ0", "eye", "eye-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/EyeZ1", "eye", "eye-z1-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/EmoteEyeZ0", "emote-eye", "emote-eye-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/EmoteEyeZ1", "emote-eye", "emote-eye-z1-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/HairZ0", "hair", "hair-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/HairZ1", "hair", "hair-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/HairZ2", "hair", "hair-z2-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/HornZ0", "horn", "horn-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/HornZ1", "horn", "horn-z1-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/Mouth", "mouth", "mouth-packed")
	_load_texture(dna, "Neck0/HeadBobber/Food", "mouth", "food-packed")
	_load_texture(dna, "Neck0/HeadBobber/FoodLaser", "mouth", "food-laser-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/Nose", "nose", "nose-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/AccessoryZ0", "accessory", "accessory-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/AccessoryZ1", "accessory", "accessory-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/AccessoryZ2", "accessory", "accessory-z2-packed")


"""
Loads the resources for a creature's arms, legs and torso based on a creature definition.
"""
func _load_body(dna: Dictionary) -> void:
	# All creatures have a body, but this class supports passing in an empty creature definition to unload the
	# textures from creature sprites. So we leave those textures as null if we're not explicitly told to draw the
	# creature's body.
	_load_texture(dna, "Sprint", "", "sprint-z0-packed")
	_load_texture(dna, "FarArm", "", "arm-z0-packed")
	_load_texture(dna, "FarLeg", "", "leg-z0-packed")
	_load_texture(dna, "Body/Viewport/Body/NeckBlend", "", "neck-blend-packed")
	_load_texture(dna, "NearLeg", "", "leg-z1-packed")
	_load_texture(dna, "NearArm", "", "arm-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/Chin", "", "chin-packed")
	
	_load_texture(dna, "Collar", "collar", "collar-packed")
	_load_texture(dna, "Bellybutton", "bellybutton", "bellybutton-packed")
	_load_texture(dna, "TailZ0", "tail", "tail-z0-packed")
	_load_texture(dna, "TailZ1", "tail", "tail-z1-packed")
	
	dna["property:BellyColors/Viewport/Body:belly"] = dna.get("belly", 0)


"""
Assigns the creature's colors based on a creature definition.
"""
func _load_colors(dna: Dictionary) -> void:
	var belly_color: Color
	if dna.has("belly_rgb"):
		belly_color = Color(dna.belly_rgb)
	
	var body_color: Color
	if dna.has("body_rgb"):
		body_color = Color(dna.body_rgb)
	
	var cloth_color: Color
	if dna.has("cloth_rgb"):
		cloth_color = Color(dna.cloth_rgb)
	
	var glass_color: Color
	if dna.has("glass_rgb"):
		glass_color = Color(dna.glass_rgb)
	
	var hair_color: Color
	if dna.has("hair_rgb"):
		hair_color = Color(dna.hair_rgb)
	
	var horn_color: Color
	if dna.has("horn_rgb"):
		horn_color = Color(dna.horn_rgb)
	
	var line_color: Color
	if dna.has("line_rgb"):
		line_color = Color(dna.line_rgb)
	
	var plastic_color: Color
	if dna.has("plastic_rgb"):
		plastic_color = Color(dna.plastic_rgb)
	
	_set_krgb(dna, "Body", line_color, body_color, belly_color)
	_set_krgb(dna, "Collar", line_color, cloth_color, hair_color)
	_set_krgb(dna, "EmoteBody", line_color)
	_set_krgb(dna, "FarArm", line_color, body_color)
	_set_krgb(dna, "FarLeg", line_color, body_color)
	_set_krgb(dna, "NearArm", line_color, body_color)
	_set_krgb(dna, "NearLeg", line_color, body_color)
	_set_krgb(dna, "Neck0/HeadBobber/EarZ0", line_color, body_color, hair_color, horn_color)
	_set_krgb(dna, "Neck0/HeadBobber/EarZ1", line_color, body_color, hair_color, horn_color)
	_set_krgb(dna, "Neck0/HeadBobber/EarZ2", line_color, body_color, hair_color, horn_color)
	_set_krgb(dna, "Neck0/HeadBobber/EmoteArmZ0", line_color, body_color)
	_set_krgb(dna, "Neck0/HeadBobber/EmoteArmZ1", line_color, body_color)
	_set_krgb(dna, "Neck0/HeadBobber/EmoteBrain", line_color)
	_set_krgb(dna, "Neck0/HeadBobber/EmoteEyeZ0", line_color, Color.white)
	_set_krgb(dna, "Neck0/HeadBobber/EmoteEyeZ1", line_color, Color.white)
	_set_krgb(dna, "Neck0/HeadBobber/HairZ0", line_color, hair_color)
	_set_krgb(dna, "Neck0/HeadBobber/HairZ1", line_color, hair_color)
	_set_krgb(dna, "Neck0/HeadBobber/HairZ2", line_color, hair_color)
	_set_krgb(dna, "Neck0/HeadBobber/Head", line_color, body_color, belly_color)
	_set_krgb(dna, "TailZ0", line_color, body_color, belly_color, hair_color)
	_set_krgb(dna, "TailZ1", line_color, body_color, belly_color, hair_color)
	
	var accessory_plastic_color := plastic_color
	if dna.get("accessory") in ["4", "5"]:
		accessory_plastic_color = horn_color
	_set_krgb(dna, "Neck0/HeadBobber/AccessoryZ0", line_color, accessory_plastic_color, glass_color, Color.white)
	_set_krgb(dna, "Neck0/HeadBobber/AccessoryZ1", line_color, accessory_plastic_color, glass_color, Color.white)
	_set_krgb(dna, "Neck0/HeadBobber/AccessoryZ2", line_color, accessory_plastic_color, glass_color, Color.white)
	
	var bellybutton_color := body_color if dna.get("belly") in ["0"] else belly_color
	_set_krgb(dna, "Bellybutton", line_color, bellybutton_color)
	
	var cheek_skin_color := belly_color if dna.get("head") in ["2", "3", "5"] else body_color
	var cheek_eye_color := belly_color if dna.get("head") in ["2", "3", "4", "5"] else body_color
	_set_krgb(dna, "Neck0/HeadBobber/CheekZ0", line_color, cheek_skin_color, cheek_eye_color)
	_set_krgb(dna, "Neck0/HeadBobber/CheekZ1", line_color, cheek_skin_color, cheek_eye_color)
	_set_krgb(dna, "Neck0/HeadBobber/CheekZ2", line_color, cheek_skin_color, cheek_eye_color)
	
	var chin_skin_color := belly_color if dna.get("head") in ["2", "3", "5"] else body_color
	_set_krgb(dna, "Neck0/HeadBobber/Chin", line_color, chin_skin_color)
	
	var mouth_skin_color := body_color
	if dna.get("mouth") in ["4"]:
		# beaks
		mouth_skin_color = horn_color
	elif dna.get("head") in ["2", "3", "5"]:
		# bottom half of the head is belly-colored
		mouth_skin_color = belly_color
	_set_krgb(dna, "Neck0/HeadBobber/Mouth", line_color, mouth_skin_color, PINK_INSIDE_COLOR, horn_color)
	
	var nose_skin_color := belly_color if dna.get("head") in ["2", "3"] else body_color
	_set_krgb(dna, "Neck0/HeadBobber/Nose", line_color, nose_skin_color)
	
	var eye_color: Color
	var eye_shine_color: Color
	var eye_skin_color := belly_color if dna.get("head") in ["2", "4", "5"] else body_color
	if dna.has("eye_rgb"):
		eye_color = Color(dna.eye_rgb.split(" ")[0])
		eye_shine_color = Color(dna.eye_rgb.split(" ")[1])
	_set_krgb(dna, "Neck0/HeadBobber/EyeZ0", line_color, eye_skin_color, eye_color, eye_shine_color)
	_set_krgb(dna, "Neck0/HeadBobber/EyeZ1", line_color, eye_skin_color, eye_color, eye_shine_color)

	_set_krgb(dna, "Neck0/HeadBobber/HornZ0", line_color, body_color, horn_color)
	_set_krgb(dna, "Neck0/HeadBobber/HornZ1", line_color, body_color, horn_color)


"""
Assigns shader colors for the specified creature node.
"""
func _set_krgb(dna: Dictionary, path: String, black: Color,
		red: Color = Color.black, green: Color = Color.black, blue: Color = Color.black):
	dna["shader:%s:black" % path] = black
	if red: dna["shader:%s:red" % path] = red
	if green: dna["shader:%s:green" % path] = green
	if blue: dna["shader:%s:blue" % path] = blue
