// Based on https://github.com/ttencate/blur_godot4/blob/0517d1159b088a272300b083ae98376d9d77ffea/Blur.gdshader.
shader_type canvas_item;

uniform vec2 direction = vec2(1.0, 0.0);
uniform float intensity = 1.000000;

vec4 fetch(sampler2D source, vec2 uv) {
	vec4 base_color = texture(source, uv);
	return vec4(1.0) * base_color.a + vec4(0.0) * (1.0 - base_color.a);
}

void fragment() {
	vec4 base_color = COLOR;
	vec2 s = intensity * direction / vec2(textureSize(TEXTURE, 0));
	
	vec4 blurred =
		intensity * 0.011194727 * fetch(TEXTURE, UV - 10.000000000 * s) +
		intensity * 0.039368696 * fetch(TEXTURE, UV - 8.415809477 * s) +
		intensity * 0.071308558 * fetch(TEXTURE, UV - 6.435363708 * s) +
		intensity * 0.110237219 * fetch(TEXTURE, UV - 4.455121108 * s) +
		intensity * 0.145451038 * fetch(TEXTURE, UV - 2.475020813 * s) +
		intensity * 0.163798995 * fetch(TEXTURE, UV - 0.495000167 * s) +
		intensity * 0.157439298 * fetch(TEXTURE, UV + 1.485004498 * s) +
		intensity * 0.129158204 * fetch(TEXTURE, UV + 3.465057055 * s) +
		intensity * 0.090434685 * fetch(TEXTURE, UV + 5.445220765 * s) +
		intensity * 0.054043977 * fetch(TEXTURE, UV + 7.425557483 * s) +
		intensity * 0.027564604 * fetch(TEXTURE, UV + 9.406126897 * s);
	
	COLOR = base_color + blurred;
}
