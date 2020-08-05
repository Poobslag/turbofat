extends Node
"""
A graphical creature editor which lets players design their own creatures.
"""

# creature characteristics which the player can edit
const EDITABLE_ALLELES := [
	"name",
	"eye", "eye_rgb",
	"nose",
	"mouth",
	"ear",
	"horn", "horn_rgb",
	"cheek", "body_rgb",
	"belly", "belly_rgb",
	"fatness",
]

# generated using 'American Forenames + Animals' from https://www.samcodes.co.uk/project/markov-namegen/
const NAMES := [
	"Agnessica", "Alandredes", "Alion", "Allie", "Alvador", "Amantis", "Ambernetta", "Ambert",
	"Amela", "Anaco", "Anathy", "Annah", "Anthia", "Antpanda", "Aphie", "Aphinchilis",
	"Arnandra", "Artha", "Arthantlion", "Badgehog", "Barah", "Basilip", "Basilvia", "Bassa",
	"Bearthur", "Beathy", "Beaven", "Beetah", "Bernarwigh", "Bernesse", "Bernet", "Berta",
	"Beula", "Blandra", "Blanie", "Bluewhal", "Brancy", "Brene", "Bridge", "Byronald",
	"Calvadorey", "Camelody", "Camie", "Candee", "Cardon", "Carolive", "Carone", "Cassand",
	"Chael", "Chary", "Chelly", "Chenriquel", "Chickerry", "Childred", "Chriscil", "Christi",
	"Cindsloth", "Clare", "Claudith", "Claure", "Condo", "Constancis", "Corpion", "Corpoise",
	"Crabbit", "Danacle", "Danie", "Darrence", "Darry", "Davieve", "Davievelynx", "Debrad",
	"Deerkatha", "Derick", "Diann", "Diannah", "Dianthew", "Donate", "Doriettany", "Dwiniferyl",
	"Earlotte", "Eduan", "Edwayne", "Edwightin", "Eleph", "Elephia", "Eliam", "Elvia",
	"Enrie", "Ermanatha", "Ernessie", "Estepheroy", "Estina", "Fernandra", "Ferryl", "Franda",
	"Frane", "Franha", "Franton", "Fredith", "Fruitorie", "Gabridget", "Gabrin", "Gabrita",
	"Galla", "Gazel", "Geckeremy", "Gecky", "Gibbonobo", "Girafael", "Giranca", "Glerfish",
	"Glorent", "Glorey", "Gregordtail", "Grine", "Groundsay", "Guana", "Gwendy", "Hammy",
	"Hannie", "Harlesnake", "Haronice", "Harooke", "Hectorianna", "Hectorto", "Heryl", "Howardwolf",
	"Howarrel", "Hummie", "Humpback", "Ianne", "Iantipeder", "Irebecca", "Irmantheodo", "Jackadelly",
	"Jackwhale", "Jacque", "Jaguadale", "Jeffe", "Jellian", "Jenne", "Jeresa", "Jeroy",
	"Joannow", "Joris", "Josemarlie", "Josemarmen", "Joset", "Juanest", "Judian", "Kariel",
	"Katheryl", "Keredpandra", "Kimbert", "Kimbertoise", "Koalam", "Krilla", "Kristalicia", "Kristian",
	"Kristiana", "Kristoad", "Krystace", "Krystalicia", "Kyler", "Ladys", "Laude", "Laudre",
	"Lawrena", "Leightina", "Lemma", "Lilligator", "Limpeter", "Locus", "Loria", "Luise",
	"Mabette", "Mamma", "Mandra", "Margaron", "Marianthia", "Maril", "Marjord", "Marjorge",
	"Marmonkey", "Marshantlio", "Marthan", "Marvey", "Mathryn", "Mattheremy", "Maurie", "Meadow",
	"Melance", "Melia", "Melice", "Merheatrica", "Miche", "Michenriel", "Micholly", "Miguelynn",
	"Mistie", "Mitchel", "Mitcrab", "Monaldine", "Monda", "Mooset", "Natalibutte", "Natashan",
	"Natashanice", "Nellip", "Nichollie", "Octori", "Panthony", "Parri", "Parrow", "Parry",
	"Parta", "Patrine", "Patshannie", "Patthew", "Pattie", "Paulah", "Paulianna", "Peline",
	"Pengutany", "Phylliam", "Polanacle", "Praig", "Rafferyl", "Ramonio", "Randice", "Rankline",
	"Rayingmana", "Rebecket", "Rences", "Reptileen", "Rhond", "Rickie", "Robertrine", "Rocod",
	"Ronita", "Rosephilda", "Roxandice", "Salma", "Sandice", "Seasey", "Sergil", "Sharles",
	"Sharyann", "Shelma", "Shirlenne", "Silkwormot", "Skingel", "Snipermin", "Squirren", "Stara",
	"Suzannie", "Swalla", "Swallie", "Swanda", "Tamie", "Tamily", "Tammeremy", "Tashany",
	"Terpion", "Theryl", "Tiffalo", "Tigeorge", "Traccoon", "Tracharona", "Trine", "Tureen",
	"Vampirank", "Verfish", "Victori", "Violark", "Violeticia", "Virgian", "Vivia", "Voleticia",
	"Vultureen", "Walrush", "Walterranda", "Watee", "Weslie", "White", "Wilda", "Wildrew",
	"Woodpeckent", "Yvonnie", "Zachark"
]

