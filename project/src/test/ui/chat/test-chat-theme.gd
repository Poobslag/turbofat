extends "res://addons/gut/test.gd"

var chat_theme := ChatTheme.new()

func test_border_color_dark() -> void:
	chat_theme.dark = true
	
	# very bright; no adjustment
	chat_theme.color = Color("e8e3ee")
	assert_eq("ffe8e3ee", chat_theme.border_color.to_html())
	
	# dim; border color is brightened
	chat_theme.color = Color("48336e")
	assert_eq("ff635184", chat_theme.border_color.to_html())
	
	# black; border color is brightened
	chat_theme.color = Color("000000")
	assert_eq("ff666666", chat_theme.border_color.to_html())


func test_accent_color_dark() -> void:
	chat_theme.dark = true
	
	# very bright; accent color is darkened
	chat_theme.color = Color("e8e3ee")
	assert_eq("ffd1ccd6", chat_theme.accent_color.to_html())
	
	# dim; accent color is lightened
	chat_theme.color = Color("48336e")
	assert_eq("ff635184", chat_theme.accent_color.to_html())
	
	# black; accent color is lightened
	chat_theme.color = Color("000000")
	assert_eq("ff666666", chat_theme.accent_color.to_html())


func test_border_color_light() -> void:
	chat_theme.dark = false
	
	# very dark; no adjustment
	chat_theme.color = Color("18131e")
	assert_eq("ff18131e", chat_theme.border_color.to_html())
	
	# bright; border color is darkened
	chat_theme.color = Color("b8c39e")
	assert_eq("ff8d9579", chat_theme.border_color.to_html())
	
	# white; border color is darkened
	chat_theme.color = Color("ffffff")
	assert_eq("ff808080", chat_theme.border_color.to_html())


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
