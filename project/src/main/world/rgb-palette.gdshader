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

// replacement colors for red, green and blue channels
uniform vec4 red : source_color;
uniform vec4 green : source_color;
uniform vec4 blue : source_color;

// replacement color for dark parts of the image (shadows)
uniform vec4 black : source_color;

void fragment() {
	vec4 rgba_in = texture(TEXTURE, UV);
	
	// mix black/red/blue/green colors sequentially. if all rgb components are equal, we first mix in 100% of the red
	// color, then 50% of the green color, then 33% of the blue color.
	float black_amount = max(0.0, 1.0 - rgba_in.r - rgba_in.g - rgba_in.b);
	vec4 rgb_out = black;
	rgb_out = mix(rgb_out, red, rgba_in.r / max(0.00001, rgba_in.r + black_amount));
	rgb_out = mix(rgb_out, green, rgba_in.g / max(0.00001, rgba_in.g + rgba_in.r + black_amount));
	rgb_out = mix(rgb_out, blue, rgba_in.b / max(0.00001, rgba_in.b + rgba_in.g + rgba_in.r + black_amount));
	rgb_out.a = rgba_in.a;
	
	// Assign final color for the pixel, and preserve transparency
	COLOR = vec4(rgb_out.rgb, rgba_in.a * rgb_out.a);
}