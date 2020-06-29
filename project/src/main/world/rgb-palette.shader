/*
 * A shader which takes an RGB image, and replaces the red component with one color, the green component with a second
 * color, and the blue component with a third color. Black pixels are also replaced with a fourth color. A pixel
 * which is mostly red but a little green will be replaced with the first and second colors.
 *
 * This approach allow a sprite to be recolored with up to four channels, and the recoloring can be handled by the
 * graphics card. It's performant and looks reasonable even if the sprite is resized before being passed off to the
 * graphics card.
 */
shader_type canvas_item;

// the replacement colors
uniform vec4 red : hint_color;
uniform vec4 green : hint_color;
uniform vec4 blue : hint_color;
uniform vec4 black : hint_color;

void fragment() {
	vec4 rgba_in = texture(TEXTURE, UV);
	
	// color defaults to the black replacement color
	vec4 rgb_out = black;
	
	// mix in other colors based on the red, green and blue components of the source image
	rgb_out = mix(rgb_out, red.rgba, rgba_in.r);
	rgb_out = mix(rgb_out, green.rgba, rgba_in.g);
	rgb_out = mix(rgb_out, blue.rgba, rgba_in.b);
	
	// Assign final color for the pixel, and preserve transparency
	COLOR = vec4(rgb_out.rgb, rgba_in.a * rgb_out.a);
}