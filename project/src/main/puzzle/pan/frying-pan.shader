shader_type canvas_item;
/*
 * Recolors and draws an outline around a frying pan.
 */

const float TAU = 6.28318530718;

// the outline width
uniform float width: hint_range(0.0, 128.0);

// the color to use when drawing the sprite
uniform vec4 white: hint_color;

// the color to use when drawing the outline
uniform vec4 black: hint_color;

// To draw the outline, we sample pixels in a circle around the current pixel. This value correspond to the number of
// sampled pixels. Higher values are slower but result in a smoother outline.
uniform int sample_count = 24;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * width;
	float sprite_alpha = texture(TEXTURE, UV).a;
	float final_alpha = sprite_alpha;

	// we go around in a circle, sampling the texture in each direction.
	// if we find an opaque section we set our alpha to 1.0 and break out of the loop
	for (float a = 0.0; a <= TAU && final_alpha < 1.0; a += TAU / float(sample_count)) {
		final_alpha = max(final_alpha, texture(TEXTURE, UV + vec2(sin(a) * size.x, cos(a) * size.y)).a);
	}
	
	vec3 final_color = mix(black.rgb, white.rgb, sprite_alpha);
	COLOR = vec4(final_color, final_alpha);
}
