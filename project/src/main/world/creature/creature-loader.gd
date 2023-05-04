#tool #uncomment to view creature in editor
extends Node
## Loads creature resources based on creature definitions. For example, a creature definition might describe high-level
## information about the creature's appearance, such as 'she has red eyes' or 'she has a star on her forehead'. This
## class converts that information into granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030', and
## also loads resource files specific to each creature.

## Color inside a creature's mouth
const PINK_INSIDE_COLOR := Color("f39274")

const SHADOW_ALPHA := 0.25

## AnimationPlayer scenes with animations for each type of mouth
var _mouth_player_scenes := {
	"1": preload("res://src/main/world/creature/Mouth1Player.tscn"),
	"2": preload("res://src/main/world/creature/Mouth2Player.tscn"),
	"3": preload("res://src/main/world/creature/Mouth3Player.tscn"),
	"4": preload("res://src/main/world/creature/Mouth4Player.tscn"),
	"5": preload("res://src/main/world/creature/Mouth5Player.tscn"),
	"6": preload("res://src/main/world/creature/Mouth6Player.tscn"),
	"7": preload("res://src/main/world/creature/Mouth7Player.tscn"),
}

## AnimationPlayer scenes with animations for each type of ear
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
	"13": preload("res://src/main/world/creature/Ear13Player.tscn"),
	"14": preload("res://src/main/world/creature/Ear14Player.tscn"),
	"15": preload("res://src/main/world/creature/Ear15Player.tscn"),
}

## Scenes which draw different bodies
var _body_shape_scenes := {
	"1": preload("res://src/main/world/creature/Body1Shape.tscn"),
	"2": preload("res://src/main/world/creature/Body2Shape.tscn"),
}

## Scenes which draw belly colors for different bodies
var _belly_scenes := {
	"1 1": preload("res://src/main/world/creature/Body1Belly1.tscn"),
	"1 2": preload("res://src/main/world/creature/Body1Belly2.tscn"),
	"2 1": preload("res://src/main/world/creature/Body2Belly1.tscn"),
	"2 2": preload("res://src/main/world/creature/Body2Belly2.tscn"),
}

## Scenes which draw shadows for different bodies
var _shadows_scenes := {
	"1": preload("res://src/main/world/creature/Body1Shadows.tscn"),
	"2": preload("res://src/main/world/creature/Body2Shadows.tscn"),
}

## Scenes which draw 'neck blends' which blend the neck with the back of the head
var _neck_blend_scenes_new := {
	"1": preload("res://src/main/world/creature/Body1NeckBlend.tscn"),
	"2": preload("res://src/main/world/creature/Body2NeckBlend.tscn"),
}

## AnimationPlayers which rearrange body parts for different bodies
var _fat_sprite_mover_scenes := {
	"1": preload("res://src/main/world/creature/FatSpriteMover1.tscn"),
	"2": preload("res://src/main/world/creature/FatSpriteMover2.tscn"),
}

var _dna_alternatives := DnaAlternatives.new()


## Returns a random creature definition.
##
## Parameters:
## 	'include_predefined_customers': If 'true' the function has a chance to return a creature from a library of
## 		predefined creatures instead of a randomly generated one.
##
## 	'creature_type': (Optional) Required creature type. If specified, creatures will be skipped in the
## 		secondary queue until one conforms to the specified type.
func random_customer_def(include_predefined_customers: bool = false,
		creature_type: Creatures.Type = Creatures.Type.DEFAULT) -> CreatureDef:
	var result: CreatureDef
	if include_predefined_customers \
			and PlayerData.customer_queue.has_standard_customer() \
			and randf() < 0.2:
		
		# We check the next 8 creatures for one which matches the specified type. If we check too few creatures, we
		# won't find one. If we check too many, we'll aggressively advance the creature queue. 8 feels about right.
		for i in range(8):
			if PlayerData.customer_queue.standard_index + i >= PlayerData.customer_queue.standard_queue.size():
				break
			var potential_result: CreatureDef = \
					PlayerData.customer_queue.standard_queue[PlayerData.customer_queue.standard_index + i]
			if not potential_result.is_customer():
				continue
			if DnaUtils.dna_matches_type(potential_result.dna, creature_type):
				result = potential_result
				PlayerData.customer_queue.standard_index += i + 1
				break
	
	if not result:
		result = CreatureDef.new()
		result.dna = DnaUtils.random_dna(creature_type)
		result.rename(NameGeneratorLibrary.generate_name(creature_type))
		result.chat_theme = chat_theme(result.dna)
		# set the filler ID, but not the fatness. the fatness attribute in the CreatureDef is the creature's natural
		# fatness -- not their fatness after being stuffed
		result.creature_id = PlayerData.creature_library.next_filler_id()
	return result


