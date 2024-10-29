shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"

uniform vec2 control_size;
uniform float position: hint_range(-1.0, 1.0) = 0.0;
uniform float deadzone: hint_range(0.0, 1.0) = 0.0;

group_uniforms knob;
uniform float knob_size: hint_range(0.0, 4.0) = 1.0;
uniform float knob_smoothness: hint_range(0.0, 1.0) = 0.2;
uniform vec3 knob_color: source_color = vec3(1.0);

group_uniforms knob_blob;
uniform float knob_blob_intensity: hint_range(0.0, 1.0) = 1.0;
uniform float knob_blob_intensity_range: hint_range(0.0, 1.0) = 0.1;
uniform vec3 knob_blob_color: source_color = vec3(1.0);

group_uniforms knob_shade;
uniform float knob_shade_size: hint_range(0.0, 4.0) = 0.5;
uniform float knob_shade_offset: hint_range(0.0, 2.0) = 0.1;
uniform float knob_shade_smoothness: hint_range(0.0, 1.0) = 0.2;
uniform float knob_shade_intensity: hint_range(0.0, 1.0) = 1.0;
uniform vec3 knob_shade_color: source_color = vec3(0.0);

group_uniforms stem;
uniform float stem_size: hint_range(0.0, 4.0) = 1.0;
uniform float stem_smoothness: hint_range(0.0, 1.0) = 0.2;
uniform vec3 stem_color: source_color = vec3(1.0);

group_uniforms stem_shade;
uniform float stem_shade_size: hint_range(0.0, 4.0) = 0.5;
uniform float stem_shade_smoothness: hint_range(0.0, 1.0) = 0.2;
uniform float stem_shade_intensity: hint_range(0.0, 1.0) = 1.0;
uniform vec3 stem_shade_color: source_color = vec3(0.0);

group_uniforms rim;
uniform float rim_size: hint_range(0.0, 4.0) = 1.0;
uniform float rim_thickness: hint_range(0.0, 1.0) = 0.2;
uniform float rim_smoothness: hint_range(0.0, 1.0) = 0.2;
uniform vec3 rim_color: source_color = vec3(1.0);

group_uniforms rim_shade;
uniform float rim_shade_size: hint_range(0.0, 4.0) = 0.5;
uniform float rim_shade_offset: hint_range(0.0, 2.0) = 0.1;
uniform float rim_shade_thickness: hint_range(0.0, 1.0) = 0.2;
uniform float rim_shade_smoothness: hint_range(0.0, 1.0) = 0.2;
uniform float rim_shade_intensity: hint_range(0.0, 1.0) = 1.0;
uniform float rim_knob_shade_intensity: hint_range(0.0, 1.0) = 1.0;
uniform vec3 rim_shade_color: source_color = vec3(0.0);

group_uniforms rim_glow;
uniform float rim_glow_intensity: hint_range(0.0, 1.0) = 1.0;


