/*
 * A shader which takes an RGB image, and replaces the red component with one texture, the green component with a second
 * texture, and the blue component with a third texture. Black pixels are also replaced with a solid color. A pixel
 * which is mostly red but a little green will be replaced with the first and second texture.
 *
 * This approach allow a sprite to be recolored with up to four channels, and the recoloring can be handled by the
 * graphics card. It's performant and looks reasonable even if the sprite is resized before being passed off to the
 * graphics card.
 */
shader_type canvas_item;
render_mode blend_mix;

// replacement textures for red, green and blue channels
uniform sampler2D red_texture;
uniform sampler2D green_texture;
uniform sampler2D blue_texture;

// replacement color for dark parts of the image (shadows)
uniform vec4 black : hint_color;

// scaling factor for each texture; bigger values will draw the textures larger
uniform vec2 red_texture_scale = vec2(1.0, 1.0);
uniform vec2 green_texture_scale = vec2(1.0, 1.0);
uniform vec2 blue_texture_scale = vec2(1.0, 1.0);

// offset for each texture; bigger values will move the textures down and right
uniform vec2 red_texture_offset = vec2(0.0, 0.0);
uniform vec2 green_texture_offset = vec2(0.0, 0.0);
uniform vec2 blue_texture_offset = vec2(0.0, 0.0);

void fragment() {
	vec4 rgba_in = texture(TEXTURE, UV);
	vec2 texture_size = vec2(textureSize(TEXTURE, 0));
	
	vec4 red = texture(red_texture, (UV - red_texture_offset) * texture_size / vec2(textureSize(red_texture, 0)) / red_texture_scale);
	vec4 green = texture(green_texture, (UV - green_texture_offset) * texture_size / vec2(textureSize(green_texture, 0)) / green_texture_scale);
	vec4 blue = texture(blue_texture, (UV - blue_texture_offset) * texture_size / vec2(textureSize(blue_texture, 0)) / blue_texture_scale);
	
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