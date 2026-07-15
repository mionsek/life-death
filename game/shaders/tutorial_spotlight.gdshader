shader_type canvas_item;

// Tutorial overlay: darkens the whole screen except a soft-edged spotlight
// hole around the explained obstacle, with a pulsing golden ring on its rim.
// hole_center is in canvas pixels (same space as UV * canvas_size).

uniform vec2 hole_center = vec2(-1000.0, -1000.0);
uniform float hole_radius = 46.0;
uniform float softness = 26.0;
uniform float darkness : hint_range(0.0, 1.0) = 0.8;
uniform vec2 canvas_size = vec2(640.0, 360.0);

void fragment() {
	float radius = hole_radius + sin(TIME * 3.0) * 3.0;
	float dist = distance(UV * canvas_size, hole_center);
	float shade = smoothstep(radius, radius + softness, dist);
	float ring = 1.0 - smoothstep(1.5, 4.5, abs(dist - radius));
	vec3 gold = vec3(1.0, 0.82, 0.35);
	COLOR = vec4(gold * ring, max(darkness * shade, ring * 0.9));
}
