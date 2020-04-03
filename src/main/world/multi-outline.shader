/*
 * A shader used to draw outlines around groups of sprites, instead of individual sprites. Darkens a sprite and pads
 * it by several pixels. This results in a larger, darker sprite which can be placed behind it to act as an outline.
 *
 * Adapted from outline.shader obtained from GDQuest's godot-demos, 2020-04-01
 *
 * https://github.com/GDQuest/godot-demos/blob/master/2018/09-20-shaders/shaders/outline.shader
 */
shader_type canvas_item;

uniform float width: hint_range(0.0, 16.0);
uniform vec4 black : hint_color;

void fragment() {
	vec2 size = vec2(width) / vec2(textureSize(TEXTURE, 0));
	
	vec4 sprite_color = texture(TEXTURE, UV);
	
	float alpha = sprite_color.a;
	
	// cardinal directions
	alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, -size.y)).a);
	alpha = max(alpha, texture(TEXTURE, UV + vec2(size.x, 0.0)).a);
	alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, size.y)).a);
	alpha = max(alpha, texture(TEXTURE, UV + vec2(-size.x, 0.0)).a);
	
	// diagonal directions; divide by sqrt(2)
	alpha = max(alpha, texture(TEXTURE, UV + vec2(size.x * 0.7071, -size.y * 0.7071)).a);
	alpha = max(alpha, texture(TEXTURE, UV + vec2(size.x * 0.7071, size.y * 0.7071)).a);
	alpha = max(alpha, texture(TEXTURE, UV + vec2(-size.x * 0.7071, size.y * 0.7071)).a);
	alpha = max(alpha, texture(TEXTURE, UV + vec2(-size.x * 0.7071, -size.y * 0.7071)).a);
	
	COLOR = vec4(black.rgb, alpha);
}
