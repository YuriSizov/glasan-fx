shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"

uniform float scroll: hint_range(-2.0, 2.0) = 0.0;
uniform vec3 base_color: source_color = vec3(1.0);

group_uniforms markings;
uniform float markings_frequency: hint_range(0.0, 50.0) = 10.0;
uniform float markings_spread: hint_range(0.0, 1.0) = 0.5;
uniform float markings_offset: hint_range(-2.0, 2.0) = 0.0;
uniform float markings_band: hint_range(0.0, 100.0) = 1.0;
uniform float markings_band_offset: hint_range(-1.0, 1.0) = 0.0;
uniform float markings_main_band: hint_range(0.0, 100.0) = 1.0;
uniform float markings_main_band_offset: hint_range(-1.0, 1.0) = 0.0;
uniform vec2 markings_band_sharpness = vec2(0.01, 0.02);
uniform vec3 markings_color: source_color = vec3(1.0);
uniform vec3 markings_main_color: source_color = vec3(1.0);

group_uniforms notches;
uniform float notches_frequency: hint_range(0.0, 30.0) = 10.0;
uniform float notches_scale: hint_range(0.1, 20.0) = 1.0;
uniform float notches_shine: hint_range(0.0, 4.0) = 0.2;
uniform float notches_brightness: hint_range(0.0, 4.0) = 1.0;
uniform float notches_band: hint_range(0.0, 100.0) = 1.0;
uniform vec2 notches_band_sharpness = vec2(0.01, 0.02);
uniform vec2 notches_limits_sharpness = vec2(0.1, 0.2);
uniform vec2 notches_shadow_sharpness = vec2(0.01, 0.1);
uniform vec3 notches_color: source_color = vec3(1.0);

group_uniforms wheel;
uniform float wheel_height: hint_range(-4.0, 4.0) = 0.0;
uniform float wheel_depth: hint_range(0.0, 1.0) = 0.1;
uniform vec2 wheel_depth_sharpness = vec2(0.2, 0.22);
uniform vec2 wheel_limits_sharpness = vec2(0.1, 0.12);
uniform float wheel_warp_power: hint_range(0.0, 10.0) = 2.0;
uniform float wheel_warp_factor: hint_range(0.0, 10.0) = 1.0;
uniform vec3 wheel_color: source_color = vec3(0.0);


float band(vec2 uv, int flip, float factor, vec2 sharpness) {
	float mask = clamp(float(flip) * 2.0 * uv.y, 0.0, 1.0);
	mask = 1.0 - 2.0 * abs(mask - 0.5);
	mask = pow(mask, factor);
	mask = smoothstep(sharpness.x, sharpness.y, mask);
	
	return mask;
}

float band_oneside(vec2 uv, int flip, float factor, vec2 sharpness) {
	float mask = clamp(float(flip) * 2.0 * uv.y, 0.0, 1.0);
	mask = 1.0 - 2.0 * (mask - 0.5);
	mask = pow(mask, factor);
	mask = smoothstep(sharpness.x, sharpness.y, mask);
	
	return mask;
}

