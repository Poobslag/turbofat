extends "res://addons/gut/test.gd"

var chat_theme := ChatTheme.new()

func test_border_color_dark() -> void:
	chat_theme.dark = true
	
	# very bright; little if any adjustment
	chat_theme.color = Color("e8e3ee")
	assert_eq("ffd6d2da", chat_theme.border_color.to_html())
	
	# dim; border color is brightened
	chat_theme.color = Color("48336e")
	assert_eq("ff70589a", chat_theme.border_color.to_html())
	
	# black; border color is brightened
	chat_theme.color = Color("000000")
	assert_eq("ff656565", chat_theme.border_color.to_html())


func test_accent_color_dark() -> void:
	chat_theme.dark = true
	
	# very bright; accent color is darkened
	chat_theme.color = Color("e8e3ee")
	assert_eq("ffa29fa6", chat_theme.accent_color.to_html())
	
	# dim; accent color is lightened
	chat_theme.color = Color("48336e")
	assert_eq("ff513d75", chat_theme.accent_color.to_html())
	
	# black; accent color is lightened
	chat_theme.color = Color("000000")
	assert_eq("ff4d4d4d", chat_theme.accent_color.to_html())


func test_border_color_light() -> void:
	chat_theme.dark = false
	
	# very dark; little if any adjustment
	chat_theme.color = Color("18131e")
	assert_eq("ff241e2b", chat_theme.border_color.to_html())
	
	# bright; border color is darkened
	chat_theme.color = Color("b8c39e")
	assert_eq("ff636758", chat_theme.border_color.to_html())
	
	# white; border color is darkened
	chat_theme.color = Color("ffffff")
	assert_eq("ff6b6b6b", chat_theme.border_color.to_html())


func test_accent_color_light() -> void:
	chat_theme.dark = false
	
	# very dark; accent color is lightened
	chat_theme.color = Color("18131e")
	assert_eq("ff3e3a43", chat_theme.accent_color.to_html())
	
	# bright; accent color is darkened
	chat_theme.color = Color("b8c39e")
	assert_eq("ff8d9579", chat_theme.accent_color.to_html())
	
	# white; accent color is darkened
	chat_theme.color = Color("ffffff")
	assert_eq("ff808080", chat_theme.accent_color.to_html())
