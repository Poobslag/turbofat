class_name ChatscriptParser
## Parses a chatscript (.chat) file containing a cutscene or lines of chat.
##
## This class is stateful and intended to be used once and thrown away. If it is reused, the previously parsed
## chat tree will be erased.

## Tracks the state for the parser.
##
## The ChatscriptParser has different states based on whether it's parsing chat, characters, locations, or something
## else.
class AbstractState:
	
	var chat_tree: ChatTree
	
	func _init(init_chat_tree: ChatTree) -> void:
		chat_tree = init_chat_tree
	
	
	func line(_line: String) -> String:
		return ""


# -----------------------------------------------------------------------------

## Default parser state for parsing headers and metadata.
##
## Mostly contains logic for transitioning into other states.
class DefaultState extends AbstractState:
	
	var chat_state: AbstractState
	
	func _init(init_chat_tree: ChatTree).(init_chat_tree) -> void:
		pass
	
	
	func line(line: String) -> String:
		var result := ""
		if not line:
			pass
		elif line.begins_with("{") and line.ends_with("}"):
			# json dictionary; set metadata
			var parsed = parse_json(line)
			if typeof(parsed) == TYPE_DICTIONARY:
				chat_tree.meta = parse_json(line)
				if "version" in chat_tree.meta:
					chat_tree.meta.erase("version")
			else:
				chat_tree.warn("Malformed chatscript JSON: %s" % [line])
		elif line.begins_with("[") and line.ends_with("]"):
			# state name; update state
			result = line.trim_prefix("[").trim_suffix("]")
		else:
			# unrecognized text; parse as chat lines and change state
			result = chat_state.line(line)
			result = StringUtils.default_if_empty(result, CHAT)
		return result

# -----------------------------------------------------------------------------

## Parser state for parsing location data (where a conversation takes place).
class LocationState extends AbstractState:
	
	func _init(init_chat_tree: ChatTree).(init_chat_tree) -> void:
			pass
	
	
	## Syntax:
	## 	[location]
	## 	inside_turbo_fat
	func line(line: String) -> String:
		var result := ""
		if line:
			chat_tree.location_id = line
		else:
			result = DEFAULT
		return result

# -----------------------------------------------------------------------------

## Parser state for parsing character data (participants in a conversation).
class CharactersState extends AbstractState:
	
	## Creature aliases used in chatscript chat lines. ChatState references this dictionary when parsing chat lines.
	##
	## key: (String) creature id
	## value: (String) alias used in chatscript chat lines
	var _character_aliases: Dictionary
	
	func _init(init_chat_tree: ChatTree, init_chat_aliases: Dictionary).(init_chat_tree) -> void:
		_character_aliases = init_chat_aliases
	
	
	func line(line: String) -> String:
		var result := ""
		if line:
			_parse_character_name(line)
		else:
			result = DEFAULT
		return result
	
	
	## Syntax:
	## 	skins, s, kitchen_9        - a character named 'skins' with an alias 's' spawns at kitchen_9
	## 	skins, s, !kitchen_9       - a character named 'skins' with an alias 's' spawns invisible at kitchen_9
	## 	(chef) skins, s            - a character named 'skins' with an alias 's' is the chef for this scene
	## 	(customer) rhonk           - a character named 'rhonk' is a customer for this scene
	## 	(observer) bones           - a character named 'bones' is the observer for this scene
	## 	skins, s                   - a character named 'skins' with an alias 's'
	## 	skins                      - a character named 'skins'
	func _parse_character_name(line: String) -> void:
		var line_parts := line.split(",")
		var character_name := "" if line_parts.size() < 1 else line_parts[0].strip_edges()
		var character_prefix: String
		
		for possible_prefix in ["(chef)", "(customer)", "(observer)"]:
			if character_name.begins_with(possible_prefix):
				character_name = StringUtils.substring_after(character_name, possible_prefix).strip_edges()
				character_prefix = possible_prefix
				break
		
		# parse character name
		character_name = StringUtils.hashwrap_constants(character_name)
		
		# parse (chef) prefix
		if character_prefix == "(chef)":
			if chat_tree.chef_id:
				chat_tree.warn("Too many chefs: %s" % [character_name])
			chat_tree.chef_id = character_name
		
		# parse (customer) prefix
		if character_prefix == "(customer)":
			chat_tree.customer_ids.append(character_name)
		
		# parse (observer) prefix
		if character_prefix == "(observer)":
			if chat_tree.observer_id:
				chat_tree.warn("Too many observers: %s" % [character_name])
			chat_tree.observer_id = character_name
		
		# parse spawn location
		var character_location := "" if line_parts.size() < 3 else line_parts[2].strip_edges()
		if character_name and character_location:
			chat_tree.spawn_locations[character_name] = character_location
		
		# parse alias
		var character_alias := "" if line_parts.size() < 2 else line_parts[1].strip_edges()
		if character_name and character_alias:
			_character_aliases[character_alias] = character_name

