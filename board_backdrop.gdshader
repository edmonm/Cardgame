shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	vec3 base = vec3(0.04, 0.06, 0.09);
	float vignette = smoothstep(0.95, 0.25, length(uv - vec2(0.5)));
	float enemy_lane = smoothstep(0.08, 0.0, abs(uv.y - 0.16));
	float player_lane = smoothstep(0.08, 0.0, abs(uv.y - 0.62));
	vec3 lanes = vec3(0.10, 0.08, 0.05) * enemy_lane + vec3(0.07, 0.10, 0.12) * player_lane;
	COLOR = vec4(base + vec3(0.03, 0.05, 0.07) * vignette + lanes, 1.0);
}
