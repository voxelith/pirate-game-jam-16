shader_type spatial;
render_mode unshaded, fog_disabled;

// MIT License. Made by Leo Peltola
// Inspired by https://threejs.org/examples/webgl_postprocessing_pixel.html

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
//uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

uniform float dither_strength : hint_range(0.0, 0.99, 0.01) = 0.99;
uniform float edge_strength : hint_range(0.0, 1.0, 0.01) = 0.0;

uniform sampler2D PALETTE_TEXTURE: source_color, filter_nearest;

vec3 toSrgb(const in vec3 rgb) {
	bvec3 cutoff = lessThan(rgb, vec3(0.0031308));
	vec3 higher = (pow(rgb, vec3(1.0/2.4)) * 1.055) - 0.055;
	vec3 lower = rgb * 12.92;

	return clamp(mix(higher, lower, cutoff), 0.0, 1.0);
}

float luminance(const in vec3 rgb) {
	return dot(rgb, vec3(0.2125, 0.7153, 0.0721));
}

float increaseSlopeA(float x, float a) {
	return a * x - a * 0.5 + 0.5;
}

float flatEndsA(float x) {
	float xClamped = clamp(x, 0.0, 1.);
	return 0.5 * (1. - cos(xClamped * PI));
}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9895,75.3639))) * 4758.56);
}

const float invPi2 = 2. / PI;

float atanNormA(float value) {
	return atan(value) * invPi2;
}

float getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 ipm){
    float depth = textureLod(depth_texture, screen_uv, 0.0).r;
    vec4 upos = ipm * vec4(vec3(screen_uv, depth) * 2.0 - 1.0, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	return -pixel_position.z;
}

float applyPalette(in vec3 pixelColor, out vec3 colorA, out vec3 colorB) {
	int numColors = textureSize(PALETTE_TEXTURE, 0).x;
	float n = float(numColors);

	float lengthA = 100.;
	float lengthB = 100.;
	
	vec3 pixelSrgb = toSrgb(pixelColor);
	
	vec3 lowColor = texelFetch(PALETTE_TEXTURE, ivec2(0, 0), 0).rgb;
	vec3 lowDelta = pixelColor - lowColor;
	if((lowDelta.r < 0.) && (lowDelta.g < 0.) && (lowDelta.b < 0.)) {
		colorA = colorB = lowColor;
		return 0.;
	}

	for (int i = 0; i < numColors; i += 2){
		vec3 currentColor = texelFetch(PALETTE_TEXTURE, ivec2(i, 0), 0).rgb;
		float currentLength = length(toSrgb(currentColor) - toSrgb(pixelColor));
		if (currentLength < lengthA) {
			lengthA = currentLength;
			colorA = currentColor;
		}
	}

	for (int i = 1; i < numColors; i += 2){
		float index = 1. / (2.*n) + float(i) / n;
		vec3 currentColor = texture(PALETTE_TEXTURE, vec2(index,0.5)).rgb;
		float currentLength = length(toSrgb(currentColor) - toSrgb(pixelColor));
		if (currentLength < lengthB) {
			lengthB = currentLength;
			colorB = currentColor;
		}
	}

	return atanNormA(lengthA / lengthB);
}

// Dithering Algorithms

float ditherRandom(in ivec2 coord) {
	return random(vec2(coord)) - 0.5;
}

float ditherChecker(in ivec2 coord) {
	return (coord.x % 2) == (coord.y % 2) ? -0.25 : 0.25;
}

float ditherRandomLines(in ivec2 coord, in float amount) {
	float value = random(vec2(coord));
	float shiftedDown = pow(value, amount) - 0.5;
	float shiftedUp = 0.5 - pow(1. - value, amount);
	return (coord.y % 2 == 1) ? shiftedDown : shiftedUp;
}

float ditherLinesX(in ivec2 coord) {
	return float(coord.y % 2 == 1) - 0.5;
}

float ditherLinesY(in ivec2 coord) {
	return float(coord.x % 2 == 1) - 0.5;
}

float ditherCircuit(in ivec2 coord) {
	float diagA = (coord.x % 2) == (coord.y % 2) ?
		random(vec2(coord)) * 0.5
		:
		random(vec2(coord)) - 0.5;
	float yFlip = (coord.y % 2 == 1) ? 1. : -1.;

	return diagA * yFlip;
}

void fragment() {
	vec2 e = vec2(1./VIEWPORT_SIZE.xy);

	vec3 original_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 final = original_color;
	float edge = 0.0;
	mat4 ipm = inverse(PROJECTION_MATRIX);
	float d = getDepth(SCREEN_UV, DEPTH_TEXTURE, ipm);
	{
		float du = getDepth(SCREEN_UV+vec2(0., -1.)*e, DEPTH_TEXTURE, ipm);
		float dr = getDepth(SCREEN_UV+vec2(1., 0.)*e, DEPTH_TEXTURE, ipm);
		float dd = getDepth(SCREEN_UV+vec2(0., 1.)*e, DEPTH_TEXTURE, ipm);
		float dl = getDepth(SCREEN_UV+vec2(-1., 0.)*e, DEPTH_TEXTURE, ipm);
		edge += du - d;
		edge += dd - d;
		edge += dr - d;
		edge += dl - d;
	}

	final = mix(final, final * (1. - edge_strength), clamp(edge, 0.0, 1.0));

	vec3 colorA;
	vec3 colorB;
	float colorMix = applyPalette(final, colorA, colorB);
	colorMix = increaseSlopeA(colorMix, 1.5);
	colorMix = flatEndsA(colorMix);

	ivec2 pixelCoord = ivec2(SCREEN_UV * VIEWPORT_SIZE);
	float ditherPattern = ditherChecker(pixelCoord);
	bool ditherMask = (colorMix + (ditherPattern * dither_strength)) > 0.5;

	//ALBEDO = vec3(ditherPattern);
	ALBEDO = mix(colorA, colorB, float(ditherMask));
}