# -----------------------------------------------------------------------------

## Parser state for parsing chat lines (chat events and branches)
class ChatState extends AbstractState:
	
	## Creature aliases used in chatscript chat lines. CharactersState populates this dictionary when parsing
	## characters.
	##
	## key: (String) creature id
	## value: (String) alias used in chatscript chat lines
	var _character_aliases: Dictionary
	
	## The current chat event being parsed. Any parsed metadata and links will be attached to this event.
	var _event: ChatEvent
	
	## The current branch key being parsed. Any additional chat events will be attached to this branch.
	var _branch_key := ""
	
	func _init(init_chat_tree: ChatTree, init_chat_aliases: Dictionary).(init_chat_tree) -> void:
		_character_aliases = init_chat_aliases
	
	
	## Syntax:
	## 	s: /._. Are you sure?
	## 	[yes] Okay, fine.
	## 	[no]
	##
	## 	[yes]
	## 	p1: ^_^ Okay fine, I could use some exercise.
	## 	s: ^__^ Great!
	##
	## 	[no]
	## 	p1: Never mind, I don't want to.
	## 	s: u_u Oh...
	func line(line: String) -> String:
		var result := ""
		if line:
			if line.begins_with("["):
				if _event:
					_parse_chat_link(line)
				else:
					_parse_branch_key(line)
			elif line.begins_with("("):
				_parse_thought(line)
			elif line.begins_with(" ("):
				_parse_meta(line)
			else:
				_parse_chat_line(line)
		else:
			_event = null
		return result
	
	
	## Syntax:
	## 	s: ^_^ Oh okay cool!
	func _parse_chat_line(line: String) -> void:
		if not ": " in line:
			chat_tree.warn("Malformed chat line: %s" % [line])
			return
		
		_event = ChatEvent.new()
		
		var who := StringUtils.substring_before(line, ": ")
		who = _unalias(who)
		if _character_aliases:
			if not who in _character_aliases and not who in _character_aliases.values():
				chat_tree.warn("Unrecognized character name: %s" % [who])
		_event.who = who
		
		_event.text = StringUtils.substring_after(line, ": ")
		_event.text = _event.text.c_unescape() # turn '\n' characters into newlines
		var creature_def: CreatureDef = PlayerData.creature_library.get_creature_def(_event.who)
		if creature_def:
			_event.chat_theme = creature_def.chat_theme
		var mood_prefix := StringUtils.substring_before(_event.text, " ")
		if mood_prefix in MOOD_PREFIXES:
			_event.mood = MOOD_PREFIXES[mood_prefix]
			_event.text = _event.text.trim_prefix(mood_prefix).strip_edges()
		chat_tree.append(_branch_key, _event)
	
	
	## Syntax:
	## 	[very-good] I think you killed it!
	## 	[just-okay] <_< I think it was just okay...
	func _parse_chat_link(line: String) -> void:
		# add branch to _event
		if not line.begins_with("[") or not "]" in line:
			chat_tree.warn("Malformed chat link: %s" % [line])
			return
		
		var branch_name := StringUtils.substring_between(line, "[", "]").strip_edges()
		var branch_text := StringUtils.substring_after(line, "]").strip_edges()
		branch_text = branch_text.c_unescape() # turn '\n' characters into newlines
		var branch_mood := -1
		var mood_prefix := StringUtils.substring_before(branch_text, " ")
		if mood_prefix in MOOD_PREFIXES:
			branch_mood = MOOD_PREFIXES[mood_prefix]
			branch_text = branch_text.trim_prefix(mood_prefix).strip_edges()
			# turn '\n' characters into newlines
		_event.add_link(branch_name, branch_text, branch_mood)
	
	
	## Syntax:
	## 	[very-good]
	func _parse_branch_key(line: String) -> void:
		if not line.begins_with("[") or not line.ends_with("]"):
			chat_tree.warn("Malformed chat branch: %s" % [line])
			return
		
		_branch_key = line.trim_prefix("[").trim_suffix("]")
	
	
	## Syntax:
	## 	(I'm not sure if they heard me.)
	func _parse_thought(line: String) -> void:
		if not line.begins_with("(") or not line.ends_with(")"):
			chat_tree.warn("Malformed thought: %s" % [line])
			return
		
		_event = ChatEvent.new()
		_event.text = line
		_event.text = _event.text.c_unescape() # turn '\n' characters into newlines
		var creature_def: CreatureDef = PlayerData.creature_library.get_player_def()
		if creature_def:
			_event.chat_theme = creature_def.chat_theme
		chat_tree.append(_branch_key, _event)
	
	
	## Syntax:
	## 	' (spira enters)'  <-- with a leading space
	func _parse_meta(line: String) -> void:
		if not line.begins_with(" (") or not line.ends_with(")"):
			chat_tree.warn("Malformed meta: %s" % [line])
			return
		
		var meta_array_string := line.trim_prefix(" (").trim_suffix(")").strip_edges()
		var meta := meta_array_string.split(",")
		for i in range(meta.size()):
			meta[i] = meta[i].strip_edges()
			meta[i] = _translate_meta_item(meta[i])
		_event.meta.append_array(meta)
		if _event.links:
			_event.link_metas.back().append_array(meta)
	
	
	## Translates human-readable phrases like 'spira enters' into metadata like 'creature_enter spira'
	func _translate_meta_item(item: String) -> String:
		var result := item
		if item.ends_with(" enters"):
			# spira enters -> creature_enter spira
			var name := item.trim_suffix(" enters")
			result = "creature_enter %s" % [_unalias(name)]
		elif item.ends_with(" exits"):
			# spira exits -> creature_exit spira
			var name := item.trim_suffix(" exits")
			result = "creature_exit %s" % [_unalias(name)]
		elif " mood " in item:
			# spira mood ^_^ -> creature_mood spira 7
			var name := StringUtils.substring_before(item, " mood ")
			name = _unalias(name)
			var mood := StringUtils.substring_after(item, " mood ")
			result = "creature_mood %s %s" % [name, MOOD_PREFIXES[mood]]
		elif " faces " in item:
			# spira faces left -> creature_orientation spira 1
			var name := StringUtils.substring_before(item, " faces ")
			name = _unalias(name)
			var orientation := StringUtils.substring_after(item, " faces ")
			result = "creature_orientation %s %s" % [name, ORIENTATION_STRINGS[orientation]]
		return result
	
	## Converts aliases like 's' and 'p1' into names like 'skins' and '#player#'.
	##
	## _unalias("s")       = "skins"
	## _unalias("p1")      = "#player#"
	## _unalias("player")  = "#player#"
	## _unalias("skins")   = "skins"
	##
	## Parameters:
	## 	'name': A name or alias such as 's', 'p1' or 'skins'.
	##
	## Returns:
	## 	The name or constant corresponding to the specified alias.
	func _unalias(s: String) -> String:
		var result := s
		result = _character_aliases.get(result, result)
		result = StringUtils.hashwrap_constants(result)
		return result


