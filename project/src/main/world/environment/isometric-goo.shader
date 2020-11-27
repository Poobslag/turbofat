/*
 * A shader which generates a flowing goo pattern with swirls in it. When squashed vertically, this goo pattern is
 * suitable as an isometric texture.
 */
shader_type canvas_item;

// the background color for most of the canvas
uniform vec4 base_color : hint_color;

// the color used for goopy swirls
uniform vec4 wave_color : hint_color;

// offset to move the goo pattern around
uniform vec2 offset = vec2(0.0, 0.0);

// squash factor to apply an isometric effect, or to maintain the goo's aspect ratio
uniform vec2 squash_factor = vec2(1.0, 1.0);

// speed at which the goo texture stretches and distorts
const float DISTORTION_SPEED = 0.0200;

// speed at which the goo texture scrolls past
const float SCROLL_SPEED = 0.0040;

// speed at which the goo texture expands
const float CYCLE_SPEED = 0.0120;

vec2 hash22(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float perlin_noise(vec2 p) {
	vec2 pi = floor(p);
	vec2 pf = p - pi;
	
	vec2 w = pf * pf * (3.0 - 2.0 * pf);
	
	float f00 = dot(hash22(pi + vec2(0.0, 0.0)), pf - vec2(0.0, 0.0));
	float f01 = dot(hash22(pi + vec2(0.0, 1.0)), pf - vec2(0.0, 1.0));
	float f10 = dot(hash22(pi + vec2(1.0, 0.0)), pf - vec2(1.0, 0.0));
	float f11 = dot(hash22(pi + vec2(1.0, 1.0)), pf - vec2(1.0, 1.0));
	
	float xm1 = mix(f00, f10, w.x);
	float xm2 = mix(f01, f11, w.x);
	
	return mix(xm1, xm2, w.y);
}

void fragment() {
	vec2 uv1 = UV - offset;
	
	// Squash the coordinates vertically to match the isometric aspect ratio
	uv1 *= squash_factor;
	
	// Offset the distortion noise from the color noise
	uv1 += vec2(38.913, 81.975);
	uv1 += TIME * SCROLL_SPEED;
	
	vec2 uv2 = UV - offset;
	uv2 += perlin_noise(4.8 * uv1);
	uv2 += vec2(TIME * DISTORTION_SPEED, 0.0);
	
	// calculate a number evenly distributed in the range [0.0, 1.0) based on perlin noise
	float f = perlin_noise(0.3 * uv2);
	f = (f + TIME * CYCLE_SPEED) * 8.0;
	f = f - floor(f);
	
	// stepify the number into a wave_amount; when wave_amount is near 1.0 we mix in the wave_color
	float wave_amount = min(smoothstep(0.25, 0.26, f), 1.0 - smoothstep(0.45, 0.50, f));
	COLOR = mix(base_color, wave_color, wave_amount);
}
