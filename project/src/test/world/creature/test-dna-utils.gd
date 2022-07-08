extends "res://addons/gut/test.gd"

func test_allele_weights_hair_and_ant_mouth() -> void:
	var dna := {"mouth": "1"}
	var allele_weights := DnaUtils.allele_weights(dna, "hair")
	
	# 'fuzzy haircut' is selected less frequently with ant mouth
	assert_almost_eq(allele_weights["0"], 5.0, 0.01)
	assert_almost_eq(allele_weights["1"], 0.333333, 0.01)


func test_allele_weights_hair_and_imp_mouth() -> void:
	var dna := {"mouth": "3"}
	var allele_weights := DnaUtils.allele_weights(dna, "hair")
	
	# 'fuzzy haircut' is selected a regular amount with imp mouth
	assert_almost_eq(allele_weights["0"], 5.0, 0.01)
	assert_almost_eq(allele_weights["1"], 1.0, 0.01)


func test_allele_weights_horn() -> void:
	var dna := {}
	var allele_weights := DnaUtils.allele_weights(dna, "horn")
	
	# 'no horn' is selected more frequently than other alleles
	assert_almost_eq(allele_weights["0"], 3.0, 0.01)
	assert_almost_eq(allele_weights["1"], 1.0, 0.01)


func test_dna_matches_type() -> void:
	# beaks do not match the 'squirrel' type
	assert_eq(DnaUtils.dna_matches_type({"mouth": "1"}, Creatures.Type.SQUIRREL), true)
	assert_eq(DnaUtils.dna_matches_type({"mouth": "4"}, Creatures.Type.SQUIRREL), false)
	
	# everything should match the 'default' type
	assert_eq(DnaUtils.dna_matches_type({"mouth": "1"}, Creatures.Type.DEFAULT), true)
	assert_eq(DnaUtils.dna_matches_type({"mouth": "4"}, Creatures.Type.DEFAULT), true)
