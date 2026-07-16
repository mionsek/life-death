shader_type canvas_item;

// The portcullis curtain retracting upward: as open_amount goes 0 -> 1, the
// visible bottom edge rises toward `top` (the lintel line, in UV.y), so the
// gate smoothly slides up and disappears behind the frame. Continuous, so it
// looks fluid at any speed regardless of frame count.

uniform float open_amount : hint_range(0.0, 1.0) = 0.0;
uniform float top : hint_range(0.0, 1.0) = 0.13;

void fragment() {
	float cutoff = mix(1.0, top, open_amount);
	if (UV.y > cutoff) {
		discard;
	}
}
