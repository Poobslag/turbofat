shader_type canvas_item;
render_mode unshaded;
/**
 * Shader which applies a shadow texture to the creature's body.
 *
 * The shadow texture is 100% black, and the creature's body uses the 'rgb-palette' texture. This shader applies the
 * shadow texture over top of the body texture, and replaces the red/green/blue components with a set of replacement
 * colors.
 */

// a texture with shadows to draw on the body texture
uniform sampler2D shadow_texture : hint_albedo;

// a texture with decorations to draw on the body texture
uniform sampler2D color_texture : hint_albedo;

// the replacement colors
uniform vec4 red : hint_color;
uniform vec4 green : hint_color;
uniform vec4 blue : hint_color;
uniform vec4 black : hint_color;

void fragment()
{
	vec4 rgba_in = texture(TEXTURE, UV);
	
	vec4 shadow_in = texture(shadow_texture, UV);
	shadow_in.a *= 0.25;
	
	// pre-mix the shadow and decoration colors
	vec4 color_in = texture(color_texture, UV);
	color_in.rgb /= max(color_in.a, 0.001);
	color_in.rgb = mix(color_in.rgb, shadow_in.rgb, shadow_in.a);
	color_in.a = min(color_in.a + shadow_in.a, 1.0);
	
	// apply the shadow and decoration colors to the red parts of the texture
	rgba_in.rgb = mix(rgba_in.rgb, color_in.rgb, color_in.a * rgba_in.r);
	
	// the output color defaults to the black replacement color. we then apply other colors over top of it
	vec4 rgb_out = black;
	rgb_out = mix(rgb_out, red.rgba, rgba_in.r * rgba_in.a);
	rgb_out = mix(rgb_out, green.rgba, rgba_in.g * rgba_in.a);
	rgb_out = mix(rgb_out, blue.rgba, rgba_in.b * rgba_in.a);
	
	// assign final color for the pixel, and preserve transparency
	COLOR = vec4(rgb_out.rgb, rgba_in.a);
}