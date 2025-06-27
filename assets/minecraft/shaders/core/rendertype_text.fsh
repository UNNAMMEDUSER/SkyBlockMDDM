#version 150
#define FRAGMENT

#moj_import <fog.glsl>

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;
uniform vec2 ScreenSize;

in vec4 baseColor;
in vec4 vertexColor;
in vec4 textureColor;

in float vertexDistance;
in vec2 texCoord0;

out vec4 fragColor;

#moj_import <utils.glsl>
#moj_import <letter.glsl>
#moj_import <running_text/main.glsl>
#moj_import <animation.glsl>

void main() {
    if (process()) {
        return;
    }
    vec2 uv = texCoord0;
    vec4 color = texture(Sampler0, uv);
    processRunningLetter(Sampler0, uv, GameTime, color);
    processAnimation(Sampler0, color);
    color = color * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
