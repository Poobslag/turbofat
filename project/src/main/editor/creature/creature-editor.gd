class_name CreatureEditor
extends Node
"""
A graphical creature editor which lets players design their own creatures.
"""

# emitted when the center creature is first initialized, and later when it is swapped out
signal center_creature_changed

enum ColorMode {
	RANDOM_COLORS, # generate colors with random RGB values
	THEME_COLORS, # load colors from preset themes
	SIMILAR_COLORS, # generate colors similar to the current colors
}

const RANDOM_COLORS := ColorMode.RANDOM_COLORS
const THEME_COLORS := ColorMode.THEME_COLORS
const SIMILAR_COLORS := ColorMode.SIMILAR_COLORS

# weighted distribution of 'fatnesses' in the range [1.0, 10.0]. most creatures are skinny.
const FATNESSES := [
	1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
	1.1, 1.2, 1.3, 1.5,
	1.8, 2.3,
]

var _rng := RandomNumberGenerator.new()
var _next_line_color_index := 0

# key: allele
# value: values which have been randomly chosen by the 'tweak dna' button
var _recent_tweaked_allele_values := {}

# generates random names
var _name_generator: NameGenerator

# the creature the player is editing
onready var center_creature: Creature = $World/Creatures/CenterCreature

# alternative creatures the player can choose
onready var outer_creatures := [
	$World/Creatures/NwCreature,
	$World/Creatures/NeCreature,
	$World/Creatures/WCreature,
	$World/Creatures/ECreature,
	$World/Creatures/SwCreature,
	$World/Creatures/SeCreature,
]

# the UI which tracks things like mutagen level and locked/unlocked alleles
onready var _mutate_ui := $Ui/TabContainer/Mutate

func _ready() -> void:
	_name_generator = NameGenerator.new()
	_name_generator.add_seed_resource("res://assets/main/editor/creature/animals.txt")
	_name_generator.add_seed_resource("res://assets/main/editor/creature/american-male-given-names.txt")
	_name_generator.add_seed_resource("res://assets/main/editor/creature/american-female-given-names.txt")
	_name_generator.min_length = 5
	_name_generator.max_length = 11
	
	Breadcrumb.connect("trail_popped", self, "_on_Breadcrumb_trail_popped")
	
	for allele in ["cheek", "eye", "ear", "horn", "mouth", "nose", "collar", "belly"]:
		_recent_tweaked_allele_values[allele] = []
	
	center_creature.set_meta("main_creature", true)
	$World/Creatures/NeCreature.set_meta("nametag_right", true)
	$World/Creatures/ECreature.set_meta("nametag_right", true)
	$World/Creatures/SeCreature.set_meta("nametag_right", true)
	
	center_creature.creature_def = PlayerData.creature_library.player_def
	emit_signal("center_creature_changed")
	mutate_all_creatures()


"""
Returns a chat theme definition for a generated creature.
"""
func _chat_theme_def(dna: Dictionary) -> Dictionary:
	var new_def := PlayerData.creature_library.player_def.chat_theme_def.duplicate()
	new_def.color = dna.body_rgb
	return new_def


"""
Regenerates all of the outer creatures to be variations of the center creature.

Any number of aspects of the creature are changed.
"""
func mutate_all_creatures() -> void:
	for creature_obj in outer_creatures:
		_mutate_creature(creature_obj)


"""
Regenerates a creature to be a variation of the center creature.

The amount of variance depends on the 'mutagen' level. The mutated alleles are randomly chosen depend on the player's
locked/unlocked alleles.
"""
func _mutate_creature(creature: Creature) -> void:
	var new_palette: Dictionary = _palette()
	
	# copy the center creature's dna, name, weight
	creature.creature_def = center_creature.creature_def
	var dna := {}
	for allele in ["line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb",
		"cheek", "eye", "ear", "horn", "mouth", "nose", "collar", "belly"]:
		if center_creature.dna.has(allele):
			dna[allele] = center_creature.dna[allele]
	
	# mutate the appropriate alleles
	for allele in _alleles_to_mutate():
		match allele:
			"name":
				creature.creature_name = _name_generator.generate_name()
				creature.creature_short_name = NameUtils.sanitize_short_name(creature.creature_name)
			"fatness":
				var new_fatnesses := FATNESSES.duplicate()
				while new_fatnesses.has(creature.get_visual_fatness()):
					new_fatnesses.erase(creature.get_visual_fatness())
				var new_fatness: float = Utils.rand_value(new_fatnesses)
				creature.set_fatness(new_fatness)
				creature.set_visual_fatness(new_fatness)
			"body_rgb":
				dna["line_rgb"] = new_palette["line_rgb"]
				dna["body_rgb"] = new_palette["body_rgb"]
			"all_rgb":
				dna["line_rgb"] = new_palette["line_rgb"]
				dna["body_rgb"] = new_palette["body_rgb"]
				dna["belly_rgb"] = new_palette["belly_rgb"]
				dna["cloth_rgb"] = new_palette["cloth_rgb"]
				dna["eye_rgb"] = new_palette["eye_rgb"]
				dna["horn_rgb"] = new_palette["horn_rgb"]
			"line_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb":
				dna[allele] = new_palette[allele]
			_:
				var new_alleles := DnaUtils.weighted_allele_values(dna, allele)
				while new_alleles.has(dna[allele]):
					new_alleles.erase(dna[allele])
				if new_alleles:
					dna[allele] = Utils.rand_value(new_alleles)
	
	creature.dna = dna
	creature.chat_theme_def = _chat_theme_def(dna)