# -----------------------------------------------------------------------------

## Current version for saved chatscript data. Should be updated if and only if the chat format breaks backwards
## compatibility. This version number follows a 'ymdh' hex date format which is documented in issue #234.
const CHATSCRIPT_VERSION := "2476"

## Emoticons which can appear at the start of a chat line to define its mood
## key: (String) String emoji representing a chatscript mood
## value: (int) An enum from Creatures.Mood
const MOOD_PREFIXES := {
	"._.": Creatures.Mood.DEFAULT,
	"<_<": Creatures.Mood.AWKWARD0,
	">_>": Creatures.Mood.AWKWARD0,
	"<__<": Creatures.Mood.AWKWARD1,
	">__>": Creatures.Mood.AWKWARD1,
	"u_u": Creatures.Mood.CRY0,
	"T_T": Creatures.Mood.CRY0,
	"Q_Q": Creatures.Mood.CRY0,
	"u__u": Creatures.Mood.CRY1,
	"T__T": Creatures.Mood.CRY1,
	"Q__Q": Creatures.Mood.CRY1,
	"^o^": Creatures.Mood.LAUGH0,
	"^O^": Creatures.Mood.LAUGH1,
	"owo": Creatures.Mood.LOVE0,
	"OwO": Creatures.Mood.LOVE1,
	"OwO...": Creatures.Mood.LOVE1_FOREVER,
	"^n^": Creatures.Mood.NO0,
	"^N^": Creatures.Mood.NO1,
	">_<": Creatures.Mood.RAGE0,
	">__<": Creatures.Mood.RAGE1,
	">___<": Creatures.Mood.RAGE2,
	"-_-": Creatures.Mood.SIGH0,
	"-__-": Creatures.Mood.SIGH1,
	"-u-": Creatures.Mood.SLY0,
	"-o-": Creatures.Mood.SLY1,
	"^_^": Creatures.Mood.SMILE0,
	"^__^": Creatures.Mood.SMILE1,
	"._.;": Creatures.Mood.SWEAT0,
	".__.;": Creatures.Mood.SWEAT1,
	"-_-;": Creatures.Mood.SWEAT0,
	"-__-;": Creatures.Mood.SWEAT1,
	"/._.": Creatures.Mood.THINK0,
	"@_@": Creatures.Mood.THINK1,
	"._./": Creatures.Mood.WAVE0,
	"^_^/": Creatures.Mood.WAVE1,
	"^__^/": Creatures.Mood.WAVE2,
	"^y^": Creatures.Mood.YES0,
	"^Y^": Creatures.Mood.YES1,
}

