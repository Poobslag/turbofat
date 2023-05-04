extends GutTest

var chat_theme := ChatTheme.new()

func test_border_color_dark() -> void:
	chat_theme.dark = true
	
	# very bright; little if any adjustment
	chat_theme.color = Color("e8e3ee")
	assert_eq("d6d2daff", chat_theme.border_color.to_html())
	
	# dim; border color is brightened
	chat_theme.color = Color("48336e")
	assert_eq("70589aff", chat_theme.border_color.to_html())
	
	# black; border color is brightened
	chat_theme.color = Color("000000")
	assert_eq("656565ff", chat_theme.border_color.to_html())


func test_accent_color_dark() -> void:
	chat_theme.dark = true
	
	# very bright; accent color is darkened
	chat_theme.color = Color("e8e3ee")
	assert_eq("a29fa6ff", chat_theme.accent_color.to_html())
	
	# dim; accent color is lightened
	chat_theme.color = Color("48336e")
	assert_eq("513d75ff", chat_theme.accent_color.to_html())
	
	# black; accent color is lightened
	chat_theme.color = Color("000000")
	assert_eq("4d4d4dff", chat_theme.accent_color.to_html())


func test_border_color_light() -> void:
	chat_theme.dark = false
	
	# very dark; little if any adjustment
	chat_theme.color = Color("18131e")
	assert_eq("241e2bff", chat_theme.border_color.to_html())
	
	# bright; border color is darkened
	chat_theme.color = Color("b8c39e")
	assert_eq("636758ff", chat_theme.border_color.to_html())
	
	# white; border color is darkened
	chat_theme.color = Color("ffffff")
	assert_eq("6b6b6bff", chat_theme.border_color.to_html())


func test_accent_color_light() -> void:
	chat_theme.dark = false
	
	# very dark; accent color is lightened
	chat_theme.color = Color("18131e")
	assert_eq("3e3a43ff", chat_theme.accent_color.to_html())
	
	# bright; accent color is darkened
	chat_theme.color = Color("b8c39e")
	assert_eq("8d9579ff", chat_theme.accent_color.to_html())
	
	# white; accent color is darkened
	chat_theme.color = Color("ffffff")
	assert_eq("808080ff", chat_theme.accent_color.to_html())
