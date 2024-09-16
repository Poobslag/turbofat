shader_type canvas_item;
/**
 * Gradually scrolls a texture in a single direction.
 */

// The texture's scale. A value of (2.0, 1.0) makes the texture twice as wide.
uniform vec2 texture_scale = vec2(1.0, 1.0);

// The texture's scrolling velocity measured in full scrolls per minute. A value of (2.0, 0.0) scrolls the texture
// right twice per minute.
uniform vec2 scroll_velocity = vec2(1.0, 1.0);

void fragment() {
    vec2 newuv = UV / texture_scale;
    newuv += TIME * scroll_velocity * vec2(-0.01667, -0.01667);
    COLOR = texture(TEXTURE, newuv);
}
