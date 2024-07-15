shader_type canvas_item;
/**
 * Draws an outline around a sprite. Adapted from outline.shader obtained from GDQuest's godot-demos, 2020-04-01
 *
 * https://github.com/GDQuest/godot-demos/blob/master/2018/09-20-shaders/shaders/outline.shader
 */

uniform float width: hint_range(0.0, 16.0);
uniform vec4 black: hint_color;

// 1.0 for most textures, 0.001 for viewport textures. Fixes aliasing artifacts specific to viewport textures.
uniform float edge_fix_factor = 1.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * width;
	
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
	
	vec3 final_color = mix(black.rgb, sprite_color.rgb / max(sprite_color.a, edge_fix_factor), sprite_color.a);
	COLOR = vec4(final_color, alpha);
}
