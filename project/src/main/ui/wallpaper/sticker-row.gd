class_name StickerRow
extends Control
"""
A row of wallpaper sprites which slowly scroll by.
"""

# the scroll velocity. only the x component is used
export (Vector2) var velocity: Vector2 setget set_velocity
export (Color) var color: Color

# sprite textures. we alternate between these textures and flip them horizontally. the second texture is optional.
export (Texture) var texture_0: Texture setget set_texture_0
export (Texture) var texture_1: Texture setget set_texture_1
var _textures: Array
var _texture_index := 0

# the sticker furthest back in the row. when it moves enough a new sticker is created to take its place
var _back_sticker: TextureRect

func _physics_process(delta: float) -> void:
	if not velocity:
		# nothing to do if velocity is 0
		return
	
	# recalculate the back sticker
	if get_child_count() and not _back_sticker:
		var children := get_children()
		if is_inside_tree() and children:
			_back_sticker = children[0]
			for child_obj in children:
				var child: TextureRect = child_obj
				if velocity.x < 0 and child.rect_position.x > _back_sticker.rect_position.x:
					_back_sticker = child
				elif velocity.x > 0 and child.rect_position.x < _back_sticker.rect_position.x:
					_back_sticker = child
	
	# add stickers if we need more
	if rect_size.y == 0:
		push_warning("illegal sticker row rect size (%s)" % [rect_size])
	elif velocity.x == 0:
		push_warning("illegal velocity (%s)" % [velocity])
	else:
		if velocity.x > 0:
			while not _back_sticker or _back_sticker.rect_position.x > 0:
				_add_sticker()
		elif velocity.x < 0:
			while not _back_sticker or _back_sticker.rect_position.x < rect_size.x + rect_size.x:
				_add_sticker()
	
	# remove stickers if we have too many
	for child_obj in get_children():
		var child: TextureRect = child_obj
		child.rect_position += delta * velocity
		if velocity.x > 0:
			if child.rect_position.x > rect_size.x + rect_size.y:
				child.queue_free()
		if velocity.x < 0:
			if child.rect_position.x < 0 - rect_size.x * 2:
				child.queue_free()


func set_texture_0(new_texture_0: Texture) -> void:
	texture_0 = new_texture_0
	_refresh_textures()


func set_texture_1(new_texture_1: Texture) -> void:
	texture_1 = new_texture_1
	_refresh_textures()


func set_velocity(new_velocity: Vector2) -> void:
	velocity = new_velocity
	# force recalculation of the back sticker
	_back_sticker = null


"""
Adds a sticker to the row.

The new sticker is placed behind the back sticker.
"""
func _add_sticker() -> void:
	var new_sticker := TextureRect.new()
	new_sticker.texture = _textures[_texture_index]
	new_sticker.expand = true
	new_sticker.rect_size = Vector2(rect_size.y, rect_size.y)
	if velocity.x > 0:
		if _back_sticker == null:
			new_sticker.rect_position.x = rect_size.x
		else:
			new_sticker.rect_position.x = _back_sticker.rect_position.x - rect_size.y * 2
	else:
		if _back_sticker == null:
			new_sticker.rect_position.x = 0
		else:
			new_sticker.rect_position.x = _back_sticker.rect_position.x + rect_size.y * 2
	new_sticker.flip_h = randf() > 0.5
	new_sticker.modulate = color
	add_child(new_sticker)
	_texture_index = (_texture_index + 1) % _textures.size()
	_back_sticker = new_sticker


"""
Refresh the texture array and texture index based on the assigned textures.
"""
func _refresh_textures() -> void:
	_textures = []
	if texture_0:
		_textures.append(texture_0)
	if texture_1:
		_textures.append(texture_1)
	_texture_index = _texture_index % _textures.size()
