#version 150
#define VERTEX

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float GameTime;
uniform vec2 ScreenSize;

vec2 UV;
vec4 newColor;
vec3 newPosition;

out vec4 baseColor;
out vec4 vertexColor;
out vec4 textureColor;

out float vertexDistance;
out vec2 texCoord0;

#moj_import <utils.glsl>
#moj_import <interpolation.glsl>
#moj_import <structure.glsl>
#moj_import <structure_small.glsl>
#moj_import <structure_medium.glsl>
#moj_import <letter.glsl>
#moj_import <animation.glsl>
#moj_import <running_text/main.glsl>

const vec4 runningLetterMarkerColor = vec4(float(175), float(54), float(193), float(35)) / float(255);

void main() {
    UV = UV0;
    newColor = Color;
    newPosition = Position;
    processAnimation();
	processStructure();
    processStructureSmall();
    processStructureMedium();
    processRunningLetter(Sampler0, gl_VertexID % 4, UV, newColor, newPosition, runningLetterMarkerColor);
    
    gl_Position = ProjMat * ModelViewMat * vec4(newPosition, 1.0);

    baseColor = newColor;
    textureColor = texelFetch(Sampler2, UV2 / 16, 0);

    vertexDistance = length((ModelViewMat * vec4(newPosition, 1.0)).xyz);
    vertexColor = baseColor * textureColor;
    texCoord0 = UV;

    if (process()) {
        return;
    }
}
