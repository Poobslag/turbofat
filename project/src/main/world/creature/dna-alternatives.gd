class_name DnaAlternatives
"""
Provides alternatives for alleles which conflict.

Certain glasses might overlap a creature's nose in a weird way. We have a 'ban list' elsewhere for combos which don't
work outright, but this class provides alternatives so that we can give the glasses a slightly different design, or
remove parts of the eyeglass frames or things like that.
"""

"""
key: allele value key like 'accessory-2', for an allele which can vary
value: array of three items
	value[0]: conflicting allele key, such as 'nose'
	value[1]: array of conflicting allele values
	value[2]: alternative allele value to replace the allele with
"""
var _alternatives: Dictionary

func _init() -> void:
	# for some noses, we switch up the glasses
	_add_alternative("nose", ["3"], "accessory", "1", "1a")
	_add_alternative("nose", ["3"], "accessory", "2", "2a")
	
	# for some body parts, we remove the upper part of headphones
	_add_alternative("ear", ["5"], "accessory", "3", "3a")
	
	# for a specific horn/hair combination, we slightly change the hairstyle
	_add_alternative("ear", ["10"], "hair", "1", "1a")


"""
Returns an alternative for the specified allele value if a conflict is detected.

Returns an empty string if there is no conflict.

Parameters:
	'dna': The dictionary of key/value pairs defining a set of textures to load.
	
	'key': Allele key which can vary, such as 'accessory'
	
	'value': Allele value which can vary, such as '2' which might sometimes switch to '2a'
"""
func alternative(dna: Dictionary, key: String, value: String) -> String:
	var result := ""
	var allele_value_key := _allele_value_key(key, value)
	if _alternatives.has(allele_value_key):
		for alternative in _alternatives.get(allele_value_key):
			if dna.get(alternative[0]) in alternative[1]:
				result = alternative[2]
				break
	return result


"""
Adds an alternative for an allele value which can vary if a conflict is detected.

Parameters:
	'conflicting_allele': Conflicting allele key, such as 'nose'
	
	'conflicting_values': Array of conflicting allele values, such as '2'
	
	'allele': Allele key which can vary if s conflict is detected, such as 'accessory'
	
	'allele_value': Allele value which can vary if a conflict is detected, such as '3'
	
	'alternative_value': The allele value it should switch to if a conflict is detected
"""
func _add_alternative(conflicting_allele: String, conflicting_values: Array,
		allele: String, allele_value: String, alternative_value: String) -> void:
	var allele_value_key := _allele_value_key(allele, allele_value)
	if not _alternatives.has(allele_value_key):
		_alternatives[allele_value_key] = []
	_alternatives[allele_value_key].append([conflicting_allele, conflicting_values, alternative_value])


func _allele_value_key(allele: String, value: String) -> String:
	return "%s-%s" % [allele, value]
