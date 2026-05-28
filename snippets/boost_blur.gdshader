// Excerpt from DroneDash — fullscreen vertical motion blur.
// A compact 7-tap Gaussian on the screen texture, driven by a
// single blur_amount uniform that's tweened up during a boost.
// shader_type canvas_item, so it runs on a fullscreen ColorRect.

shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE;
	float r = 3.0 * blur_amount;
	vec3 acc = vec3(0.0);
	acc += texture(screen_tex, SCREEN_UV + vec2(0.0, -3.0 * r * px.y)).rgb * 1.0;
	acc += texture(screen_tex, SCREEN_UV + vec2(0.0, -2.0 * r * px.y)).rgb * 4.0;
	acc += texture(screen_tex, SCREEN_UV + vec2(0.0, -1.0 * r * px.y)).rgb * 8.0;
	acc += texture(screen_tex, SCREEN_UV                              ).rgb * 10.0;
	acc += texture(screen_tex, SCREEN_UV + vec2(0.0,  1.0 * r * px.y)).rgb * 8.0;
	acc += texture(screen_tex, SCREEN_UV + vec2(0.0,  2.0 * r * px.y)).rgb * 4.0;
	acc += texture(screen_tex, SCREEN_UV + vec2(0.0,  3.0 * r * px.y)).rgb * 1.0;
	COLOR = vec4(acc / 36.0, 1.0);
}