void fragment() {
	float ar = control_size.x / control_size.y;
	vec2 uv = (UV - 0.5) * 2.0;
	uv.y /= ar;
	vec3 output_color = COLOR.rgb;
	float output_alpha = 0.0;

	float position_distance = position * (1.0 - deadzone);
	float position_side = step(0.5, 1.0 + sign(position) * uv.y - 0.5);

	// Create the knob shape.
	vec2 knob_uv = uv;
	knob_uv.y -= position_distance;
	float knob_mask = length(knob_uv);
	knob_mask = 0.0 - knob_mask + knob_size;
	knob_mask = smoothstep(0.0, knob_smoothness, knob_mask);
	
	// Create a shadow blob for the knob.
	float knob_shadow_offset = -0.4 + 0.2 * abs(position - 0.3);
	float knob_shadow_blob = length(knob_uv + vec2(0.0, knob_shadow_offset));
	knob_shadow_blob = 0.0 - knob_shadow_blob + knob_size - 0.04;
	knob_shadow_blob = smoothstep(0.0, knob_smoothness + 0.07, knob_shadow_blob);
	// Add the shadow blob to the output.
	float knob_shadow_blob_factor = knob_blob_intensity + knob_blob_intensity_range * abs(position);
	output_color = overlay(output_color, knob_blob_color, knob_shadow_blob_factor, knob_shadow_blob);
	output_alpha += knob_shadow_blob * knob_shadow_blob_factor;
	
	// Create shading for the knob.
	vec2 knob_shade_uv = knob_uv;
	knob_shade_uv.y += knob_shade_offset * (1.5 + 0.2 * (position));
	float knob_shade = length(knob_shade_uv);
	knob_shade = knob_shade - knob_shade_size;
	knob_shade = smoothstep(0.0, knob_shade_smoothness, knob_shade);
	// Mix the knob color with shading.
	vec3 knob_output = overlay(knob_color, knob_shade_color, knob_shade_intensity, knob_shade);
	
	// Add the knob to the output.
	output_color = overlay(output_color, knob_output, knob_mask, knob_mask);
	output_alpha += knob_mask;
	
	// Create the stem shape.
	vec2 stem_uv = uv;
	stem_uv.y = abs(stem_uv.y - position_distance / 2.0) - abs(position_distance / 2.0);
	stem_uv.y = clamp(stem_uv.y, 0.0, 1.0);
	//
	vec2 stem_mask_uv = abs(stem_uv);
	stem_mask_uv.x += stem_smoothness - stem_size;
	stem_mask_uv.y -= (1.0 - length(stem_uv)) - 2.0 * stem_size;
	stem_mask_uv = smoothstep(0.0, stem_smoothness, stem_mask_uv);
	stem_mask_uv = 1.0 - stem_mask_uv;
	float stem_mask = stem_mask_uv.x * stem_mask_uv.y;
	stem_mask -= knob_mask;
	stem_mask = clamp(stem_mask, 0.0, 1.0);
	// Create shading for the stem.
	vec2 stem_shade_uv = stem_uv;
	stem_shade_uv.y += 0.1 * abs(position);
	stem_shade_uv.x *= 2.0 + 0.3 * abs(position);
	float stem_shade = length(stem_shade_uv);
	stem_shade = stem_shade - stem_shade_size;
	stem_shade = smoothstep(0.0, stem_shade_smoothness, stem_shade);
	// Mix the stem color with shading.
	vec3 stem_output = overlay(stem_color, stem_shade_color, stem_shade_intensity, stem_shade);
	// Add the shadow blob shade to the stem.
	stem_output = overlay(stem_output, stem_shade_color, stem_shade_intensity, knob_shadow_blob);
	
	// Add the stem to the output.
	output_color = overlay(output_color, stem_output, stem_mask, stem_mask);
	output_alpha += stem_mask;
	
	// Create the rim shape.
	vec2 rim_uv = uv;
	float rim_outer_mask = length(rim_uv);
	rim_outer_mask = 0.0 - rim_outer_mask + rim_size;
	rim_outer_mask = smoothstep(0.0, rim_smoothness, rim_outer_mask);
	float rim_inner_mask = length(rim_uv);
	rim_inner_mask = 0.0 - rim_inner_mask + rim_size - rim_thickness;
	rim_inner_mask = smoothstep(0.0, rim_smoothness, rim_inner_mask);
	//
	float rim_mask = rim_outer_mask - rim_inner_mask;
	rim_mask -= knob_mask + stem_mask * position_side; // Only in half.
	rim_mask = clamp(rim_mask, 0.0, 1.0);
	// Create shading for the rim.
	vec2 rim_shade_uv = rim_uv;
	rim_shade_uv.y += rim_shade_offset;
	float rim_inner_shade = length(rim_shade_uv);
	rim_inner_shade = rim_inner_shade - rim_shade_size;
	rim_inner_shade = smoothstep(0.0, rim_shade_smoothness, rim_inner_shade);
	float rim_outer_shade = length(rim_shade_uv);
	rim_outer_shade = rim_outer_shade - rim_shade_size - rim_shade_thickness;
	rim_outer_shade = smoothstep(0.0, rim_shade_smoothness, rim_outer_shade);
	float rim_shade = 1.0 - clamp(rim_inner_shade - rim_outer_shade, 0.0, 1.0);
	// Mix the rim color with shading.
	vec3 rim_output = overlay(rim_color, rim_shade_color, rim_shade_intensity, rim_shade);
	// Add the shadow blob to the rim.
	rim_output = overlay(rim_output, rim_shade_color, rim_knob_shade_intensity, knob_shadow_blob);

	// Add an extra glow on the stem from the rim.
	float stem_rim_glow = length(rim_shade_uv - sign(position) * vec2(0, 0.13));
	stem_rim_glow = stem_rim_glow - rim_shade_size;
	stem_rim_glow = smoothstep(0.0, rim_shade_smoothness, stem_rim_glow);
	stem_rim_glow *= 1.0 - position_side; // Only in half.
	stem_rim_glow = stem_mask * stem_rim_glow;
	stem_rim_glow = clamp(stem_rim_glow, 0.0, 1.0);
	output_color = overlay(output_color, rim_color, rim_glow_intensity, stem_rim_glow);

	// Add an extra shade on the stem from the rim.
	float stem_rim_shade = length(rim_shade_uv);
	stem_rim_shade = stem_rim_shade - rim_shade_size + 0.05;
	stem_rim_shade = smoothstep(0.0, rim_shade_smoothness, stem_rim_shade);
	stem_rim_shade *= 1.0 - position_side; // Only in half.
	stem_rim_shade = stem_mask * stem_rim_shade;
	stem_rim_shade = clamp(stem_rim_shade, 0.0, 1.0);
	output_color = overlay(output_color, stem_shade_color, stem_shade_intensity, stem_rim_shade);

	// Add the rim to the output.
	output_color = overlay(output_color, rim_output, rim_mask, rim_mask);
	output_alpha += rim_mask;


	// Output.
	COLOR = vec4(output_color, output_alpha);
}
