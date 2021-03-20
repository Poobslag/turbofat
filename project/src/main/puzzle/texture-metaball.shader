shader_type canvas_item;
render_mode blend_mix;
/**
 * Shader which overlays 'metaballs' and 'rainbow metaballs' onto an underlying texture.
 *
 * Metaballs are organic-looking blobby objects. This shader renders them onto a texture, ensuring only the opaque
 * pixels of the underlying texture are painted. This shader is applied to a fuzzy texture with alpha values ranging
 * from [0.0, 1.0]. It pushes the alpha values out to the extremes, resulting in big blobby areas where the blurry
 * alpha values exceeded a certain threshold.
 */

// speed at which the rainbow pattern stretches and distorts
const float DISTORTION_SPEED = 0.0400;

// speed at which the rainbow pattern scrolls past
const float SCROLL_SPEED = 0.0080;

// speed at which the rainbow pattern cycles its hues
const float CYCLE_SPEED = 0.0240;

uniform sampler2D noise;

// texture for flat-color metaballs
uniform sampler2D frosting_texture : hint_albedo;

// texture for rainbow metaballs
uniform sampler2D rainbow_texture : hint_albedo;

// an offset which is applied to both textures
uniform vec2 frosting_texture_offset;

// the maximum frosting opacity
uniform float frosting_alpha = 0.6;

// Smooth HSV to RGB conversion by Inigo Quilez (https://www.shadertoy.com/view/MsS3Wc)
vec3 hsv2rgb_smooth(in vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	rgb = rgb * rgb * (3.0 - 2.0 * rgb);
	return c.z * mix(vec3(1.0), rgb, c.y);
}

float perlin_noise(in vec2 p) {
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
	vec4 frosting_color = texture(frosting_texture, UV);
	vec4 rainbow_color = texture(rainbow_texture, UV);
	
	// Embiggen rgb values of translucent pixels. For some reason translucent pixels have smaller RGB values when
	// they're given to us. For example, a translucent white pixel will have a red value of 0.25 instead of 1.00.
	frosting_color.rgb /= max(frosting_color.a, 0.01);
	rainbow_color.rgb /= max(rainbow_color.a, 0.01);
	
	// calculate flat metaball color
	frosting_color.a = smoothstep(0.76, 0.80, frosting_color.a);
	
	// calculate rainbow metaball color
	vec2 uv2 = UV + perlin_noise(0.6 * vec2(UV.x + 38.913 + TIME * 0.010, UV.y + 81.975 + TIME * DISTORTION_SPEED));
	uv2 = uv2 + vec2(TIME * SCROLL_SPEED, 0.0);
	float f = perlin_noise(2.0 * uv2);
	f = (f + TIME * CYCLE_SPEED) * 2.0;
	f = stepify_hue(f);
	rainbow_color.rgb = hsv2rgb_smooth(vec3(f, 1.0, 1.0));
	rainbow_color.a = smoothstep(0.76, 0.80, rainbow_color.a);
	
	// mix the metaball colors
	frosting_color = mix(frosting_color, rainbow_color, rainbow_color.a);
	
	// apply the metaball colors to the underlying texture
	COLOR.rgb = mix(color.rgb, frosting_color.rgb, frosting_color.a * frosting_alpha);
	COLOR.a = color.a;
}
