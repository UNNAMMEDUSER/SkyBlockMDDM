#version 150

#ifdef VERTEX

const vec4 markerColor = vec4(10, 10, 10, 255) / 255;

bool isMarker(vec4 color) {
    return color == markerColor;
}

int toInt(vec4 color) {
    return (int(color.a * 255) << 24) + (int(color.r * 255) << 16) + (int(color.g * 255) << 8) + (int(color.b * 255)); 
}

flat out float animatedLetterInterpolation;
flat out float animatedLetterInterpolationStage;
out vec2 animatedLetterNextStageUV;

void processAnimation() {
    animatedLetterInterpolation = float(0);
    animatedLetterInterpolationStage = float(0);
    animatedLetterNextStageUV = vec2(float(0));
    ivec2 textureSize = textureSize(Sampler0, 0);
    vec4 color = texture(Sampler0, UV);
    if (!isMarker(color)) {
        return;
    }
    int vertexID = gl_VertexID % 4;
    
    vec2 pixelSize = vec2(1) / textureSize;
    vec2 propertiesDeltaUV = vec2((vertexID == 2 || vertexID == 3) ? -1 : 1, 0);
    vec2 deltaUV = vec2((vertexID == 2 || vertexID == 3) ? 1 : 0, (vertexID == 1 || vertexID == 2) ? 1 : 0);

    vec2 sectionSizePropertyUV = UV + propertiesDeltaUV * pixelSize;
    vec2 framesCountPropertyUV = UV + propertiesDeltaUV * pixelSize * 2;
    vec2 framesTotalCountPropertyUV = UV + propertiesDeltaUV * pixelSize * 3;
    vec2 framesDelayPropertyUV = UV + propertiesDeltaUV * pixelSize * 4;
    vec2 ascentPropertyUV = UV + propertiesDeltaUV * pixelSize * 5;
    vec2 interpolationPropertyUV = UV + propertiesDeltaUV * pixelSize * 6;

    int frameSize = toInt(texture(Sampler0, sectionSizePropertyUV));
    int framesCount = toInt(texture(Sampler0, framesCountPropertyUV));
    int framesTotalCount = toInt(texture(Sampler0, framesTotalCountPropertyUV));
    int frameDelay = toInt(texture(Sampler0, framesDelayPropertyUV));
    int ascent = toInt(texture(Sampler0, ascentPropertyUV));
    animatedLetterInterpolation = toInt(texture(Sampler0, interpolationPropertyUV)) != 0 ? float(1) : float(0);
    ivec2 spriteSheetSize = ivec2(frameSize) * ivec2(framesCount) + ivec2(2, 2);
    vec2 baseUV = UV - (spriteSheetSize * deltaUV) * pixelSize;

    float stage = fract(GameTime * 24000 * 20 / (frameDelay * framesTotalCount));
    int currentFrame = int(stage * framesTotalCount);
    int frameX = currentFrame % framesCount;
    int frameY = currentFrame / framesCount;
    UV = baseUV + (vec2(1) + (vec2(frameX, frameY) + deltaUV) * frameSize) * pixelSize;
    if (animatedLetterInterpolation > 0.5) {
        float stagePerFrame = float(1) / float(framesTotalCount);
        animatedLetterInterpolationStage = mod(stage, stagePerFrame) / stagePerFrame;

        int nextFrame = (currentFrame + 1) % framesTotalCount;
        int nextFrameX = nextFrame % framesCount;
        int nextFrameY = nextFrame / framesCount;

        animatedLetterNextStageUV = baseUV + (vec2(1) + (vec2(nextFrameX, nextFrameY) + deltaUV) * frameSize) * pixelSize;
    }
    newPosition.y -= ascent;
}

#endif

#ifdef FRAGMENT


flat in float animatedLetterInterpolation;
flat in float animatedLetterInterpolationStage;
in vec2 animatedLetterNextStageUV;

void processAnimation(in sampler2D sprite, inout vec4 color) {
    if (animatedLetterInterpolation < 0.5) {
        return;
    }
    vec4 overlayColor = texture(sprite, animatedLetterNextStageUV);
    color = color + (overlayColor - color) * animatedLetterInterpolationStage;
}

#endif