## Different directions a creature can face
## key: (String) String representing a direction a creature can face
## value: (int) An enum from Creatures.Orientation
const ORIENTATION_STRINGS := {
	"left": Creatures.SOUTHWEST,
	"right": Creatures.SOUTHEAST,
	"se": Creatures.SOUTHEAST,
	"sw": Creatures.SOUTHWEST,
	"nw": Creatures.NORTHWEST,
	"ne": Creatures.NORTHEAST,
}

## parser headers which appear in square braces in the chatscript file
const DEFAULT := "default"
const LOCATION := "location"
const CHARACTERS := "characters"
const CHAT := "chat"

## key: (String) parser state name such as 'default', 'location', 'characters', 'chat'
## value: (AbstractState) parser state
var _states_by_name: Dictionary

## the chat tree being parsed
var _chat_tree := ChatTree.new()
var _state: AbstractState

## key: (String) creature id
## value: (String) alias used in chatscript chat lines
var _character_aliases := {}

func _init() -> void:
	_states_by_name = {
		DEFAULT: DefaultState.new(_chat_tree),
		LOCATION: LocationState.new(_chat_tree),
		CHARACTERS: CharactersState.new(_chat_tree, _character_aliases),
		CHAT: ChatState.new(_chat_tree, _character_aliases),
	}
	_states_by_name[DEFAULT].chat_state = _states_by_name[CHAT]
	_state = _states_by_name[DEFAULT]


## Parses a ChatTree from the specified chatscript resource.
##
## This class is stateful and intended to be used once and thrown away. If chat_tree_from_file is invoked more than
## once, the previously parsed chat_tree will be erased.
func chat_tree_from_file(path: String) -> ChatTree:
	_chat_tree.reset()
	_character_aliases.clear()
	
	if not FileUtils.file_exists(path):
		push_error("File not found: %s" % [path])
	else:
		var f := File.new()
		f.open(path, File.READ)
		
		while f.get_error() == OK and not f.eof_reached():
			# strip any whitespace at the end of the line
			var line := f.get_line().strip_edges(false)
			if line.begins_with("//"):
				# comment; ignore line
				continue
			var new_state_name := _state.line(line)
			if new_state_name:
				if not _states_by_name.has(new_state_name):
					_chat_tree.warn("Invalid header line: %s" % [line])
					continue
				_state = _states_by_name[new_state_name]
		
		match f.get_error():
			OK, ERR_FILE_EOF:
				pass
			_:
				push_error("File error %s: %s" % [f.get_error(), path])
		
		if f.is_open():
			f.close()
		
		_chat_tree.chat_key = ChatLibrary.chat_key_from_path(path)
	
	return _chat_tree