"""
Regenerates all of the outer creatures to be variations of the center creature.

Only one aspect of the creature is changed. We select a value which is different from the creature's current value, and
which hasn't been selected recently.
"""
func tweak_all_creatures(allele: String, color_mode: int = THEME_COLORS) -> void:
	for creature_obj in outer_creatures:
		_tweak_creature(creature_obj, allele, color_mode)


"""
Generates a palette.

Depending on the specified color mode, the new palette is either loaded from a preset, or generated with completely
random colors, or derived from the current palette.
"""
func _palette(color_mode: int = THEME_COLORS) -> Dictionary:
	var result := {}
	if color_mode == THEME_COLORS:
		# load a preset palette
		result = DnaUtils.random_creature_palette()
	elif color_mode == RANDOM_COLORS:
		# generate a palette with random colors
		var body := Color(randf(), randf(), randf())
		var cloth := Color(randf(), randf(), randf())
		var belly := Color(randf(), randf(), randf())
		var eye0 := Color(randf(), randf(), randf())
		var eye1 := Color(randf(), randf(), randf())
		var horn := Color(randf(), randf(), randf())
		
		# blend the belly color with the body color
		belly = lerp(belly, body, rand_range(0.0, 1.0))
		if randf() > 0.5:
			# light belly
			belly.s -= _rng.randfn(0.3, 0.15)
			belly.v += _rng.randfn(0.3, 0.15)
		else:
			# similar-colored belly
			belly.s += _rng.randfn(0.0, 0.2)
			belly.v += _rng.randfn(0.0, 0.2)
		
		# secondary eye color is a lighter variation of the regular color
		eye1 = _random_highlight_color(eye0)
		
		# desaturate the horns
		horn.s = pow(horn.s, 8)
		
		result["body_rgb"] = body.to_html(false)
		result["belly_rgb"] = belly.to_html(false)
		result["cloth_rgb"] = cloth.to_html(false)
		result["eye_rgb"] = "%s %s" % [eye0.to_html(false), eye1.to_html(false)]
		result["horn_rgb"] = horn.to_html(false)
		result["line_rgb"] = center_creature.dna["line_rgb"]
	elif color_mode == SIMILAR_COLORS:
		# derive a palette from the creature's current palette
		result["line_rgb"] = center_creature.dna["line_rgb"]
		for allele in ["body_rgb", "belly_rgb", "cloth_rgb", "horn_rgb"]:
			var body := Color(center_creature.dna[allele])
			result[allele] = _random_similar_color(body).to_html(false)
		
		var eye0: Color = Color(center_creature.dna["eye_rgb"].split(" ")[0])
		eye0 = _random_similar_color(eye0)
		result["eye_rgb"] = "%s %s" % [eye0.to_html(false), _random_highlight_color(eye0).to_html(false)]
	return result


"""
Regenerates a creature to be a variation of the center creature.

Only one aspect of the creature is changed. We select a value which is different from the creature's current value, and
which hasn't been selected recently.
"""
func _tweak_creature(creature: Creature, allele: String, color_mode: int) -> void:
	var palette: Dictionary = _palette(color_mode)
	if allele == "line_rgb":
		# cycle through line colors predictably
		palette["line_rgb"] = Color(DnaUtils.LINE_COLORS[_next_line_color_index]).to_html(false)
		_next_line_color_index = (_next_line_color_index + 1) % DnaUtils.LINE_COLORS.size()
	elif color_mode == RANDOM_COLORS:
		# leave the line color alone
		palette["line_rgb"] = center_creature.dna["line_rgb"]
	
	# copy the center creature's dna, name, weight
	creature.creature_def = center_creature.creature_def
	var dna := {}
	for allele in ["line_rgb", "body_rgb", "belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb",
		"cheek", "eye", "ear", "horn", "mouth", "nose", "collar", "belly"]:
		if center_creature.dna.has(allele):
			dna[allele] = center_creature.dna[allele]
	
	match allele:
		"name":
			creature.creature_name = _name_generator.generate_name()
			creature.creature_short_name = NameUtils.sanitize_short_name(creature.creature_name)
		"fatness":
			var new_fatnesses := FATNESSES.duplicate()
			while new_fatnesses.has(creature.get_visual_fatness()):
				new_fatnesses.erase(creature.get_visual_fatness())
			var new_fatness: float = Utils.rand_value(new_fatnesses)
			creature.set_fatness(new_fatness)
			creature.set_visual_fatness(new_fatness)
		"body_rgb":
			dna["line_rgb"] = palette["line_rgb"]
			dna["body_rgb"] = palette["body_rgb"]
		"all_rgb":
			dna["line_rgb"] = palette["line_rgb"]
			dna["body_rgb"] = palette["body_rgb"]
			dna["belly_rgb"] = palette["belly_rgb"]
			dna["cloth_rgb"] = palette["cloth_rgb"]
			dna["eye_rgb"] = palette["eye_rgb"]
			dna["horn_rgb"] = palette["horn_rgb"]
		"belly_rgb", "cloth_rgb", "eye_rgb", "horn_rgb", "line_rgb":
			dna[allele] = palette[allele]
		_:
			var new_alleles := DnaUtils.unique_allele_values(allele)
			var unpicked_alleles := new_alleles.duplicate()
			unpicked_alleles.erase(dna[allele])
			for recent_allele in _recent_tweaked_allele_values[allele]:
				unpicked_alleles.erase(recent_allele)
			if not unpicked_alleles:
				unpicked_alleles = new_alleles
				unpicked_alleles.erase(dna[allele])
				_recent_tweaked_allele_values[allele].clear()
			if unpicked_alleles:
				dna[allele] = Utils.rand_value(unpicked_alleles)
				_recent_tweaked_allele_values[allele].append(dna[allele])
	
	creature.dna = dna
	creature.chat_theme_def = _chat_theme_def(dna)


