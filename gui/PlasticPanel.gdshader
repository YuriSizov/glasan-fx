shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"

uniform vec2 size = vec2(100.0, 100.0);

uniform float light_intensity: hint_range(0.0, 1.0) = 0.5;
uniform float light_smoothness: hint_range(0.0, 0.5) = 0.01;
uniform int light_inverted: hint_range(0, 1) = 0;

uniform int border_width: hint_range(0, 48) = 1;
uniform float border_smoothness: hint_range(0.0, 0.5) = 0.01;

uniform vec2 bolt_offset = vec2(11.0, 11.0);
uniform float bolt_scale = 10.0;
uniform float bolt_size: hint_range(0.0, 1.0) = 0.45;
uniform float bolt_smoothness: hint_range(0.0, 0.5) = 0.07;
uniform float bolt_thickness: hint_range(0.0, 1.0) = 0.2;
uniform float bolt_visibility: hint_range(0.0, 1.0) = 0.8;


void fragment() {
	float ar = size.x / size.y;
	vec2 uv = UV;
	
	vec3 output_color = COLOR.rgb;
	float output_alpha = 1.0;
	
	// Generate a border mask.
	float border_mask = 0.0;
	float fborder_width = float(border_width);
	// Add each side individually.
	border_mask += 1.0 - smoothstep(fborder_width - border_smoothness, fborder_width + border_smoothness, uv.x * size.x);
	border_mask += smoothstep((size.x - fborder_width) - border_smoothness, (size.x - fborder_width) + border_smoothness, uv.x * size.x);
	border_mask += 1.0 - smoothstep(fborder_width - border_smoothness, fborder_width + border_smoothness, uv.y * size.y);
	border_mask += smoothstep((size.y - fborder_width) - border_smoothness, (size.y - fborder_width) + border_smoothness, uv.y * size.y);
	border_mask = clamp(border_mask, 0.0, 1.0);
	
	// Generate a light mask. We only care about parts close to corners.
	float light_mask = (uv.x * ar + uv.y) / 2.0;
	// Align it to top-right and bottom-left, keeping the 45 degree angle at both points.
	float light_mix_factor = step(1.0, (uv.x + (1.0 - uv.y)));
	light_mask = mix(light_mask, light_mask - 0.5 * (ar - 1.0), light_mix_factor);
	light_mask = (1.0 - light_mask) * (1.0 - float(light_inverted)) + light_mask * float(light_inverted);
	light_mask = smoothstep(0.5 - light_smoothness, 0.5 + light_smoothness, light_mask);
	
	// Add the light overlay to the output color, using the border mask.
	output_color = overlay(output_color, vec3(light_mask), light_intensity, border_mask);
	
	// Generate a bolt mask in all 4 corners.
	vec2 bolt_point = size * (0.5 - abs(uv - 0.5)) - bolt_offset;
	float bolt_mask = clamp(length(bolt_point) / bolt_scale, 0.0, 1.0);
	// Create an outer and an inner ring.
	float bolt_ring_1 = 1.0 - smoothstep(bolt_size - bolt_smoothness, bolt_size + bolt_smoothness, bolt_mask);
	float bolt_ring_2 = 1.0 - smoothstep(bolt_size - bolt_thickness - bolt_smoothness, bolt_size - bolt_thickness + bolt_smoothness, bolt_mask);
	bolt_mask = clamp(bolt_ring_1 - 0.8 * bolt_ring_2, 0.0, 1.0);
	
	// Add bolts to the output color.
	output_color = overlay(output_color, vec3(0.98), bolt_visibility, bolt_mask);
	
	// Output.
	COLOR = vec4(output_color, output_alpha);
}
