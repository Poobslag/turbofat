shader_type canvas_item;
/*
 * Recolors a bar shown in the results screen's bar graph to use a particular set of textures and colors.
 *
 * Each bar graph bar has a unique colored texture or 'accent' which is tiled against a white background. The texture
 * can be resized or recolored. It can also be swapped so that it draws white shapes against a colored background.
 *
 * The shader is applied to a texture which contains a black outlined shape with white inside, and transparent outside.
 * The shader code uses the red channel of the texture to determine where to draw the background accents.
 */

const float PI = 3.14159265358979;

// The size of the node this shader is applied to
uniform vec2 node_size = vec2(100, 100);

// The color of the border, which is black in the source texture
uniform vec4 black : hint_color;

// The color of the middle area, which is white in the source texture
uniform vec4 white : hint_color;

// A monochrome texture containing the accents to draw in the chat window's middle
uniform sampler2D accent_texture;

uniform float accent_scale = 0.25;

// Accent texture rotation in degrees
uniform float accent_rotation = 0.0;

// If 'false', the accents will be drawn as colored shapes against a white background. If 'true', the two are swapped
// as white shapes against a colored background.
uniform bool accent_swapped = false;

void fragment() {
	vec4 rgba_in = COLOR;
	
	// Apply the node size, texture size and rotation
	vec2 tex_uv = UV * node_size - node_size;
	tex_uv = tex_uv * mat2(vec2(cos(radians(-accent_rotation)), -sin(radians(-accent_rotation))), vec2(sin(radians(-accent_rotation)), cos(radians(-accent_rotation))));
	tex_uv /= accent_scale * vec2(textureSize(accent_texture, 0));

	// Apply the texture image
	vec4 tex_rgba = accent_swapped ? vec4(1.0) - textureLod(accent_texture, tex_uv, 1.5) : textureLod(accent_texture, tex_uv, 1.5);
	vec4 rgba_out = mix(black, white, rgba_in * tex_rgba.r);

	// preserve transparency of source image
	rgba_out.a *= rgba_in.a;
	COLOR = vec4(rgba_out.rgb, rgba_out.a);
}