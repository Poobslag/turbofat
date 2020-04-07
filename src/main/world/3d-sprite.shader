shader_type spatial;
/*
 * Draws a 3D sprite with an outline.
 *
 * This is not used for drawing an outline around a 3D object like a cube or a sphere, but for drawing a 2D sprite as
 * a 3D object with an outline.
 */

render_mode unshaded;

uniform float outline_width: hint_range(0.0, 16.0);
uniform vec4 outline_color : hint_color;

// The texture to render
uniform sampler2D albedo_texture: hint_albedo;

// The offset to apply when rendering the texture to the 3D object
uniform vec2 texture_offset;

varying vec2 vertex_position;

void vertex() {
	vertex_position = VERTEX.xz / 2.0;
}

void fragment() {
	vec2 texture_xy = (vertex_position + vec2(1.0, 1.0)) * 0.5 + texture_offset / vec2(textureSize(albedo_texture, 0));
	vec4 sprite_color = texture(albedo_texture, texture_xy);

	float alpha = sprite_color.a;
	vec2 tickle = 2.0 * outline_width / vec2(textureSize(albedo_texture, 0));

	// cardinal directions
	alpha = max(alpha, texture(albedo_texture, texture_xy + vec2(0.0, -tickle.y)).a);
	alpha = max(alpha, texture(albedo_texture, texture_xy + vec2(tickle.x, 0.0)).a);
	alpha = max(alpha, texture(albedo_texture, texture_xy + vec2(0.0, tickle.y)).a);
	alpha = max(alpha, texture(albedo_texture, texture_xy + vec2(-tickle.x, 0.0)).a);

	// diagonal directions; divide by sqrt(2)
	alpha = max(alpha, texture(albedo_texture, texture_xy + vec2(tickle.x * 0.7071, -tickle.y * 0.7071)).a);
	alpha = max(alpha, texture(albedo_texture, texture_xy + vec2(tickle.x * 0.7071, tickle.y * 0.7071)).a);
	alpha = max(alpha, texture(albedo_texture, texture_xy + vec2(-tickle.x * 0.7071, tickle.y * 0.7071)).a);
	alpha = max(alpha, texture(albedo_texture, texture_xy + vec2(-tickle.x * 0.7071, -tickle.y * 0.7071)).a);

	ALBEDO = mix(outline_color.rgb, sprite_color.rgb, sprite_color.a);
	ALPHA = alpha;
}
