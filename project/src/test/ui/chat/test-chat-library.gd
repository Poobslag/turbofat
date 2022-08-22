extends "res://addons/gut/test.gd"

func test_add_lull_characters_no_effect() -> void:
	assert_eq(ChatLibrary.add_lull_characters(""), "")
	assert_eq(ChatLibrary.add_lull_characters("One"), "One")
	assert_eq(ChatLibrary.add_lull_characters("One two"), "One two")
	assert_eq(ChatLibrary.add_lull_characters("One two."), "One two.")


func test_add_lull_characters_punctuation() -> void:
	assert_eq(ChatLibrary.add_lull_characters("One two, three four!"), "One two,| three four!")
	assert_eq(ChatLibrary.add_lull_characters("One? Two!"), "One?| Two!")
	assert_eq(ChatLibrary.add_lull_characters("One! Two! Three."), "One!| Two!| Three.")
	
	assert_eq(ChatLibrary.add_lull_characters("One - two."), "One -| two.")
	assert_eq(ChatLibrary.add_lull_characters("One -- two."), "One -|-| two.")
	assert_eq(ChatLibrary.add_lull_characters("That's a half-baked idea."), "That's a half-baked idea.")
	
	# Don't add lull characters if there are already lull characters.
	assert_eq(ChatLibrary.add_lull_characters("One -|||-||| two."), "One -|||-||| two.")
	assert_eq(ChatLibrary.add_lull_characters("O||n||e||.|||||| Two, three!"), "O||n||e||.|||||| Two, three!")


func test_add_lull_characters_ellipses() -> void:
	assert_eq(ChatLibrary.add_lull_characters("..."), ".|.|.")
	assert_eq(ChatLibrary.add_lull_characters("...One"), ".|.|.|One")
	assert_eq(ChatLibrary.add_lull_characters("One..."), "One...")
	assert_eq(ChatLibrary.add_lull_characters("One...?"), "One...?")
	assert_eq(ChatLibrary.add_lull_characters("One...!"), "One...!")
	assert_eq(ChatLibrary.add_lull_characters("One... two. ...Three four."), "One.|.|.| two.| .|.|.|Three four.")


func test_add_mega_lull_characters() -> void:
	assert_eq(ChatLibrary.add_mega_lull_characters("OH, MY!!!"), "O|H|,||| M|Y|!|!|!")
	assert_eq(ChatLibrary.add_mega_lull_characters("¡¡¡OH, MI!!!"), "¡|¡|¡|O|H|,||| M|I|!|!|!")
	assert_eq(ChatLibrary.add_mega_lull_characters("О, МОЙ!"), "О|,||| М|О|Й|!")


func test_chat_key_from_path() -> void:
	assert_eq(ChatLibrary.chat_key_from_path("res://assets/main/chat/career/lemon/10-a.chat"),
			"chat/career/lemon/10_a")


func test_path_from_chat_key() -> void:
	assert_eq(ChatLibrary.path_from_chat_key("chat/career/lemon/10_a"),
			"res://assets/main/chat/career/lemon/10-a.chat")