"""
Randomly calculates a set of alleles to mutate.

These alleles are randomly selected based on the player's locked/unlocked selections.

Unlocked alleles are always returned. Locked alleles are never returned. Alleles which are neither locked nor unlocked
are randomly returned depending on the 'mutagen' value; a higher mutagen value results in more alleles being returned.
"""
func _alleles_to_mutate() -> Array:
	var result := []
	result += _mutate_ui.get_unlocked_alleles()
	var flexible_alleles: Array = _mutate_ui.get_flexible_alleles()
	
	# if all color alleles are flexible/unlocked, we replace them with an 'all_rgb' allele 50% of the time to
	# encourage themed colors
	var some_rgb_locked := false
	for allele_obj in _mutate_ui.get_locked_alleles():
		var allele: String = allele_obj
		if allele.ends_with("_rgb"):
			some_rgb_locked = true
	if not some_rgb_locked and randf() > 0.5:
		var new_flexible_alleles := ["all_rgb"]
		for allele in flexible_alleles:
			if not allele.ends_with("_rgb"):
				new_flexible_alleles.append(allele)
		flexible_alleles = new_flexible_alleles
	
	# determine how many alleles to mutate based on the 'mutagen' value
	var extra_mutations_float: float = lerp(0, flexible_alleles.size(), _mutate_ui.mutagen)
	var extra_mutations := int(extra_mutations_float)
	if randf() < (extra_mutations_float - extra_mutations):
		# numbers like 2.35 are rounded down 35% of the time, and rounded up 65% of the time
		extra_mutations += 1
	
	if not result and extra_mutations == 0:
		# ensure there's at least one mutation, even if no alleles are unlocked and mutagen is set to zero
		extra_mutations += 1
	
	if extra_mutations:
		flexible_alleles.shuffle()
		result += flexible_alleles.slice(0, extra_mutations - 1)
	
	# if the result has 'all_rgb', remove other '_rgb' mutations
	if result.has("all_rgb"):
		var new_result := ["all_rgb"]
		for allele in result:
			if not allele.ends_with("_rgb"):
				new_result.append(allele)
		result = new_result
	
	return result


"""
Randomly generates a color with a similar HSV to the specified color.
"""
func _random_similar_color(color: Color) -> Color:
	var new_color := color
	new_color.h = new_color.h + _rng.randfn(0.0, 0.06)
	new_color.s = new_color.s + _rng.randfn(0.0, 0.06)
	new_color.v = new_color.v + _rng.randfn(0.0, 0.06)
	return new_color


"""
Randomly generates a brighter version of the specified color.
"""
func _random_highlight_color(color: Color) -> Color:
	var new_color := color
	new_color.h = color.h + _rng.randfn(+0.00, 0.03)
	new_color.s = color.s + _rng.randfn(-0.50, 0.20)
	new_color.v = color.v + _rng.randfn(+0.40, 0.10)
	return new_color


func _on_Breadcrumb_trail_popped(_prev_path: String) -> void:
	if not Breadcrumb.trail:
		get_tree().change_scene("res://src/main/ui/menu/LoadingScreen.tscn")


func _on_Quit_pressed() -> void:
	Breadcrumb.pop_trail()


func _on_Reroll_pressed() -> void:
	mutate_all_creatures()
	_mutate_ui.mutagen *= 0.84


"""
Swap the clicked creature with the center creature.
"""
func _on_CreatureSelector_creature_clicked(creature: Creature) -> void:
	if creature == center_creature:
		return
	
	var creature_def_tmp: CreatureDef = center_creature.creature_def
	center_creature.creature_def = creature.creature_def
	creature.creature_def = creature_def_tmp
	emit_signal("center_creature_changed")
