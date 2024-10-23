shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"

uniform vec3 base_color: source_color = vec3(0.0);

uniform float switch_position: hint_range(-1.0, 1.0) = 0.0;
uniform float switch_position_safezone: hint_range(0.0, 1.0) = 0.0;
uniform vec3 switch_color: source_color = vec3(1.0);

uniform float width_factor = 3.0;
uniform float width_reducer: hint_range(0.0, 1.0) = 0.85;
uniform float thickness_base: hint_range(0.0, 1.0) = 0.5;
uniform float thickness_smoothness: hint_range(0.0, 0.5) = 0.1;

uniform float vignette_center: hint_range(1.0, 300.0) = 15.0;
uniform float vignette_rim: hint_range(0.0, 8.0) = 0.5;
uniform float vignette_intensity: hint_range(0.0, 1.0) = 0.0;


void fragment() {
	vec2 uv = (UV - 0.5) * 2.0;
	vec3 output_color = base_color;
	float output_alpha = 1.0;
	
	// Create a vignette/shadow overlay. Adding it before the main element makes it pop more.
	vec2 vignette_uv = UV * (1.0 - UV.yx);
	float vignette_value = clamp(pow(vignette_uv.x * vignette_uv.y * vignette_center, vignette_rim), 0.0, 1.0);
	// Add the vignette overlay to the output color.
	output_color = overlay(output_color, vec3(0.075), (1.0 - vignette_value), vignette_intensity);

	// Create UV for the flip switch.
	vec2 switch_uv = uv;
	switch_uv.x = pow(abs(switch_uv.x), width_factor) * width_reducer;
	// Apply the positional shift to the flip switch.
	float position_normalized = (switch_position * (1.0 - switch_position_safezone) + 1.0) / 2.0;
	float position_top = 1.0 - smoothstep(0.0, position_normalized, UV.y);
	float position_bottom = smoothstep(position_normalized, 1.0, UV.y);
	switch_uv.y = clamp(position_top + position_bottom, 0.0, 0.5);
	switch_uv.y += step(0.1, switch_uv.y) * 0.07;
	
	// Create the switch mask.
	float switch_mask = 1.0 - polygon_distance(4, switch_uv) * length(switch_uv);
	switch_mask = smoothstep(0.0, 0.99, switch_mask);
	switch_mask = pow(switch_mask, 1.4);
	// Add an extra focus on the top part.
	float switch_top = 1.0 - length(switch_uv);
	switch_top = smoothstep(thickness_base - thickness_smoothness, thickness_base + thickness_smoothness, switch_top);
	switch_mask = pow(switch_top, 8.0) + switch_mask;
	switch_mask = clamp(switch_mask, 0.0, 1.0);
	// Add the switch to the output color.
	output_color = overlay(output_color, switch_color, switch_mask, switch_mask);
	
	// Add a tiny bit of rounding for corners using vignetting. Values are hand-picked.
	output_alpha = vignette(vec3(1.0), vec3(0.0), 10000.0, 0.01, 100.0, UV).r;
	
	// Output.
	COLOR = vec4(output_color, output_alpha);
}