void fragment() {
	vec2 uv = UV - 0.5;
	vec2 scrolled_uv = uv;
	scrolled_uv.x -= scroll;
	
	vec3 output_color = base_color;
	float output_alpha = 0.0;
	
	// Draw the markings.
	
	vec2 markings_uv = uv + vec2(markings_offset, 0.0);
	// Create the base markings mask.
	float markings_mask = abs(markings_uv.x) * markings_frequency + 1.55;
	markings_mask = step(markings_spread, sin(markings_mask));
	// Create a band mask for the markings.
	float band_mask = band(markings_uv + markings_band_offset, -1, markings_band, markings_band_sharpness);
	markings_mask *= band_mask;
	
	// Add the markings to the output color.
	output_color = overlay(output_color, markings_color, markings_mask, markings_mask);
	output_alpha += markings_mask;

	// Create the main marking mask.
	float markings_main_mask = 1.0 - step(markings_spread / markings_frequency, abs(markings_uv.x));
	// Create a band mask for the main marking. It's the same as above, but a bit longer.
	float band_main_mask = band(markings_uv + markings_main_band_offset, -1, markings_main_band, markings_band_sharpness);
	markings_main_mask = clamp(markings_main_mask * band_main_mask, 0.0, 1.0);
	
	// Add the main marking to the output color.
	output_color = overlay(output_color, markings_main_color, markings_main_mask, markings_main_mask);
	output_alpha += markings_main_mask;
	
	// Draw the wheel with notches.
	
	// Create the back side of the wheel.
	float wheel_back_mask = band(uv + 0.05 + wheel_height, 1, notches_band - 1.0, notches_band_sharpness);
	float wheel_back_limits = smoothstep(wheel_limits_sharpness.x, wheel_limits_sharpness.y, 1.0 - abs(uv.x) * 2.0);
	wheel_back_mask = clamp(wheel_back_limits * wheel_back_mask, 0.0, 1.0);
	// Add the back side to the output color.
	output_color = overlay(output_color, vec3(0.0), wheel_back_mask, wheel_back_mask);
	output_alpha += wheel_back_mask;
	
	// Create a uv for the wheel warp/bend.
	vec2 wheel_uv = uv;
	wheel_uv.y += pow(abs(uv.x), wheel_warp_power) * wheel_warp_factor + wheel_height;

	// Create the top side of the wheel.
	float wheel_top_mask = clamp(2.0 * uv.y, 0.0, 1.0);
	wheel_top_mask = smoothstep(wheel_depth, wheel_depth + 0.16, wheel_top_mask);
	float wheel_bottom_mask = band_oneside(wheel_uv + 0.04, 1, notches_band, notches_band_sharpness);
	float wheel_bottom_limits = smoothstep(wheel_depth_sharpness.x, wheel_depth_sharpness.y, 1.0 - abs(wheel_uv.x) * 2.0);
	wheel_bottom_mask = clamp(wheel_bottom_limits * wheel_bottom_mask, 0.0, 1.0);
	float wheel_mask = min(wheel_top_mask, wheel_bottom_mask);
	
	// Add the top part of the wheel to the output color.
	vec3 wheel_top_color = mix(wheel_color, vec3(1.0), 0.15);
	output_color = overlay(output_color, wheel_top_color, wheel_mask, wheel_mask);
	output_alpha += wheel_mask;
	
	// Create the notches mask.
	float notches_mask = abs(scrolled_uv.x) * notches_frequency;
	notches_mask = abs(mod(notches_mask, notches_scale) - notches_scale / 2.0);
	notches_mask = pow(notches_mask, notches_shine) * notches_brightness;
	
	// Create a band mask for the notches. Add limits and shadow to refine the shape.
	float band_notches_mask = band(wheel_uv, 1, notches_band, notches_band_sharpness);
	float band_notches_limits = smoothstep(notches_limits_sharpness.x, notches_limits_sharpness.y, 1.0 - abs(wheel_uv.x) * 2.0);
	band_notches_mask = clamp(band_notches_limits * band_notches_mask, 0.0, 1.0);
	float band_notches_shadow = band(wheel_uv, 1, notches_band, notches_shadow_sharpness);
	band_notches_mask = clamp(band_notches_shadow * band_notches_mask, 0.0, 1.0);
	
	// Finalize the notches mask.
	notches_mask = clamp(notches_mask * band_notches_mask, 0.0, 1.0);
	
	// Add the front part of the wheel with notches to the output color.
	output_color = overlay(output_color, wheel_color, band_notches_mask, band_notches_mask);
	output_color = overlay(output_color, notches_color, notches_mask, notches_mask);
	output_alpha += band_notches_mask;
	
	// Output.
	COLOR = vec4(output_color, output_alpha);
}
