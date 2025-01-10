#tool #uncomment to view creature in editor
extends Node
## Assigns and unassigns textures and animations based on a creature's dna.
##
## This needs to be separate from the CreatureVisuals node because it must continue running while paused. Otherwise the
## creature editor will have strange behavior, particularly in its color picker.

## emitted when a creature's textures and animations are loaded
signal dna_loaded

## Maximum amount of microseconds to spend setting shader params in each frame. This is capped to avoid frame
## drops.
const MAX_SHADER_USEC_PER_FRAME := 120

## Array of string shader keys from the dna which haven't yet been loaded. Instead of loading these up front, we load
## these gradually over time. Setting shader params is slow and setting too many at once causes frame drops.
var _pending_shader_keys: Array

onready var _creature_visuals: CreatureVisuals = get_parent()

func _process(_delta: float) -> void:
	if _pending_shader_keys:
		# if there are any pending shader keys, we load a few each frame. Setting shader params is slow and setting
		# too many at once causes frame drops
		var start_ticks_usec := Time.get_ticks_usec()
		while Time.get_ticks_usec() - start_ticks_usec < MAX_SHADER_USEC_PER_FRAME and _pending_shader_keys:
			var key: String = _pending_shader_keys.pop_front()
			var node_path: String = key.split(":")[1]
			var shader_param: String = key.split(":")[2]
			var shader_value = _creature_visuals.dna[key]
			
			# Creature data from old versions of the game might try to update shaders on nonexistent nodes or
			# nonexistent materials. We check for null to avoid a crash.
			if _creature_visuals.has_node(node_path) and _creature_visuals.get_node(node_path).material:
				_creature_visuals.get_node(node_path).material.set_shader_param(shader_param, shader_value)
		
		if not _pending_shader_keys:
			emit_signal("dna_loaded")


## Unassigns the textures and animations for the creature.
##
## Different body parts have different animations and textures. Before changing the creature's appearance, any old
## textures and animations need to be stopped and removed, and any signals disconnected. This method handles all of
## that.
func unload_dna() -> void:
	_creature_visuals.get_node("Animations/EmotePlayer").unemote_immediate()
	for node_path in [
		"Bellybutton",
		"Collar",
		"FarArm",
		"FarLeg",
		"NearArm",
		"NearLeg",
		"Sprint",
		"TailZ0",
		"TailZ1",
		"Neck0/HeadBobber",
		"Neck0/HeadBobber/AccessoryZ0",
		"Neck0/HeadBobber/AccessoryZ1",
		"Neck0/HeadBobber/AccessoryZ2",
		"Neck0/HeadBobber/CheekZ0",
		"Neck0/HeadBobber/CheekZ1",
		"Neck0/HeadBobber/CheekZ2",
		"Neck0/HeadBobber/Chin",
		"Neck0/HeadBobber/EarZ0",
		"Neck0/HeadBobber/EarZ1",
		"Neck0/HeadBobber/EarZ2",
		"Neck0/HeadBobber/EmoteEyeZ0",
		"Neck0/HeadBobber/EmoteEyeZ1",
		"Neck0/HeadBobber/EyeZ0",
		"Neck0/HeadBobber/EyeZ1",
		"Neck0/HeadBobber/HairZ0",
		"Neck0/HeadBobber/HairZ1",
		"Neck0/HeadBobber/HairZ2",
		"Neck0/HeadBobber/Head",
		"Neck0/HeadBobber/HornZ0",
		"Neck0/HeadBobber/HornZ1",
		"Neck0/HeadBobber/Mouth",
		"Neck0/HeadBobber/Nose",
	]:
		if _creature_visuals.has_node(node_path):
			var node: Node2D = _creature_visuals.get_node(node_path)
			if node is PackedSprite:
				var packed_sprite: PackedSprite = node as PackedSprite
				packed_sprite.texture = null
				packed_sprite.frame_data = ""
			if node.get("material"):
				node.material.set_shader_param("red", Color.black)
				node.material.set_shader_param("green", Color.black)
				node.material.set_shader_param("blue", Color.black)
				node.material.set_shader_param("black", Color.black)
	
	_creature_visuals.get_node("Neck0/HeadBobber/Mouth").z_index = 0
	_creature_visuals.get_node("Neck0/HeadBobber").position = Vector2(0, -100)
	_creature_visuals.rescale(1.00)
	
	_remove_dna_node("Animations/MouthPlayer")
	_remove_dna_node("Animations/EarPlayer")
	_remove_dna_node("Animations/FatSpriteMover")
	
	_remove_dna_node("Body/BodyShape")
	_remove_dna_node("Body/Belly")
	_remove_dna_node("Body/NeckBlend")
	_remove_dna_node("Body/Shadows")
	_creature_visuals.get_node("Body").refresh_children()
	_creature_visuals.get_node("Animations").reset()


