// Helpful functions for effect shaders.

// Adds an overlay on top of the base color, following the blend factor and the mask.
vec3 overlay(vec3 base_color, vec3 overlay_color, float overlay_blend, float mask) {
	return mix(base_color, overlay_color, overlay_blend) * mask + base_color * (1.0 - mask);
}

// Adds a vignette effect on top of the base color.
vec3 vignette(vec3 base_color, vec3 color, float center, float rim, float intensity, vec2 uv) {
	vec2 vignette_uv = uv * (1.0 - uv.yx);
	float value = clamp(pow(vignette_uv.x * vignette_uv.y * center, rim), 0.0, 1.0);

	return overlay(base_color, color, (1.0 - value), intensity);
}

// Remaps the mask value to the target pair of colors.
float colorize_mask(float mask, float in_color, float out_color) {
	return mask * in_color + (1.0 - mask) * out_color;
}

// Calculates the distance for a polygon with the given number of sides.
float polygon_distance(int sides, vec2 uv) {
	float angle = atan(uv.x, uv.y);
	float slice = TAU / float(sides);

	return cos(floor(.5 + angle / slice) * slice - angle);
}

// Based on https://github.com/ttencate/blur_godot4/blob/0517d1159b088a272300b083ae98376d9d77ffea/Blur.gdshader.
float blur_alpha(sampler2D source, vec2 uv, vec2 direction, float intensity) {
	vec2 s = intensity * direction / vec2(textureSize(source, 0));

	float blurred =
		0.011194727 * texture(source, uv - 10.000000000 * s).a +
		0.039368696 * texture(source, uv - 8.415809477 * s).a +
		0.071308558 * texture(source, uv - 6.435363708 * s).a +
		0.110237219 * texture(source, uv - 4.455121108 * s).a +
		0.145451038 * texture(source, uv - 2.475020813 * s).a +
		0.163798995 * texture(source, uv - 0.495000167 * s).a +
		0.157439298 * texture(source, uv + 1.485004498 * s).a +
		0.129158204 * texture(source, uv + 3.465057055 * s).a +
		0.090434685 * texture(source, uv + 5.445220765 * s).a +
		0.054043977 * texture(source, uv + 7.425557483 * s).a +
		0.027564604 * texture(source, uv + 9.406126897 * s).a;

	// Allows to disable the effect completely at the cost of being applied twice.
	blurred *= intensity;

	return blurred;
}

vec3 blur_color(sampler2D source, vec2 uv, vec2 direction, float intensity) {
	vec2 s = intensity * direction / vec2(textureSize(source, 0));

	vec3 blurred =
		0.011194727 * texture(source, uv - 10.000000000 * s).rgb +
		0.039368696 * texture(source, uv - 8.415809477 * s).rgb +
		0.071308558 * texture(source, uv - 6.435363708 * s).rgb +
		0.110237219 * texture(source, uv - 4.455121108 * s).rgb +
		0.145451038 * texture(source, uv - 2.475020813 * s).rgb +
		0.163798995 * texture(source, uv - 0.495000167 * s).rgb +
		0.157439298 * texture(source, uv + 1.485004498 * s).rgb +
		0.129158204 * texture(source, uv + 3.465057055 * s).rgb +
		0.090434685 * texture(source, uv + 5.445220765 * s).rgb +
		0.054043977 * texture(source, uv + 7.425557483 * s).rgb +
		0.027564604 * texture(source, uv + 9.406126897 * s).rgb;

	// Allows to disable the effect completely at the cost of being applied twice.
	blurred *= intensity;

	return blurred;
}
