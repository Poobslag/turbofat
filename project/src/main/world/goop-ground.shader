/*
 * A shader which takes an RGB image, and replaces the red and blue component with different textures, and the green
 * component with a flowing goop pattern. Black pixels are also replaced with a solid color.
 *
 * This approach allow a sprite to be recolored with up to four channels, and the recoloring can be handled by the
 * graphics card. It's performant and looks reasonable even if the sprite is resized before being passed off to the
 * graphics card.
 */
shader_type canvas_item;

// squash factor to apply an isometric effect
const vec2 SQUASH_FACTOR = vec2(0.5, 1.0);

// speed at which the goop texture stretches and distorts
const float DISTORTION_SPEED = 0.0100;

// speed at which the goop texture scrolls past
const float SCROLL_SPEED = 0.0080;

// speed at which the goop texture expands
const float CYCLE_SPEED = 0.0060;

// replacement textures for red and blue channels
uniform sampler2D red_texture;
uniform sampler2D blue_texture;

// noise texture used to render goop
uniform sampler2D noise_texture;

// replacement color for dark parts of the image (shadows)
uniform vec4 black : hint_color;

// the base color for the goop. most of the goop is the base color
uniform vec4 base_color : hint_color;

// the wave color for the goop. the goop has thin strips of this color
uniform vec4 wave_color : hint_color;

uniform mat4 view_to_local;

varying vec2 local;

// workaround for Godot #14904; builtin variables are not usable in shader functions
varying float time;

void vertex() {
	local = (view_to_local * WORLD_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	time = TIME;
}

// returns a number evenly distributed in the range [0.0, 1.0) based on simplex noise
float get_noise_2d(vec2 p) {
	return textureLod(noise_texture, p, 2.0).r;
}

vec4 goop_color() {
	vec2 uv0 = local * SQUASH_FACTOR / vec2(textureSize(noise_texture, 0));
	vec2 uv1 = uv0 + vec2(38.913, 81.975) + time * SCROLL_SPEED;
	vec2 uv2 = uv0 * vec2(4.0, 4.0) + get_noise_2d(1.2 * uv1) + vec2(time * DISTORTION_SPEED, 0.0);

	// calculate a number evenly distributed in the range [0.0, 1.0) based on noise
	float f = get_noise_2d(0.3 * uv2 / vec2(8.0, 8.0));
	f = fract((f + time * CYCLE_SPEED) * 8.0);

	// stepify the number into a wave_amount; when wave_amount is near 1.0 we mix in the wave_color
	float wave_amount = min(smoothstep(0.25, 0.26, f), 1.0 - smoothstep(0.35, 0.38, f));
	return mix(base_color, wave_color, wave_amount);
}

void fragment() {
	vec4 rgba_in = texture(TEXTURE, UV);
	
	vec4 red = texture(red_texture, local / vec2(textureSize(red_texture, 0)));
	vec4 green = goop_color();
	vec4 blue = texture(blue_texture, local / vec2(textureSize(blue_texture, 0)));
	
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