## Assigns the textures and animations based on the creature's dna.
##
## This method assumes that any existing animations and connections have been disconnected.
func load_dna() -> void:
	if _creature_visuals.dna.has("mouth") and _creature_visuals.dna.mouth != "0":
		_add_dna_node(CreatureLoader.new_mouth_player(_creature_visuals.dna.mouth), "mouth",
				_creature_visuals.dna.mouth, _creature_visuals.get_node("Animations"))
	
	if _creature_visuals.dna.has("ear") and _creature_visuals.dna.ear != "0":
		_add_dna_node(CreatureLoader.new_ear_player(_creature_visuals.dna.ear), "ear",
				_creature_visuals.dna.ear, _creature_visuals.get_node("Animations"))
	
	if _creature_visuals.dna.has("body"):
		_add_dna_node(CreatureLoader.new_fat_sprite_mover(_creature_visuals.dna.body), "fat sprite mover",
				_creature_visuals.dna.body, _creature_visuals.get_node("Animations"))
		
		var body: Body = _creature_visuals.get_node("Body")
		_add_dna_node(CreatureLoader.new_body_shape(_creature_visuals.dna.body),
				"body shape", _creature_visuals.dna.body, body)
		if _creature_visuals.dna.has("belly") and _creature_visuals.dna.get("belly") != "0":
			_add_dna_node(CreatureLoader.new_belly(_creature_visuals.dna.body, _creature_visuals.dna.belly),
					"belly", "%s %s" % [_creature_visuals.dna.body, _creature_visuals.dna.belly], body)
		_add_dna_node(CreatureLoader.new_neck_blend(_creature_visuals.dna.body),
				"neck blend", "%s" % [_creature_visuals.dna.body], body)
		_add_dna_node(CreatureLoader.new_shadows(_creature_visuals.dna.body),
				"shadows", _creature_visuals.dna.body, body)
		body.refresh_children()
	
	if _creature_visuals.get_node("Animations").has_node("MouthPlayer"):
		_creature_visuals.mouth_player = _creature_visuals.get_node("Animations").get_node("MouthPlayer")
	
	for key in _creature_visuals.dna.keys():
		if key.find("property:") == 0:
			var node_path: String = key.split(":")[1]
			var property_name: String = key.split(":")[2]
			var property_value = _creature_visuals.dna[key]
			if _creature_visuals.has_node(node_path):
				_creature_visuals.get_node(node_path).set(property_name, property_value)
	
	_pending_shader_keys.clear()
	for key in _creature_visuals.dna.keys():
		if key.find("shader:") == 0:
			_pending_shader_keys.append(key)
	
	_creature_visuals.rescale(0.60 if _creature_visuals.dna.get("body") == "2" else 1.00)
	_creature_visuals.visible = true
	
	# initialize creature curves, and reset the mouth/eye frame to avoid a strange transition frame
	_creature_visuals.reset_frames()
	
	if not _pending_shader_keys:
		emit_signal("dna_loaded")


## Removes a 'dna node', one which swaps out based on the creature's DNA.
func _remove_dna_node(path: NodePath) -> void:
	if not _creature_visuals.has_node(path):
		return
	
	var node := _creature_visuals.get_node(path)
	# These nodes must be immediately removed to avoid name conflicts with the nodes which replace them.
	node.get_parent().remove_child(node)
	node.queue_free()


## Adds a 'dna node', one which swaps out based on the creature's DNA.
##
## Parameters:
## 	'node': The node to add
##
## 	'key_message': The node description to display in error messages
##
## 	'value_message': The node value to display in error messages
##
## 	'parent': The parent of the new node
func _add_dna_node(node: Node, key_message: String, value_message: String, parent: Node = self) -> void:
	if not node:
		push_warning("Invalid %s: %s" % [key_message, value_message])
		return
	
	parent.add_child(node)
	node.owner = _creature_visuals
	node.creature_visuals_path = node.get_path_to(_creature_visuals)
