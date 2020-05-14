shader_type canvas_item;
render_mode blend_mix;
/**
 * Shader which generates 'metaballs', organic-looking blobby objects
 *
 * This shader is applied to a fuzzy texture with alpha values ranging from [0.0, 1.0]. It pushes the alpha values out
 * to the extremes, resulting in big blobby areas where the blurry alpha values exceeded a certain threshold.
 */

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	// Embiggen rgb values of translucent pixels. For some reason translucent pixels have smaller RGB values when
	// they're given to us. For example, a translucent white pixel will have a red value of 0.25 instead of 1.00.
	color.rgb /= max(color.a, 0.01);
	
	color.a = smoothstep(0.76, 0.80, color.a);
	COLOR = color;
}
