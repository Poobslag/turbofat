class_name NameUtils
## Utility class for creature names.

const MAX_CREATURE_NAME_LENGTH := 63
const MAX_CREATURE_SHORT_NAME_LENGTH := 15

## Sanitizes a creatures name.
##
## Removes any illegal characters, and any leading/trailing punctuation. Excessively short names are padded, and
## excessively long names are truncated.
static func sanitize_name(name: String) -> String:
	var result := ""
	var utf8 := name.to_lower().to_utf8()
	
	# sanitize characters we don't want in names
	for i in range(name.length()):
		if utf8[i] < 32 or utf8[i] == 127:
			# replace sequences of one or more bad characters with a single hyphen
			if not result.ends_with(" "):
				result += " "
		else:
			result += name[i]
	
	result = result.lstrip(" !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")
	result = result.rstrip(" !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")
	if not result:
		result = "X"
	return result.substr(0, MAX_CREATURE_NAME_LENGTH)


## Sorts an array of strings by length.
##
## In GDScript this requires an internal class because of Godot #30668.
static func sort_by_length(strings: Array) -> void:
	strings.sort_custom(LengthSorter, '_compare_by_length')


class LengthSorter:
	static func _compare_by_length(a: String, b: String) -> bool:
		return a.length() > b.length()


## Sanitizes a creatures short name.
##
## Removes any illegal characters, and any leading/trailing punctuation. Excessively short names are padded, and
## excessively long names are shortened using a complex name shortening algorithm.
static func sanitize_short_name(name: String) -> String:
	var result := sanitize_name(name)
	if result.length() <= MAX_CREATURE_SHORT_NAME_LENGTH:
		return result
	
	if result.find(" ") >= 0:
		# multiple words
		var words: Array = result.split(" ")
		sort_by_length(words)
		result = words[0]
	
	if result.length() > MAX_CREATURE_SHORT_NAME_LENGTH:
		result = shorten_name(result)
	
	return result


## Returns 'true' if the specified letter is a consonant.
##
## Parameters:
## 	'character': An upper-case or lower-case letter.
##
## 	'y': True if 'y' counts as a consonant.
static func is_consonant(character: String, y: bool = false) -> bool:
	var result: bool
	match character.to_lower():
		"a", "e", "i", "o", "u": result = false
		"y": result = y
		_: result = true
	return result


## Returns 'true' if the specified letter is a vowel.
##
## Parameters:
## 	'character': An upper-case or lower-case letter.
##
## 	'y': True if 'y' counts as a vowel.
static func is_vowel(character: String, y: bool = true) -> bool:
	var result: bool
	match character.to_lower():
		"a", "e", "i", "o", "u": result = true
		"y": result = y
		_: result = false
	return result


## Shortens a name using a complex name shortening algorithm.
##
## Instead of shortening names like 'Francoisensellensoile' into awkwardly truncated names like 'Francoi', this
## analyzes vowel/consonant patterns to come up with nicknames like 'Franny'.
##
## Parameters:
## 	'name': A single-word name which should be shortened.
static func shorten_name(name: String) -> String:
	var result := name.substr(0, 5)
	
	# check if the name is alphabetic; if so, we can try to shorten it in a cute way
	var regex := RegEx.new()
	regex.compile("[a-zA-Z]*")
	if not regex.search(name):
		return result
	
	# find the first consonant
	var first_consonant_index := 1
	while first_consonant_index < name.length():
		if is_consonant(name[first_consonant_index]):
			break
		first_consonant_index += 1
	if first_consonant_index > 7:
		return result
	
	# find the first vowel
	var first_vowel_index := first_consonant_index
	while first_vowel_index < name.length():
		if is_vowel(name[first_vowel_index]):
			break
		first_vowel_index += 1
	if first_vowel_index > 8:
		return result
	
	result = name.substr(0, first_vowel_index + 2)
	var end_char := result[result.length() - 1]
	if "bdfglmnprstvz".find(end_char) >= 0:
		result += end_char + "y"
	elif "cjkqwx".find(end_char) >= 0:
		pass
	elif "aeiouy".find(end_char) >= 0:
		var suffixes := "bdgklmnprtx"
		result += suffixes[randi() % suffixes.length()]
	
	return result


## Converts a short name like 'Dr. Smiles' into a creature ID like 'dr_smiles'.
##
## The creature editor converts creature IDs to snake case and strips any diacritical marks or upper ascii. The game
## should work fine even if the IDs have upper ascii and spaces, they'll just be more annoying to type in.
static func short_name_to_id(short_name: String) -> String:
	var transformer := StringTransformer.new(short_name)
	
	# convert to lowercase
	transformer.transformed = transformer.transformed.to_lower()
	
	# convert characters with diacritical marks to undecorated latin letters
	transformer.sub("[àáâãäå]", "a")
	transformer.sub("[æ]", "ae")
	transformer.sub("[ç]", "c")
	transformer.sub("[èéêë]", "e")
	transformer.sub("[ìíîï]", "i")
	transformer.sub("[ðòóôõö]", "o")
	transformer.sub("[ñ]", "n")
	transformer.sub("[š]", "s")
	transformer.sub("[ùúûü]", "u")
	transformer.sub("[ýÿ]", "y")
	transformer.sub("[ž]", "z")
	
	# strip special characters and punctuation
	transformer.sub("[^a-zA-Z0-9]+", "_")
	
	return transformer.transformed
