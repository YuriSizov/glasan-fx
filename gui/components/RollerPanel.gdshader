shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"


void fragment() {
	vec2 uv = (UV - 0.5) * 2.0;
	vec3 output_color = COLOR.rgb;
	float output_alpha = 1.0;
	
	// Generate a bevel mask.
	float bevel_dist = polygon_distance(4, uv);
	float bevel_mask = (1.0 - bevel_dist * length(uv) / 0.99) / 0.02;
	bevel_mask = 1.0 - clamp(bevel_mask, 0.0, 1.0);
	// Add the bevel to the color output.
	output_color = overlay(output_color, vec3(0.05), 1.0, bevel_mask);
	
	// Generate a light mask.
	float light_mask = 1.0 - (UV.x + UV.y) / 2.0;
	light_mask = smoothstep(0.49, 0.51, light_mask);
	light_mask = clamp(light_mask * bevel_mask, 0.0, 1.0);
	// Add the light mask to the color output.
	output_color = overlay(output_color, vec3(1.0), 0.34, light_mask);
	
	// Add a tiny bit of rounding for corners using vignetting. Values are hand-picked.
	output_alpha = vignette(vec3(1.0), vec3(0.0), 10000.0, 0.08, 20.0, UV).r;
	
	COLOR = vec4(output_color, output_alpha);
}
