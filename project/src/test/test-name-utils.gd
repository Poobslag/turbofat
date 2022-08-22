extends "res://addons/gut/test.gd"

func test_sanitize_name_length() -> void:
	# 31 character limit
	assert_eq(NameUtils.sanitize_name(""), "X")
	assert_eq(NameUtils.sanitize_name("A"), "A")
	assert_eq(NameUtils.sanitize_name(
			"0123456789012345678901234567890123456789"
			+ "0123456789012345678901234567890123456789"),
			"012345678901234567890123456789012345678901234567890123456789012")


func test_sanitize_name_first_and_last_character() -> void:
	# don't start or end the filename with whitespace or punctuation
	assert_eq(NameUtils.sanitize_name(" spoil633"), "spoil633")
	assert_eq(NameUtils.sanitize_name(".spoil633"), "spoil633")
	assert_eq(NameUtils.sanitize_name("-spoil633"), "spoil633")
	assert_eq(NameUtils.sanitize_name("?spoil633"), "spoil633")
	
	assert_eq(NameUtils.sanitize_name("spoil633 "), "spoil633")
	assert_eq(NameUtils.sanitize_name("spoil633."), "spoil633")
	assert_eq(NameUtils.sanitize_name("spoil633-"), "spoil633")
	assert_eq(NameUtils.sanitize_name("spoil633?"), "spoil633")


func test_sanitize_name_invalid_characters() -> void:
	assert_eq(NameUtils.sanitize_name("abc	def"), "abc def")
	assert_eq(NameUtils.sanitize_name("abc#def"), "abc def")
	assert_eq(NameUtils.sanitize_name("abc|def"), "abc def")


func test_sanitize_name_valid_characters() -> void:
	assert_eq(NameUtils.sanitize_name("Spoil633"), "Spoil633")
	assert_eq(NameUtils.sanitize_name("spoil-633"), "spoil-633")
	assert_eq(NameUtils.sanitize_name("húsbóndi"), "húsbóndi")
	assert_eq(NameUtils.sanitize_name("Dr. Smiles"), "Dr. Smiles")
	assert_eq(NameUtils.sanitize_name("abc/def"), "abc/def")


func test_sanitize_short_name() -> void:
	# multiple words; pick the longest word
	assert_eq(NameUtils.sanitize_short_name("Crowd Nosy Distance Embarrass"), "Embarrass")
	assert_eq(NameUtils.sanitize_short_name("Crowd Embarrass Nosy Distance"), "Embarrass")
	
	# one huge word; truncate it near a vowel
	assert_eq(NameUtils.sanitize_short_name("Crowdembarrassnosydistance"), "Crow")
	assert_eq(NameUtils.sanitize_short_name("Crodwembarrassnosydistance"), "Croddy")
	
	# one huge mess of consonants
	assert_eq(NameUtils.sanitize_short_name("Crwdmbrrssnsydstncbrshcvr"), "Crwdm")


func test_short_name_to_id() -> void:
	assert_eq(NameUtils.short_name_to_id(""), "")
	
	# ids should be snake_case and only include underscores, letters, and numbers
	assert_eq(NameUtils.short_name_to_id("SPOIL633"), "spoil633")
	assert_eq(NameUtils.short_name_to_id("spoil-633"), "spoil_633")
	assert_eq(NameUtils.short_name_to_id("húsbóndi"), "husbondi")
	assert_eq(NameUtils.short_name_to_id("Dr. Smiles"), "dr_smiles")
	assert_eq(NameUtils.short_name_to_id("ŽÁLGÕ"), "zalgo")
	assert_eq(NameUtils.short_name_to_id("_-spoil-_-633-?"), "_spoil_633_")
