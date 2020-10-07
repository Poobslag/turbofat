shader_type canvas_item;
render_mode unshaded;
/**
 * A gradient map shader which translates light/dark tones to colors in a gradient.
 */

// Gradient used in the mapping; light and dark tones are mapped to colors in this gradient.
uniform sampler2D gradient: hint_black;

void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	COLOR = texture(gradient, vec2(input_color.r, 0.0));
}
