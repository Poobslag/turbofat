extends Label
"""
Renders the current frames-per-second to the screen, '60.00 fps'
"""

func _process(delta: float):
	text = "%.2f fps" % Engine.get_frames_per_second()
