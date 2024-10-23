shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"

uniform vec2 slider_size = vec2(1.0, 1.0);
uniform float knob_position: hint_range(-1.0, 1.0) = 0.0;

uniform float rail_safezone: hint_range(0.0, 1.0) = 0.5;
uniform float rail_thickness: hint_range(0.0, 1.0) = 0.5;
uniform float rail_smoothness: hint_range(0.01, 1.0) = 0.1;

uniform float knob_scale: hint_range(0.0, 5.0) = 1.0;
uniform float knob_width: hint_range(0.01, 5.0) = 0.75;
uniform vec3 knob_color: source_color = vec3(1.0);
uniform vec3 knob_dark_color: source_color = vec3(0.0);

uniform vec4 knob_light_color: source_color = vec4(1.0);
uniform float knob_light_smoothness: hint_range(0.0, 1.0) = 0.1;


void fragment() {
	float aspect_ratio = slider_size.x / slider_size.y;
	vec3 output_color = COLOR.rgb;
	float output_alpha = 0.0;
	
	// Create a mask for the slider rail.
	vec2 rail_uv = 1.0 - abs(UV - 0.5) * 2.0;
	float rail_mask = rail_uv.y;
	rail_mask = rail_mask - (1.0 - rail_thickness);
	rail_mask = smoothstep(0.0, rail_smoothness, rail_mask);
	// Apply the same smoothing on the sides, adjusted for the AR.
	rail_mask *= smoothstep(0.0, rail_smoothness / aspect_ratio, rail_uv.x - rail_safezone / aspect_ratio);
	rail_mask = clamp(rail_mask, 0.0, 1.0);
	// Add the slider rail to the output.
	output_color = overlay(output_color, vec3(0.0), rail_mask, rail_mask);
	output_alpha += rail_mask;

	// Create a mask for the slider knob.
	vec2 knob_uv = (UV - 0.5) * 2.0 * knob_scale;
	knob_uv.x -= knob_position * (1.0 - rail_safezone * 2.0 / aspect_ratio) * knob_scale;
	knob_uv.x *= aspect_ratio / knob_width;
	//
	float knob_dist = polygon_distance(4, knob_uv);
	float knob_mask = (1.0 - knob_dist * length(knob_uv) / 0.99) / 0.02;
	knob_mask = clamp(knob_mask, 0.0, 1.0);
	// Create a color for the slider knob.
	float knob_output_mask = (1.0 - knob_dist * length(knob_uv) / 0.99) / 0.6;
	knob_output_mask *= (2.0 - abs(knob_uv.x)) * 0.7;
	//
	float knob_finger_shadow = 1.0 - abs(knob_uv.x);
	knob_finger_shadow = pow(knob_finger_shadow, 0.2) - 0.7;
	knob_output_mask = clamp(knob_output_mask, 0.0, 1.0);
	knob_output_mask *= (1.0 - knob_finger_shadow);
	vec3 knob_output = knob_color * knob_output_mask + knob_dark_color * (1.0 - knob_output_mask);
	
	// Add the slider knob to the output.
	output_color = overlay(output_color, knob_output, knob_mask, knob_mask);
	output_alpha += knob_mask;
	
	// Prepare the light/shade mask.
	float light_mask = 1.0 - smoothstep(0.0, knob_light_smoothness, knob_uv.y + knob_uv.x + knob_light_smoothness / 2.0);
	light_mask *= knob_mask;
	float light_mask_submask = pow(knob_output_mask, 4.0) * 3.0;
	light_mask = colorize_mask(light_mask_submask, 0.0, light_mask);
	light_mask = clamp(light_mask, 0.0, 1.0);
	// Apply the light/shade mask to the final color.
	output_color = overlay(output_color, knob_light_color.rgb, knob_light_color.a, light_mask);
	
	// Output.
	COLOR = vec4(output_color, output_alpha);
}
