class_name MarkovModel
## Model for markov chains.
##
## Maintains a list of letter sequences and letters which can follow them.

var min_length := 3
var max_length := 15

## Smallest cluster of letters which are guaranteed to stay together. A fractional value will randomly alternate
## between the lower and higher values while generating words.
var order := 2.5

## key: (String) Letter cluster, newline-terminated for the word's end
## value: (int) Number of times the cluster appeared in the input data
var frequency := {}

## key: (String) Letter cluster
## value: (Dictionary) Dictionary of continuation clusters
var connections := {}

func clear() -> void:
	frequency.clear()
	connections.clear()


## Adds an input word to use when generating new words.
func add_word(word: String) -> void:
	if word.length() <= 1:
		return
	
	var int_orders := [floor(order)]
	if floor(order) != ceil(order):
		int_orders.append(ceil(order))
	
	for int_order in int_orders:
		for i in range(1, word.length() + int_order + 1):
			var cluster := word.substr(max(i - int_order - 1, 0), min(i, int_order + 1))
			if i > word.length():
				cluster += "\n"
			_add_cluster(cluster)


## Generates a new word similar to the input words.
##
## Generation can fail for a few reasons, such as if the generated word is too long, too short, or if the model is
## flawed. In those cases this method will return an empty string.
##
## Returns:
## 	A generated word, or an empty string if generation fails.
func generate_word() -> String:
	var word := ""
	while true:
		var cluster := word.substr(max(0, word.length() - ceil(order) - 1), ceil(order) + 1)
		cluster = _get_cluster(cluster, word.length() >= min_length)
		if not cluster:
			# failure; couldn't find a continuation
			word = ""
			break
		if cluster.ends_with("\n"):
			# success; end of the word
			break
		word += cluster.substr(cluster.length() - 1, 1)
		if word.length() > max_length:
			# failure; word grew too long
			word = ""
			break
	return word


## Appends a new letter to a letter cluster, returning the result.
##
## Parameters:
## 	'cluster_in': A cluster of letters.
##
## 	'may_end': True if this method is allowed to end the word.
##
## Returns:
## 	The input letter cluster with a new letter added at the end.
func _get_cluster(cluster_in: String, may_end: bool) -> String:
	# calculate the total number of connections
	var total := 0
	var int_order := ceil(order) if randf() <= fmod(order, 1.0) else floor(order)
	var prefix := cluster_in.substr(max(cluster_in.length() - int_order, 0))
	for cluster in connections.get(prefix):
		if cluster.ends_with("\n") and not may_end:
			continue
		total += frequency[cluster]
	
	# pick a connection proportionally with how often it exists in the source data
	var result: String
	if total:
		var index := randi() % total
		for cluster in connections.get(prefix):
			if cluster.ends_with("\n") and not may_end:
				continue
			index -= frequency[cluster]
			if index < 0:
				result = cluster
				break
	return result


## Adds a cluster to the markov model.
func _add_cluster(cluster: String) -> void:
	if not frequency.has(cluster):
		frequency[cluster] = 0
		var prefix := cluster.substr(0, cluster.length() - 1)
		Utils.put_if_absent(connections, prefix, {})
		connections[prefix][cluster] = true
	frequency[cluster] += 1
