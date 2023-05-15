/*
 * Renders a greyscale image as a single-color mask with an alpha component.
 *
 * Used to black out the screen during scene transitions.
 */
shader_type canvas_item;
render_mode unshaded;

// The red value which defines the cutoff for what's opaque
uniform float cutoff : hint_range(0.0, 1.0);

// How much of the image should be translucent, instead of pure opaque/transparent.
// 0.0 = extreme alpha values; 1.0 = middling alpha values;
uniform float smooth_size : hint_range(0.0, 1.0);

// How much the image should fade instead of respecting the mask
// 0.0 = only respect the mask; 1.0 = only fade
uniform float harshness : hint_range(0.0, 1.0);

// Whether values over the cutoff should be opaque or transparent
// false = low values are opaque; true = high values are opaque
uniform bool invert = false;

void fragment()
{
	// calculate the mask alpha
	float fade_alpha = smoothstep(
		cutoff + (invert ? 0.0 : smooth_size), 
		cutoff + (invert ? smooth_size : 0.0), 
		mix(smooth_size, 1.0 - smooth_size, texture(TEXTURE, UV).r));
	
	// apply the 'harshness' value to make the mask effect less jarring
	float approx_target = invert ? 1.0 - cutoff : cutoff;
	fade_alpha = clamp(fade_alpha, max(0.0, approx_target - harshness), min(1.0, approx_target + harshness));
	
	COLOR = vec4(1.0, 1.0, 1.0, fade_alpha);
}