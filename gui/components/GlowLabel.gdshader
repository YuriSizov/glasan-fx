shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"

uniform vec2 direction = vec2(1.0, 0.0);
uniform float intensity = 1.000000;


void fragment() {
	vec4 base_color = COLOR;
	float blurred_color = blur_alpha(TEXTURE, UV, direction, intensity);

	COLOR.a = base_color.a + blurred_color;
}
