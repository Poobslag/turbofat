shader_type canvas_item;
/**
 * Paints the opaque parts of the texture with a flat color.
 */

// the color to paint over the texture
uniform vec4 mix_color: source_color = vec4(1.0, 1.0, 1.0, 0.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, mix_color.rgb, mix_color.a);
	COLOR = color;
}