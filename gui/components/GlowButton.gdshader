shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"

uniform vec2 button_size = vec2(1.0, 1.0);
uniform float base_incline: hint_range(0.0, 1.0) = 0.5;
uniform float horizontal_incline: hint_range(0.0, 10.0) = 1.0;

uniform vec3 main_color: source_color = vec3(1.0);
uniform vec3 back_color: source_color = vec3(0.0);
uniform vec4 light_color: source_color = vec4(1.0, 1.0, 1.0, 0.25);

uniform float global_shine: hint_range(0.0, 1.0) = 0.8;
uniform float top_shine: hint_range(0.0, 10.0) = 1.0;

uniform float side_edge_shine: hint_range(0.0, 1.0) = 0.75;
uniform float side_edge_cone: hint_range(0.1, 10.0) = 2.0;
uniform float side_edge_smoothness: hint_range(0.0, 1.0) = 0.01;
uniform float side_edge_shadow: hint_range(0.1, 20.0) = 2.0;

uniform float vignette_center: hint_range(1.0, 50.0) = 15.0;
uniform float vignette_rim: hint_range(0.0, 4.0) = 0.5;
uniform float vignette_intensity: hint_range(0.0, 1.0) = 0.0;


void fragment() {
	float aspect_ratio = button_size.x / button_size.y;
	aspect_ratio /= horizontal_incline;
	vec2 uv = (UV - 0.5);
	
	vec2 square_uv = vec2(
		sign(uv.x) * clamp(abs(uv.x) * aspect_ratio - 0.5 * (aspect_ratio - 1.0), 0.0, 0.5),
		uv.y
	);
	
	// First we build a color mask (a grayscale value defining areas for colorization later).
	float color_mask = 0.0;
	
	// Add an edge shine for sides.
	float side_edge = min(abs(square_uv.x), abs(square_uv.y));
	// Adjust the cone of the edge shine.
	side_edge = smoothstep(0.0, side_edge_shine, side_edge) / side_edge_shine;
	side_edge = pow(side_edge, side_edge_cone);
	// Add shadowing to the lowest part of the edge shine.
	float side_shadow = (abs(square_uv.x) * abs(square_uv.y) * side_edge_shadow);
	side_edge = colorize_mask(side_shadow, 0.0, side_edge);
	//
	color_mask += side_edge;
	
	// Calculate the rough top side mask.
	float square_mask = 0.55 - max(abs(square_uv.x), abs(square_uv.y));
	square_mask = smoothstep(0.0, base_incline, square_mask);
	// Add the rough top side mask for extra shine.
	color_mask += square_mask * top_shine;
	
	// Adjust the intensity.
	color_mask = smoothstep(0.0, 1.0 / global_shine, color_mask);
	
	// Add a main color layer to the top side.
	float top_mask = smoothstep(0.96, 1.0, square_mask);
	color_mask = colorize_mask(top_mask, 1.0, color_mask);
	
	// Normalize the color mask.
	color_mask = clamp(color_mask, 0.0, 1.0);
	
	// Use the color mask to generate the base output color.
	vec3 output_color = main_color * color_mask + back_color * (1.0 - color_mask);
	
	// Prepare the light/shade mask.
	float light_mask = smoothstep(0.0, side_edge_smoothness, square_uv.y + square_uv.x + side_edge_smoothness / 2.0);
	light_mask = colorize_mask(top_mask, 0.0, 1.0 - light_mask);

	// Apply the light/shade mask to the final color.
	output_color = overlay(output_color, light_color.rgb, light_color.a, light_mask);
	// Also apply the half-light overlay to the top side.
	output_color = overlay(output_color, light_color.rgb, light_color.a / 4.0, top_mask);

	// Apply a vignette effect on top.
	output_color = vignette(output_color, vec3(0.075), vignette_center, vignette_rim, vignette_intensity, UV);

	// Add a tiny bit of rounding for corners using vignetting. Values are hand-picked.
	vec3 output_mask = vignette(vec3(1.0), vec3(0.0), 10000.0, 0.02, 50.0, UV);

	// Output.
	COLOR = vec4(output_color, output_mask.r);
}
