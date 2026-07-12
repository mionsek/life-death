extends Control

# Draws the level-graph connections as dotted (hand-stippled) black trails.
# level_select feeds it dense polylines; dots are placed at an even arc-length
# spacing so the dashes stay uniform along the curves.

const DOT_SPACING := 13.0
const DOT_RADIUS := 2.1
const COLOR_OPEN := Color(0.08, 0.07, 0.06, 0.85)
const COLOR_LOCKED := Color(0.08, 0.07, 0.06, 0.32)
# Below the surface the map art is near-black, so the trail flips to glowing
# ember dots to stay readable.
const HELL_Y := 455.0
const COLOR_OPEN_HELL := Color(1.0, 0.8, 0.5, 0.9)
const COLOR_LOCKED_HELL := Color(1.0, 0.8, 0.5, 0.3)

# Each entry: {"points": PackedVector2Array, "open": bool}
var paths: Array = []


func _draw() -> void:
	for path in paths:
		var open: bool = path["open"]
		var points: PackedVector2Array = path["points"]
		var carry := 0.0
		for i in range(points.size() - 1):
			var a := points[i]
			var b := points[i + 1]
			var seg_len := a.distance_to(b)
			if seg_len <= 0.0001:
				continue
			var dir := (b - a) / seg_len
			var d := carry
			while d < seg_len:
				var dot := a + dir * d
				var color: Color
				if dot.y > HELL_Y:
					color = COLOR_OPEN_HELL if open else COLOR_LOCKED_HELL
				else:
					color = COLOR_OPEN if open else COLOR_LOCKED
				draw_circle(dot, DOT_RADIUS, color)
				d += DOT_SPACING
			carry = d - seg_len
