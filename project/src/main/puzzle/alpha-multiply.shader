shader_type canvas_item;
render_mode blend_mul;
/**
 * Textures drawn using 'multiply mode' do not work with alpha transparency; transparent pixels are treated as black.
 *
 * This shader works around the issue by modulating opaque pixels, and mixing transparent pixels with white.
 */

// Color used to modulate the opaque parts of the texture
uniform vec4 mix_color: hint_color = vec4(1.0, 1.0, 1.0, 0.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, mix_color.rgb, color.a * mix_color.a);
	COLOR = color;
}