## Returns a chat theme definition for a generated creature.
func chat_theme(dna: Dictionary) -> ChatTheme:
	var new_theme := ChatTheme.new()
	new_theme.accent_scale = Utils.rand_value([
			0.50, 0.58, 0.67, 0.75, 0.88,
			1.00, 1.15, 1.33, 1.50, 1.75,
			2.00, 2.30, 2.66, 3.00, 3.50,
			4.00, 4.60, 5.33, 6.00, 7.00,
			8.00
	])
	new_theme.accent_swapped = randf() > 0.5
	new_theme.accent_texture_index = randi() % ChatLinePanel.CHAT_TEXTURE_COUNT
	new_theme.color = dna.body_rgb
	new_theme.dark = randf() > 0.5
	return new_theme


## Returns an AnimationPlayer for the specified type type of mouth.
func new_mouth_player(mouth_key: String) -> AnimationPlayer:
	var result: AnimationPlayer
	if _mouth_player_scenes.has(mouth_key):
		result = _mouth_player_scenes[mouth_key].instantiate()
	return result


## Returns an AnimationPlayer for the specified type of ear.
func new_ear_player(ear_key: String) -> AnimationPlayer:
	var result: AnimationPlayer
	if _ear_player_scenes.has(ear_key):
		result = _ear_player_scenes[ear_key].instantiate()
	return result


## Returns a CreatureCurve for drawing a type of body.
func new_body_shape(body_key: String) -> CreatureCurve:
	var result: CreatureCurve
	if _body_shape_scenes.has(body_key):
		result = _body_shape_scenes[body_key].instantiate()
	return result


## Returns a CreatureCurve for drawing belly colors for a type of body.
func new_belly(body_key: String, body_colors_key: String) -> CreatureCurve:
	var result: CreatureCurve
	var key := "%s %s" % [body_key, body_colors_key]
	if _belly_scenes.has(key):
		result = _belly_scenes[key].instantiate()
	return result


## Returns a Node2D containing CreatureCurves for drawing shadows for a type of body.
func new_shadows(body_key: String) -> Node2D:
	var result: Node2D
	if _shadows_scenes.has(body_key):
		result = _shadows_scenes[body_key].instantiate()
	return result


## Returns a CreatureCurve which blends the neck with the back of the head.
func new_neck_blend(body_key: String) -> CreatureCurve:
	var result: CreatureCurve
	if _neck_blend_scenes_new.has(body_key):
		result = _neck_blend_scenes_new[body_key].instantiate()
	return result


## Returns an AnimationPlayer which rearranges body parts for a type of bodyq.
func new_fat_sprite_mover(body_key: String) -> AnimationPlayer:
	var result: AnimationPlayer
	if _fat_sprite_mover_scenes.has(body_key):
		result = _fat_sprite_mover_scenes[body_key].instantiate()
	return result


## Loads all the appropriate resources and property definitions for a creature. The resulting textures are stored back
## in the 'dna' parameter which is passed in.
##
## This can also be invoked with an empty creature definition, in which case the creature definition will be populated
## with the property definitions needed to unload all of their textures and colors.
##
## Parameters:
## 	'dna': Defines high-level information about the creature's appearance, such as 'she has red eyes'. The response
## 		includes granular information such as 'her Eye/Sprint/TxMap/RGB value is ff3030'.
func load_details(dna: Dictionary) -> void:
	_load_head(dna)
	_load_body(dna)
	_load_colors(dna)


