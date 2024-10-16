shader_type canvas_item;

#include "res://shaders/functions.gdshaderinc"

uniform float state_pressed: hint_range(0.0, 1.0) = 0.0;
uniform bool inset_left = false;
uniform bool inset_right = false;

uniform float shadow_position: hint_range(0.0, 0.5) = 0.2;
uniform float shadow_size: hint_range(0.0, 0.5) = 0.1;
uniform float shadow_compensation = 0.0;

uniform float inset_height: hint_range(0.0, 1.0) = 0.67;
uniform float inset_smoothness: hint_range(0.0, 0.5) = 0.0;
uniform float inset_shadow_position: hint_range(0.0, 0.5) = 0.2;
uniform float inset_shadow_size: hint_range(0.0, 0.5) = 0.1;


void fragment() {
	vec2 uv = abs(UV - 0.5);
	vec3 output_color = COLOR.rgb;
	float output_alpha = COLOR.a;
	
	// Create UV for the shadow mask.
	vec2 shadow_uv = uv;
	shadow_uv = pow(shadow_uv, vec2(2.0));
	float sh_position = shadow_position - shadow_compensation;
	float sh_size = shadow_size + shadow_compensation;
	shadow_uv = smoothstep(sh_position - sh_size, sh_position + sh_size, shadow_uv);
	
	// Make the bottom side more intense.
	float bottom_shadow = pow(UV.y, 8.0);
	bottom_shadow = smoothstep(0.3, 0.7, bottom_shadow) / 4.0;
	shadow_uv.y += bottom_shadow * (1.0 - state_pressed);
	
	// Add insets to the shadow.
	float inset_shadow = uv.x;
	inset_shadow = pow(inset_shadow, 2.0);
	inset_shadow = smoothstep(inset_shadow_position - inset_shadow_size, inset_shadow_position + inset_shadow_size, inset_shadow);
	
	vec2 inset_uv = vec2(step(0.5, UV.x), 1.0 - UV.y);
	float inset_y_mask = inset_uv.y * inset_uv.x * float(inset_right) + inset_uv.y * (1.0 - inset_uv.x) * float(inset_left);
	inset_y_mask = smoothstep(inset_height - inset_smoothness, inset_height + inset_smoothness, inset_y_mask);
	shadow_uv.x = inset_shadow * inset_y_mask + shadow_uv.x * (1.0 - inset_y_mask);
	
	// Apply the state transform to the shadow mask.
	shadow_uv.x = shadow_uv.x + (shadow_uv.x * UV.y) * state_pressed * 2.4;
	shadow_uv.y = shadow_uv.y + UV.y / 1.4 * state_pressed;
	
	// Create the shadow mask.
	float shadow_mask = max(shadow_uv.x, shadow_uv.y);
	// Add the shadow mask to the output color.
	output_color = overlay(output_color, vec3(0.0), shadow_mask, shadow_mask);
	
	// Add a tiny bit of rounding for corners using vignetting. Values are hand-picked.
	output_alpha = vignette(vec3(1.0), vec3(0.0), 4000.0, 0.01, 40.0, UV).r;
	
	// Output.
	COLOR = vec4(output_color, output_alpha);
}
