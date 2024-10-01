shader_type canvas_item;
/**
 * Decorates a button with a rainbow effect with scrolling and wobbling.
 *
 * This shader is designed to apply to a button with a black border and white center. It generates a dynamic rainbow
 * gradient that scrolls across the white part of the button, applying the specified border color to the black part of
 * the button.
 */

// The size of the node this shader is applied to
uniform vec2 node_size = vec2(100, 100);

// The base angle for the wobble effect
uniform float angle = 0.0;

// Speed of the scroll
uniform float speed = 6.0;

// The minimum rgb value of the rainbow. A bright color results in a pale rainbow, a dark color results in a vibrant rainbow.
uniform vec4 rainbow_brightness : hint_color;

// The color of the border.
uniform vec4 border_color : hint_color;

// A center color which is drawn over top of the rainbow. Useful for applying tints when the button is pressed or focused.
uniform vec4 center_color : hint_color = vec4(1.0, 1.0, 1.0, 0.0);

void fragment() {
	// Get the UV coordinates and center them around the node's center
	vec2 uv = UV * node_size - node_size / 2.0;

	// Rotate and apply a wobble effect
	float angle_wobble = angle + 10.0 * sin(speed * TIME / 24.0);
	uv = uv * mat2(vec2(cos(radians(-angle_wobble)), -sin(radians(-angle_wobble))), vec2(sin(radians(-angle_wobble)), cos(radians(-angle_wobble))));

	// Scroll the rainbow left
	uv.x += TIME * speed;

	// Generate a rainbow color based on the uv.x coordinate
	vec3 rainbow_color;
	rainbow_color.r = rainbow_brightness.r + (1.0 - rainbow_brightness.r) * sin(uv.x / 10.0 + 0.0);
	rainbow_color.g = rainbow_brightness.g + (1.0 - rainbow_brightness.g) * sin(uv.x / 10.0 + 2.0);
	rainbow_color.b = rainbow_brightness.b + (1.0 - rainbow_brightness.b) * sin(uv.x / 10.0 + 4.0);

	// combine it with the button's rgb
	COLOR = mix(border_color, vec4(rainbow_color, 1.0), COLOR.r);

	// Apply the center color tint
	COLOR.rgb = mix(COLOR.rgb, center_color.rgb, center_color.a);
}