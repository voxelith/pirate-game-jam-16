shader_type spatial;
render_mode unshaded;

uniform vec4 color: source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float opacity: hint_range(0.0, 1.0, 0.1) = 1.0;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9895,75.3639))) * 4758.56);
}

void fragment() {
	if(random(SCREEN_UV) >= opacity) discard;
	ALBEDO.rgb = color.rgb;
}