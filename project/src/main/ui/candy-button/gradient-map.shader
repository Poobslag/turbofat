shader_type canvas_item;
render_mode unshaded;
/**
 * Applies a gradient map to a texture. Obtained from GDQuest's Gradient Map tutorial, 2024-05-14
 *
 * https://www.gdquest.com/tutorial/godot/shaders/gradient-map/
 */

// Gradient used in the mapping; light and dark tones are mapped to colors in this gradient.
uniform sampler2D gradient: hint_black;

uniform float mix_amount = 1.0;

void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	float greyscale_value = dot(input_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 sampled_color = texture(gradient, vec2(greyscale_value, 0.0)).rgb;

	COLOR.rgb = mix(input_color.rgb, sampled_color, mix_amount);
	COLOR.a = input_color.a;
}