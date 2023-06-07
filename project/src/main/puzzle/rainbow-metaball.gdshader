shader_type canvas_item;
render_mode blend_mix;
/**
 * A shader which generates 'rainbow metaballs', organic-looking blobby objects with a rainbow texture
 *
 * This shader is applied to a fuzzy texture with alpha values ranging from [0.0, 1.0]. It pushes the alpha values out
 * to the extremes, resulting in big blobby areas where the blurry alpha values exceeded a certain threshold.
 */

// speed at which the rainbow pattern stretches and distorts
const float DISTORTION_SPEED = 0.200;

// speed at which the rainbow pattern scrolls past
const float SCROLL_SPEED = 0.040;

// speed at which the rainbow pattern cycles its hues
const float CYCLE_SPEED = 0.240;

uniform sampler2D noise : repeat_enable;

// Smooth HSV to RGB conversion by Inigo Quilez (https://www.shadertoy.com/view/MsS3Wc)
vec3 hsv2rgb_smooth(in vec3 c) {
	vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	rgb = rgb * rgb * (3.0 - 2.0 * rgb);
	return c.z * mix(vec3(1.0), rgb, c.y);
}

float get_noise_2d(in vec2 p) {
	return textureLod(noise, p * 0.125, 2.0).x;
}

// Snaps a hue value to a standard set of hues
float stepify_hue(in float f_in) {
	float f = fract(f_in);
	float f_out = 0.02;
	f_out += 0.08 * smoothstep(0.08, 0.12, f);
	f_out += 0.08 * smoothstep(0.21, 0.25, f);
	f_out += 0.06 * smoothstep(0.33, 0.37, f);
	f_out += 0.23 * smoothstep(0.46, 0.50, f);
	f_out += 0.08 * smoothstep(0.58, 0.62, f);
	f_out += 0.12 * smoothstep(0.71, 0.75, f);
	f_out += 0.12 * smoothstep(0.83, 0.87, f);
	f_out += 0.23 * smoothstep(0.96, 1.00, f);
	return f_out;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	vec2 uv2 = UV + get_noise_2d(0.6 * vec2(UV.x + 38.913 + TIME * 0.010, UV.y + 81.975 + TIME * DISTORTION_SPEED));
	uv2 = uv2 + vec2(TIME * SCROLL_SPEED, 0.0);
	
	float f = get_noise_2d(2.0 * uv2);
	f = (f + TIME * CYCLE_SPEED) * 2.0;
	f = stepify_hue(f);
	
	color.rgb = hsv2rgb_smooth(vec3(f, 1.0, 1.0));
	
	color.a = smoothstep(0.76, 0.80, color.a);
	COLOR = color;
}
