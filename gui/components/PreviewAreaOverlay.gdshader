shader_type canvas_item;
render_mode unshaded;

#include "res://shaders/functions.gdshaderinc"

uniform vec2 blur_direction = vec2(0.0, 1.0);
uniform float blur_intensity = 1.000000;

uniform float glass_shine_offset: hint_range(-1.0, 1.0) = 0.0;
uniform float glass_shine_sharpness: hint_range(0.0, 0.5) = 0.01;
uniform float glass_shine_opaqueness: hint_range(0.0, 1.0) = 0.64;

uniform float vignette_center: hint_range(1.0, 300.0) = 15.0;
uniform float vignette_rim: hint_range(0.0, 8.0) = 0.5;
uniform float vignette_intensity: hint_range(0.0, 1.0) = 0.0;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec2 uv = UV;
	vec4 base_color = texture(screen_texture, SCREEN_UV);
	vec3 blurred_color = blur_color(screen_texture, SCREEN_UV, blur_direction, blur_intensity);

	vec3 output_color = base_color.rgb + blurred_color * 0.8;
	float output_alpha = 1.0;

	// Create a shiny overlay.
	float glass_shine = (uv.x + uv.y) / 2.0;
	float glass_shine_position = (glass_shine_offset + 1.0) / 2.0;
	glass_shine = smoothstep(glass_shine_position - glass_shine_sharpness, glass_shine_position + glass_shine_sharpness, glass_shine);
	glass_shine = (1.0 - glass_shine);
	
	// Apply the opaqueness factor.
	glass_shine *= glass_shine_opaqueness;
	// Add the shiny overlay to the output color.
	output_color = overlay(output_color, vec3(glass_shine), glass_shine, glass_shine);
	
	// Create a vignette/shadow overlay.
	vec2 vignette_uv = UV * (1.0 - UV.yx);
	float vignette_value = clamp(pow(vignette_uv.x * vignette_uv.y * vignette_center, vignette_rim), 0.0, 1.0);
	// Add the vignette overlay to the output color.
	output_color = overlay(output_color, vec3(0.075), (1.0 - vignette_value), vignette_intensity);

	// Add a tiny bit of rounding for corners using vignetting. Values are hand-picked.
	output_alpha = vignette(vec3(1.0), vec3(0.0), 100000.0, 0.04, 40.0, UV).r;

	// Output.
	COLOR = vec4(output_color, output_alpha);
}
