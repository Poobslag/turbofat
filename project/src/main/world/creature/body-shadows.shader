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
	

	// mix black/red/blue/green colors sequentially. if all rgb components are equal, we first mix in 100% of the red
	// color, then 50% of the green color, then 33% of the blue color.
	float black_amount = max(0.0, 1.0 - rgba_in.r / rgba_in.a - rgba_in.g / rgba_in.a - rgba_in.b / rgba_in.a);
	vec4 rgb_out = black;
	rgb_out = mix(rgb_out, red, rgba_in.r / max(0.00001, rgba_in.r + black_amount));
	rgb_out = mix(rgb_out, green, rgba_in.g / max(0.00001, rgba_in.g + rgba_in.r + black_amount));
	rgb_out = mix(rgb_out, blue, rgba_in.b / max(0.00001, rgba_in.b + rgba_in.g + rgba_in.r + black_amount));
	
	// assign final color for the pixel, and preserve transparency
	COLOR = vec4(rgb_out.rgb, rgba_in.a);
}