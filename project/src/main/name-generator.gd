class_name NameGenerator
## Markov chain name generation algorithm.
##
## Accepts as input a list of words like 'banana' and 'anabelle', and mixes them into new words like 'banabelle'.

var markov_model := MarkovModel.new()
var min_length: int setget set_min_length
var max_length: int setget set_max_length
var order: float setget set_order

## Key: Word from the source material
## Value: true
var _seed_words := {}

## cached list of generated names; we generate many names at once at cache them
var _generated_names := []

## resource paths containing input names (one word per line)
var _seed_paths := []

## seed names loaded from the resource files
var _seed_word_lists := []

## Configures the name generator with 'American given names' and 'animals'.
##
## This generates names like 'Boala', 'Badgehog' and 'Coyce'.
func load_american_animals() -> void:
	add_seed_resource("res://assets/main/editor/creature/animals.txt")
	add_seed_resource("res://assets/main/editor/creature/american-male-given-names.txt")
	add_seed_resource("res://assets/main/editor/creature/american-female-given-names.txt")
	set_order(2.7)
	set_min_length(4)
	set_max_length(11)


func reset() -> void:
	markov_model.clear()
	_generated_names.clear()
	_seed_paths.clear()
	_seed_word_lists.clear()


func set_min_length(new_min_length: int) -> void:
	markov_model.min_length = new_min_length


func set_max_length(new_max_length: int) -> void:
	markov_model.max_length = new_max_length


func set_order(new_order: float) -> void:
	markov_model.order = new_order


## Add a resource file to load words from.
func add_seed_resource(path: String) -> void:
	var words: Array = FileUtils.get_file_as_text(path).split("\n")
	_seed_word_lists.append(words)
	for word in words:
		_seed_words[word] = true
	_seed_paths.append(path)


## Generates a name based on the seed resources.
##
## This method regenerates the markov chain connection data and generates several names all at once. It then returns
## those cached names each time it's called until the cache is exhausted.
func generate_name() -> String:
	if not _generated_names:
		# repopulate the list of generated words
		var words := _mix_seed_lists()
		_refresh_markov_model(words)
		_refresh_generated_names()
	
	if not _generated_names:
		# couldn't repopulate the list of generated names
		push_warning("Couldn't generate any names.")
		for _i in range(10):
			_generated_names.push_front(StringUtils.capitalize_words(Utils.rand_value(_seed_words.keys())))
	
	return _generated_names.pop_front()


## Mixes a few seed word lists into a single list of words.
##
## This takes the same amount of words from each list, so a list of 100 words won't get drowned out by a list of 500
## words.
func _mix_seed_lists() -> Array:
	var words := []
	var word_count: int = _seed_word_lists[0].size()
	for word_list in _seed_word_lists:
		word_count = min(word_count, word_list.size())
	for word_list in _seed_word_lists:
		var new_words := []
		for word in word_list:
			new_words.append(word)
		new_words.shuffle()
		words += new_words.slice(0, word_count - 1)
	return words


func _refresh_markov_model(words: Array) -> void:
	markov_model.clear()
	for word in words:
		markov_model.add_word(word)


func _refresh_generated_names() -> void:
	for _i in range(100):
		var name := markov_model.generate_word()
		if name and not _seed_words.has(name):
			_generated_names.append(StringUtils.capitalize_words(name))
