#version 150
#define PI 3.1415926538

uint toRGB(vec3 color) {
    uint r = uint(round(color.r * 255));
    uint g = uint(round(color.g * 255));
    uint b = uint(round(color.b * 255));
    return ((uint(r) << 24) | (uint(g) << 16) | (uint(b) << 8) | uint(255));
}

uint toRGB(vec4 color) {
    uint r = uint(round(color.r * 255));
    uint g = uint(round(color.g * 255));
    uint b = uint(round(color.b * 255));
    uint a = uint(round(color.a * 255));
    return ((uint(r) << 24) | (uint(g) << 16) | (uint(b) << 8) | uint(a));
}

float random(float seed) {
    return fract(sin(seed) * 43758.5453123);
}

float random(vec2 seed){
	return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(float n) {
    float floor = floor(n);
    float fract = fract(n);
    return mix(random(floor), random(floor + 1), fract);
}

vec3 fromRGB(float r, float g, float b) {
    return vec3(r / 255.0, g / 255.0, b / 255.0);
}

vec3 fromHSV(vec3 color) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.www);
    return color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), color.y);
}

float distanceBetween(vec2 point, vec2 linePoint, float angle) {
    vec2 direction = vec2(cos(angle), sin(angle));
    vec2 normalizedDirection = normalize(direction);
    float a = normalizedDirection.x;
    float b = normalizedDirection.y;
    float c = -(a * linePoint.x + b * linePoint.y);

    return abs(a * point.x + b * point.y + c) / sqrt(a * a + b * b);
}

int toIndex(int x, int y, int z, int sizeX, int sizeY, int sizeZ) {
    return x + z * sizeX + y * sizeX * sizeZ;
}

ivec3 fromIndex(int index, int sizeX, int sizeY, int sizeZ) {
    return ivec3(index % sizeX, (index / (sizeX * sizeZ)) % sizeY, (index / sizeX) % sizeZ);
}

const vec2[4] verticesRelativeVectors = vec2[4] (
    vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0)
);

vec2 toRelativeVector(int vertexID) {
    return verticesRelativeVectors[vertexID % 4];
}
