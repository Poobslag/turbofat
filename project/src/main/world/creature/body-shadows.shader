shader_type canvas_item;
render_mode unshaded;
/**
 * Shader which applies a shadow texture to the creature's body.
 *
 * The shadow texture is 100% black, and the creature's body uses the 'rgb-palette' texture. This shader applies the
 * shadow texture over top of the body texture, and replaces the red/green/blue components with a set of replacement
 * colors.
 */

// the shadow texture which is drawn over top of the body texture
uniform sampler2D shadow_texture : hint_albedo;

// the replacement colors
uniform vec4 red : hint_color;
uniform vec4 green : hint_color;
uniform vec4 blue : hint_color;
uniform vec4 black : hint_color;

void fragment()
{
	vec4 rgba_in = texture(TEXTURE, UV);
	// darken the body texture based on shadow_texture's alpha
	rgba_in.rgb = mix(rgba_in.rgb, vec3(0.0), texture(shadow_texture, UV).a * 0.25) / max(rgba_in.a, 0.01);
	
	// color defaults to the black replacement color
	vec4 rgb_out = black;
	
	// mix in other colors based on the red, green and blue components of the source image
	rgb_out = mix(rgb_out, red.rgba, rgba_in.r);
	rgb_out = mix(rgb_out, green.rgba, rgba_in.g);
	rgb_out = mix(rgb_out, blue.rgba, rgba_in.b);
	
	// Assign final color for the pixel, and preserve transparency
	COLOR = vec4(rgb_out.rgb, rgba_in.a);
}