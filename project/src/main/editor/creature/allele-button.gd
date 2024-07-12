class_name AlleleButton
extends CandyButtonC3
## Button which selects one or more alleles in the creature editor.
##
## An allele button usually corresponds to a single allele such as "poofy hair" or "sunglasses", but can also
## correspond to a combination of alleles such as "squirrel body with a colored belly"

## key: (String) a single allele, or combination of alleles separated by a space
## value: (Resource) icon for the specified allele combo
const ALLELE_ICONS_BY_COMBO := {
	"eye_0": preload("res://assets/main/editor/creature/icon-eye-0.png"),
	"eye_1": preload("res://assets/main/editor/creature/icon-eye-1.png"),
	"eye_2": preload("res://assets/main/editor/creature/icon-eye-2.png"),
	"eye_3": preload("res://assets/main/editor/creature/icon-eye-3.png"),
	"eye_4": preload("res://assets/main/editor/creature/icon-eye-4.png"),
	"eye_5": preload("res://assets/main/editor/creature/icon-eye-5.png"),
	"eye_6": preload("res://assets/main/editor/creature/icon-eye-6.png"),
	"eye_7": preload("res://assets/main/editor/creature/icon-eye-7.png"),
	"eye_8": preload("res://assets/main/editor/creature/icon-eye-8.png"),
	
	"head_1": preload("res://assets/main/editor/creature/icon-head-1.png"),
	"head_2": preload("res://assets/main/editor/creature/icon-head-2.png"),
	"head_3": preload("res://assets/main/editor/creature/icon-head-3.png"),
	"head_4": preload("res://assets/main/editor/creature/icon-head-4.png"),
	"head_5": preload("res://assets/main/editor/creature/icon-head-5.png"),
	
	"nose_0": preload("res://assets/main/editor/creature/icon-nose-0.png"),
	"nose_1": preload("res://assets/main/editor/creature/icon-nose-1.png"),
	"nose_2": preload("res://assets/main/editor/creature/icon-nose-2.png"),
	"nose_3": preload("res://assets/main/editor/creature/icon-nose-3.png"),
	"nose_4": preload("res://assets/main/editor/creature/icon-nose-4.png"),
	
	"mouth_0": preload("res://assets/main/editor/creature/icon-mouth-0.png"),
	"mouth_1": preload("res://assets/main/editor/creature/icon-mouth-1.png"),
	"mouth_2": preload("res://assets/main/editor/creature/icon-mouth-2.png"),
	"mouth_3": preload("res://assets/main/editor/creature/icon-mouth-3.png"),
	"mouth_4": preload("res://assets/main/editor/creature/icon-mouth-4.png"),
	"mouth_5": preload("res://assets/main/editor/creature/icon-mouth-5.png"),
	"mouth_6": preload("res://assets/main/editor/creature/icon-mouth-6.png"),
	"mouth_7": preload("res://assets/main/editor/creature/icon-mouth-7.png"),
	
	"cheek_0": preload("res://assets/main/editor/creature/icon-cheek-0.png"),
	"cheek_1": preload("res://assets/main/editor/creature/icon-cheek-1.png"),
	"cheek_2": preload("res://assets/main/editor/creature/icon-cheek-2.png"),
	"cheek_3": preload("res://assets/main/editor/creature/icon-cheek-3.png"),
	"cheek_4": preload("res://assets/main/editor/creature/icon-cheek-4.png"),

	"accessory_0": preload("res://assets/main/editor/creature/icon-accessory-0.png"),
	"accessory_1": preload("res://assets/main/editor/creature/icon-accessory-1.png"),
	"accessory_2": preload("res://assets/main/editor/creature/icon-accessory-2.png"),
	"accessory_3": preload("res://assets/main/editor/creature/icon-accessory-3.png"),
	"accessory_4": preload("res://assets/main/editor/creature/icon-accessory-4.png"),
	"accessory_5": preload("res://assets/main/editor/creature/icon-accessory-5.png"),

	"bellybutton_0": preload("res://assets/main/editor/creature/icon-bellybutton-0.png"),
	"bellybutton_1": preload("res://assets/main/editor/creature/icon-bellybutton-1.png"),
	"bellybutton_2": preload("res://assets/main/editor/creature/icon-bellybutton-2.png"),
	"bellybutton_3": preload("res://assets/main/editor/creature/icon-bellybutton-3.png"),
	"bellybutton_4": preload("res://assets/main/editor/creature/icon-bellybutton-4.png"),

	"body_1 belly_0": preload("res://assets/main/editor/creature/icon-body-1-belly-0.png"),
	"body_1 belly_1": preload("res://assets/main/editor/creature/icon-body-1-belly-1.png"),
	"body_1 belly_2": preload("res://assets/main/editor/creature/icon-body-1-belly-2.png"),
	"body_2 belly_0": preload("res://assets/main/editor/creature/icon-body-2-belly-0.png"),
	"body_2 belly_1": preload("res://assets/main/editor/creature/icon-body-2-belly-1.png"),
	"body_2 belly_2": preload("res://assets/main/editor/creature/icon-body-2-belly-2.png"),

	"ear_0": preload("res://assets/main/editor/creature/icon-ear-0.png"),
	"ear_1": preload("res://assets/main/editor/creature/icon-ear-1.png"),
	"ear_2": preload("res://assets/main/editor/creature/icon-ear-2.png"),
	"ear_3": preload("res://assets/main/editor/creature/icon-ear-3.png"),
	"ear_4": preload("res://assets/main/editor/creature/icon-ear-4.png"),
	"ear_5": preload("res://assets/main/editor/creature/icon-ear-5.png"),
	"ear_6": preload("res://assets/main/editor/creature/icon-ear-6.png"),
	"ear_7": preload("res://assets/main/editor/creature/icon-ear-7.png"),
	"ear_8": preload("res://assets/main/editor/creature/icon-ear-8.png"),
	"ear_9": preload("res://assets/main/editor/creature/icon-ear-9.png"),
	"ear_10": preload("res://assets/main/editor/creature/icon-ear-10.png"),
	"ear_11": preload("res://assets/main/editor/creature/icon-ear-11.png"),
	"ear_12": preload("res://assets/main/editor/creature/icon-ear-12.png"),
	"ear_13": preload("res://assets/main/editor/creature/icon-ear-13.png"),
	"ear_14": preload("res://assets/main/editor/creature/icon-ear-14.png"),
	"ear_15": preload("res://assets/main/editor/creature/icon-ear-15.png"),

	"horn_0": preload("res://assets/main/editor/creature/icon-forehead-0.png"),
	"horn_1": preload("res://assets/main/editor/creature/icon-forehead-1.png"),
	"horn_2": preload("res://assets/main/editor/creature/icon-forehead-2.png"),

	"hair_0": preload("res://assets/main/editor/creature/icon-hair-0.png"),
	"hair_1": preload("res://assets/main/editor/creature/icon-hair-1.png"),
	"hair_2": preload("res://assets/main/editor/creature/icon-hair-2.png"),

	"collar_0": preload("res://assets/main/editor/creature/icon-neck-0.png"),
	"collar_1": preload("res://assets/main/editor/creature/icon-neck-1.png"),
	"collar_2": preload("res://assets/main/editor/creature/icon-neck-2.png"),
	"collar_3": preload("res://assets/main/editor/creature/icon-neck-3.png"),
	"collar_4": preload("res://assets/main/editor/creature/icon-neck-4.png"),
	"collar_5": preload("res://assets/main/editor/creature/icon-neck-5.png"),

	"tail_0": preload("res://assets/main/editor/creature/icon-tail-0.png"),
	"tail_1": preload("res://assets/main/editor/creature/icon-tail-1.png"),
	"tail_2": preload("res://assets/main/editor/creature/icon-tail-2.png"),
	"tail_3": preload("res://assets/main/editor/creature/icon-tail-3.png"),
	"tail_4": preload("res://assets/main/editor/creature/icon-tail-4.png"),
	"tail_5": preload("res://assets/main/editor/creature/icon-tail-5.png"),
	"tail_6": preload("res://assets/main/editor/creature/icon-tail-6.png"),
	"tail_7": preload("res://assets/main/editor/creature/icon-tail-7.png"),
}

var allele_combo: String setget set_allele_combo

func set_allele_combo(new_allele_combo: String) -> void:
	allele_combo = new_allele_combo
	
	if ALLELE_ICONS_BY_COMBO.has(allele_combo):
		set_icon(ALLELE_ICONS_BY_COMBO[allele_combo])
	else:
		push_warning("allele icon not found for combo: '%s'" % [allele_combo])
		set_icon(null)
