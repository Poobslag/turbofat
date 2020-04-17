shader_type canvas_item;
/*
 * Recolors the conversation window to use vibrant colors and a scrolling background.
 *
 * The conversation window has a colored texture or 'accent' which scrolls in a vaguely circular motion across a white
 * background. The texture can be resized or recolored. It can also be swapped so that it draws white shapes against
 * a colored background.
 *
 * The shader is applied to a texture which contains a black outlined shape with red inside, and transparent outside.
 * The shader code uses the red channel of the texture to determine where to draw the background accents.
 */

const float PI = 3.14159265358979;

// The size of the sprite the shader is applied to. A larger value results in the texture being scaled down and
// scrolling slower.
const vec2 sprite_size = vec2(2048.0, 512.0);

// The color of the border around the chat window, which is black in the source texture
uniform vec4 border_color : hint_color;

// The color of the chat window's middle area, which is red in the source texture
uniform vec4 center_color : hint_color;

// The color of the accents drawn in the chat window's middle
uniform vec4 accent_color : hint_color;

// A monochrome texture containing the accents to draw in the chat window's middle
uniform sampler2D accent_texture;

// A number from [0, 1.0] representing how opaque the accents are; 1.0 = fully opaque
uniform float accent_amount = 0.24;
uniform float accent_scale = 2.0;

// If 'false', the accents will be drawn as colored shapes against a white background. If 'true', the two are swapped
// as white shapes against a colored background.
uniform bool accent_swapped = false;

// A number from [0, 1.0] representing how transparent the middle area is; 1.0 = fully transparent
uniform float center_transparency = 0.16;

// The number of seconds the accents take to scroll back to their original position
uniform vec2 scroll_period = vec2(7.377, 4.111);

// Combined with sprite_size, this decides how far the accents scroll
uniform vec2 scroll_distance = vec2(120.0, 60.0);

void fragment() {
	vec4 rgba_in = texture(TEXTURE, UV);
	
	vec2 scroll_amount = vec2(0.0);
	// scroll in a vaguely circle motion
	scroll_amount.x = scroll_distance.x * 0.5 * sin(2.0 * PI * TIME / scroll_period.x) / sprite_size.x;
	scroll_amount.y = scroll_distance.y * 0.5 * cos(2.0 * PI * TIME / scroll_period.y) / sprite_size.y;
	// gradually scroll the texture vertically
	scroll_amount.y += TIME * scroll_distance.y * 0.33 / sprite_size.y;
	scroll_amount /= accent_scale;

	// mix in the middle texture based on the red component of the source image
	vec4 rgba_out = mix(border_color, center_color, rgba_in.r);
	vec4 tex_color = vec4(1.0) - texture(accent_texture, UV * vec2(6.0, 1.50) / accent_scale + scroll_amount);
	if (accent_swapped)
		// flip it so the accents are white and the background is colored
		tex_color = vec4(1.0) - tex_color;
	rgba_out = mix(rgba_out, accent_color, rgba_in.r * accent_amount * tex_color);
	
	// preserve transparency of source image
	rgba_out.a *= rgba_in.a;
	// apply transparency to chat window center
	rgba_out.a *= 1.0 - center_transparency * max(0.0, rgba_in.r);
	COLOR = vec4(rgba_out.rgb, rgba_out.a);
}