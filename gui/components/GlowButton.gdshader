shader_type canvas_item;

uniform vec3 main_color: source_color = vec3(1.0);
uniform vec3 back_color: source_color = vec3(0.0);
uniform vec4 light_color: source_color = vec4(1.0, 1.0, 1.0, 0.25);

uniform float global_shine: hint_range(0.0, 1.0) = 0.8;
uniform float side_edge_shine: hint_range(0.0, 10.0) = 1.25;

uniform float rim_factor: hint_range(0.0, 1.0) = 0.8;
uniform float rim_thickness: hint_range(0.001, 1.0) = 0.01;
uniform float rim_smoothness: hint_range(1.0e-8, 2.0) = 1.0e-8;

uniform float vignette_center: hint_range(1.0, 50.0) = 15.0;
uniform float vignette_rim: hint_range(0.0, 4.0) = 0.5;
uniform float vignette_intensity: hint_range(0.0, 1.0) = 0.0;


void fragment() {
	float color_mask = 0.0;
	vec2 uv = UV - 0.5;
	float top_size = (rim_factor / 2.0);
	
	int sides = 4;
	float angle = atan(uv.x, uv.y);
	float slice = TAU / float(sides);
	float dist = cos(floor(.5 + angle / slice) * slice - angle);
	
	// Top side mask.
	float square = (1.0 - dist * length(uv) / top_size) / 1.0e-8;
	square = clamp(square, 0.0, 1.0);
	
	// Edge shine for sides.
	float side_edge = (1.0 - dist) * side_edge_shine;
	// Mask the shine using the top side.
	side_edge = side_edge * (1.0 - square) + 0.0 * square;
	color_mask += side_edge;
	
	// Top side rim.
	float rim = (1.0 - abs(dist * length(uv) - top_size) / rim_thickness) / rim_smoothness;
	rim = clamp(rim, 0.0, 1.0);
	color_mask += rim;
	
	// Adjust the intensity.
	color_mask = smoothstep(0.0, 1.0/global_shine, color_mask);
	
	// Add a main color overlay to the top side.
	color_mask = 1.0 * square + color_mask * (1.0 - square);
	
	// Normalize the mask and apply colors.
	color_mask = clamp(color_mask, 0.0, 1.0);
	vec3 output_color = main_color * color_mask + back_color * (1.0 - color_mask);
	
	// Prepare the light/shade mask.
	float light_mask = 1.0 - (step(0.0, uv.y + uv.x));
	light_mask = light_mask * (1.0 - square) + 0.0 * square;
	
	// Apply the light/shade mask to the final color.
	output_color = mix(output_color, light_color.rgb, light_color.a) * light_mask + output_color * (1.0 - light_mask);
	// Also apply the half-light overlay to the top side.
	output_color = mix(output_color, light_color.rgb, light_color.a / 3.0) * square + output_color * (1.0 - square);
	
	// Apply a vignette effect on top.
	vec2 vignette_uv = UV * (1.0 - UV.yx);
	float vignette = clamp(pow(vignette_uv.x * vignette_uv.y * vignette_center, vignette_rim), 0.0, 1.0);
	output_color = mix(output_color, vec3(0.0), (1.0 - vignette)) * vignette_intensity + output_color * (1.0 - vignette_intensity);
	
	COLOR = vec4(output_color, 1.0);
}
