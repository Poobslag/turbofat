extends "res://addons/gut/test.gd"

var _model: MarkovModel

func before_each() -> void:
	_model = MarkovModel.new()
	_model.order = 3


func test_add_word_order_2() -> void:
	_model.order = 2
	_model.add_word("banana")
	assert_eq(_model.frequency.get("b"), 1)
	assert_eq(_model.frequency.get("ba"), 1)
	assert_eq(_model.frequency.get("ban"), 1)
	assert_eq(_model.frequency.get("ana"), 2)
	assert_eq(_model.frequency.get("na\n"), 1)
	
	assert_eq(_model.connections.get("").get("b"), true)
	assert_eq(_model.connections.get("b").get("ba"), true)
	assert_eq(_model.connections.get("ba").get("ban"), true)
	assert_eq(_model.connections.get("an").get("ana"), true)
	assert_eq(_model.connections.get("na").get("nan"), true)
	assert_eq(_model.connections.get("na").get("na\n"), true)


func test_add_word_order_4() -> void:
	_model.order = 4
	_model.add_word("banana")
	assert_eq(_model.frequency.get("b"), 1)
	assert_eq(_model.frequency.get("ba"), 1)
	assert_eq(_model.frequency.get("ban"), 1)
	assert_eq(_model.frequency.get("bana"), 1)
	assert_eq(_model.frequency.get("banan"), 1)
	assert_eq(_model.frequency.get("anana"), 1)
	assert_eq(_model.frequency.get("nana\n"), 1)
	
	assert_eq(_model.connections.get("").get("b"), true)
	assert_eq(_model.connections.get("b").get("ba"), true)
	assert_eq(_model.connections.get("ba").get("ban"), true)
	assert_eq(_model.connections.get("ban").get("bana"), true)
	assert_eq(_model.connections.get("bana").get("banan"), true)
	assert_eq(_model.connections.get("anan").get("anana"), true)
	assert_eq(_model.connections.get("nana").get("nana\n"), true)


func test_add_word_length_2() -> void:
	_model.add_word("ba")
	assert_eq(_model.frequency.get("b"), 1)
	assert_eq(_model.frequency.get("ba"), 1)
	assert_eq(_model.frequency.get("a\n"), 1)


func test_add_word_length_1() -> void:
	_model.add_word("b")
	assert_eq(_model.frequency.size(), 0)


func test_add_word_length_0() -> void:
	_model.add_word("")
	assert_eq(_model.frequency.size(), 0)