## Loads a creature texture based on a dna key/value pair.
##
## The input dna contains key/value pairs which we need to map to a texture to load, such as {'ear': '0'}. We map
## this key/value pair to a resource such as res://assets/main/world/creature/0/ear-z1.png. The input parameters
## include the dictionary of key/value pairs, which specific key/value pair we should look up, and the filename to
## associate with the key/value pair.
##
## Parameters:
## 	'dna': The dictionary of key/value pairs defining a set of textures to load.
##
## 	'key': The specific key/value pair to be looked up. If the key is empty, the value will be hard-coded to '1'.
##
## 	'filename': The stripped-down filename of the resource to look up. All creature texture files have a path of
## 		res://assets/main/world/creature/0/{something}.png, so this parameter only specifies the {something}.
func _load_texture(dna: Dictionary, node_path: String, key: String, filename: String) -> void:
	var resource_path: String
	var frame_data: String
	var resource: Resource
	if not key.is_empty() and not dna.has(key):
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
		elif Engine.is_editor_hint():
			resource = load(resource_path)
		else:
			resource = ResourceCache.get_resource(resource_path)
	
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


## Loads the resources for a creature's head based on a creature definition.
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
	
	_load_texture(dna, "Neck0/HeadBobber/Nose", "nose", "nose-packed")
	
	_load_texture(dna, "Neck0/HeadBobber/AccessoryZ0", "accessory", "accessory-z0-packed")
	_load_texture(dna, "Neck0/HeadBobber/AccessoryZ1", "accessory", "accessory-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/AccessoryZ2", "accessory", "accessory-z2-packed")


## Loads the resources for a creature's arms, legs and torso based on a creature definition.
func _load_body(dna: Dictionary) -> void:
	# All creatures have a body, but this class supports passing in an empty creature definition to unload the
	# textures from creature sprites. So we leave those textures as null if we're not explicitly told to draw the
	# creature's body.
	_load_texture(dna, "Sprint", "", "sprint-z0-packed")
	_load_texture(dna, "FarArm", "", "arm-z0-packed")
	_load_texture(dna, "FarLeg", "", "leg-z0-packed")
	_load_texture(dna, "NearLeg", "", "leg-z1-packed")
	_load_texture(dna, "NearArm", "", "arm-z1-packed")
	_load_texture(dna, "Neck0/HeadBobber/Chin", "", "chin-packed")
	
	_load_texture(dna, "Collar", "collar", "collar-packed")
	_load_texture(dna, "Bellybutton", "bellybutton", "bellybutton-packed")
	_load_texture(dna, "TailZ0", "tail", "tail-z0-packed")
	_load_texture(dna, "TailZ1", "tail", "tail-z1-packed")


## Assigns the creature's colors based on a creature definition.
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
	
	dna["property:Body:line_color"] = line_color
	dna["property:Body:body_color"] = body_color
	dna["property:Body:belly_color"] = belly_color
	dna["property:Body:shadow_color"] = Utils.to_transparent(line_color, SHADOW_ALPHA)
	
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
	_set_krgb(dna, "Neck0/HeadBobber/EmoteEyeZ0", line_color, Color.WHITE)
	_set_krgb(dna, "Neck0/HeadBobber/EmoteEyeZ1", line_color, Color.WHITE)
	_set_krgb(dna, "Neck0/HeadBobber/HairZ0", line_color, hair_color)
	_set_krgb(dna, "Neck0/HeadBobber/HairZ1", line_color, hair_color)
	_set_krgb(dna, "Neck0/HeadBobber/HairZ2", line_color, hair_color)
	_set_krgb(dna, "Neck0/HeadBobber/Head", line_color, body_color, belly_color)
	_set_krgb(dna, "TailZ0", line_color, body_color, belly_color, hair_color)
	_set_krgb(dna, "TailZ1", line_color, body_color, belly_color, hair_color)
	
	var accessory_plastic_color := plastic_color
	if dna.get("accessory") in ["4", "5"]:
		accessory_plastic_color = horn_color
	_set_krgb(dna, "Neck0/HeadBobber/AccessoryZ0", line_color, accessory_plastic_color, glass_color, Color.WHITE)
	_set_krgb(dna, "Neck0/HeadBobber/AccessoryZ1", line_color, accessory_plastic_color, glass_color, Color.WHITE)
	_set_krgb(dna, "Neck0/HeadBobber/AccessoryZ2", line_color, accessory_plastic_color, glass_color, Color.WHITE)
	
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


## Assigns shader colors for the specified creature node.
func _set_krgb(dna: Dictionary, path: String, black: Color,
		red: Color = Color.BLACK, green: Color = Color.BLACK, blue: Color = Color.BLACK):
	dna["shader:%s:black" % path] = black
	if red: dna["shader:%s:red" % path] = red
	if green: dna["shader:%s:green" % path] = green
	if blue: dna["shader:%s:blue" % path] = blue