# weighted distribution of 'fatnesses' in the range [1.0, 10.0]. most creatures are skinny.
const FATNESSES := [
	1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
	1.1, 1.2, 1.3, 1.5,
	1.8, 2.3,
]

# the creature the player is editing
onready var _center_creature := $World/Creatures/CenterCreature

# alternative creatures the player can choose
onready var _outer_creatures := [
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
	Breadcrumb.connect("trail_popped", self, "_on_Breadcrumb_trail_popped")

	_center_creature.set_meta("main_creature", true)
	$World/Creatures/NeCreature.set_meta("nametag_right", true)
	$World/Creatures/ECreature.set_meta("nametag_right", true)
	$World/Creatures/SeCreature.set_meta("nametag_right", true)
	
	_initialize_creature(_center_creature)
	for creature in _outer_creatures:
		_initialize_creature(creature)


"""
Returns a chat theme definition for a generated creature.
"""
func _random_chat_theme_def() -> Dictionary:
	return {}


"""
Regenerates all of the outer creatures to be variations of the center creature.
"""
func _mutate_all_creatures() -> void:
	for creature_obj in _outer_creatures:
		_mutate_creature(creature_obj)


"""
Regenerates a creature to be a variation of the center creature.

The amount of variance depends on the 'mutagen' level. The mutated alleles are randomly chosen depend on the player's
locked/unlocked alleles.
"""
func _mutate_creature(creature: Creature) -> void:
	var new_palette: Dictionary = Utils.rand_value(DnaUtils.CREATURE_PALETTES)
	
	# copy the center creature's definition into the target creature
	var dna := {}
	for dna_property in [
			"line_rgb", "body_rgb", "belly_rgb", "eye_rgb", "horn_rgb",
			"cheek", "eye", "ear", "horn", "mouth", "nose", "belly"
	]:
		dna[dna_property] = _center_creature.dna[dna_property]
	creature.set_fatness(_center_creature.get_fatness())
	creature.set_visual_fatness(_center_creature.get_visual_fatness())
	creature.set_chat_theme_def(_center_creature.chat_theme_def)
	creature.creature_name = _center_creature.creature_name
	
	# mutate the appropriate alleles
	for allele in _alleles_to_mutate():
		match allele:
			"name":
				creature.creature_name = Utils.rand_value(NAMES)
			"fatness":
				var new_fatnesses := FATNESSES.duplicate()
				while new_fatnesses.has(creature.get_visual_fatness()):
					new_fatnesses.erase(creature.get_visual_fatness())
				var new_fatness: float = Utils.rand_value(new_fatnesses)
				creature.set_fatness(new_fatness)
				creature.set_visual_fatness(new_fatness)
			"body_rgb":
				dna["body_rgb"] = new_palette["body_rgb"]
				dna["line_rgb"] = new_palette["line_rgb"]
			"all_rgb":
				dna["body_rgb"] = new_palette["body_rgb"]
				dna["line_rgb"] = new_palette["line_rgb"]
				dna["belly_rgb"] = new_palette["belly_rgb"]
				dna["eye_rgb"] = new_palette["eye_rgb"]
				dna["horn_rgb"] = new_palette["horn_rgb"]
			"belly_rgb", "eye_rgb", "horn_rgb":
				dna[allele] = new_palette[allele]
			_:
				var new_alleles := DnaUtils.allele_values(dna, allele)
				while new_alleles.has(dna[allele]):
					new_alleles.erase(dna[allele])
				dna[allele] = Utils.rand_value(new_alleles)
	
	creature.dna = dna


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
Initializes a new creature with random characteristics.
"""
func _initialize_creature(_creature: Creature) -> void:
	_creature.dna = CreatureLoader.random_def()
	var fatness: float = Utils.rand_value(FATNESSES)
	_creature.set_fatness(fatness)
	_creature.set_visual_fatness(fatness)
	_creature.set_chat_theme_def(_random_chat_theme_def())
	_creature.creature_name = Utils.rand_value(NAMES)


func _on_Breadcrumb_trail_popped(_prev_path: String) -> void:
	if not Breadcrumb.trail:
		get_tree().change_scene("res://src/main/ui/menu/LoadingScreen.tscn")


func _on_Quit_pressed() -> void:
	Breadcrumb.pop_trail()


func _on_Reroll_pressed() -> void:
	_mutate_all_creatures()
	_mutate_ui.mutagen *= 0.84


"""
Swap the clicked creature with the center creature.
"""
func _on_CreatureSelector_creature_clicked(creature: Creature) -> void:
	if creature == _center_creature:
		return
	
	var dna_tmp: Dictionary = _center_creature.dna
	var fatness_tmp: float = _center_creature.get_fatness()
	var chat_theme_def_tmp: Dictionary = _center_creature.chat_theme_def
	var creature_name_tmp: String = _center_creature.creature_name
	
	_center_creature.dna = creature.dna
	_center_creature.set_fatness(creature.get_fatness())
	_center_creature.set_visual_fatness(creature.get_fatness())
	_center_creature.set_chat_theme_def(creature.chat_theme_def)
	_center_creature.creature_name = creature.creature_name

	creature.dna = dna_tmp
	creature.set_fatness(fatness_tmp)
	creature.set_visual_fatness(fatness_tmp)
	creature.set_chat_theme_def(chat_theme_def_tmp)
	creature.creature_name = creature_name_tmp
