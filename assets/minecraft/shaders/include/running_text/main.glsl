#version 150

#ifdef VERTEX

flat out float isRunningLetter;
flat out float runningLetterDuration;
flat out vec2 runningLetterFromUV;
flat out vec2 runningLetterToUV;

bool processRunningLetter(in sampler2D letterSprite, int vertexID, inout vec2 uv, inout vec4 letterColor, inout vec3 position, in vec4 markerColor) {
    vec4 color = texture(letterSprite, uv);
    if (color != markerColor) {
        isRunningLetter = float(0);
        runningLetterDuration = float(0);
        runningLetterFromUV = vec2(float(0));
        runningLetterToUV = vec2(float(0));
        return false;
    }
    if (fract(position.z) < 0.01) {
        letterColor.a = 0;
        isRunningLetter = float(0);
        runningLetterDuration = float(0);
        runningLetterFromUV = vec2(float(0));
        runningLetterToUV = vec2(float(0));
        return false;
    }
    isRunningLetter = float(1);
    ivec2 textureSize = textureSize(letterSprite, 0);

    vec2 pixelSize = vec2(float(1)) / textureSize;
    vec2 deltaUV = toRelativeVector(vertexID);

    vec2 spriteSizePropertyUV = uv + vec2((vertexID == 2 || vertexID == 3) ? -1 : 1, 0) * pixelSize;

    vec4 spriteSizeColor = texture(letterSprite, spriteSizePropertyUV);

    vec2 spriteSize = spriteSizeColor.rg * 255;
    float sectionWidth = letterColor.r * 255;

    runningLetterDuration = letterColor.g * 255;

    runningLetterFromUV = uv - deltaUV * pixelSize * spriteSize + pixelSize;
    runningLetterToUV = runningLetterFromUV + pixelSize * (spriteSize - vec2(float(2)));
    uv = runningLetterFromUV + deltaUV * pixelSize * vec2(sectionWidth, spriteSize.y - 2);

    float fromPositionX = position.x - deltaUV.x * spriteSize.x * ((spriteSize.y - 2) / (spriteSize.y));
    position.x = fromPositionX + deltaUV.x * sectionWidth;
    letterColor = vec4(float(1), float(1), float(1), letterColor.a);
    return true;
}

#endif

#ifdef FRAGMENT

flat in float isRunningLetter;
flat in float runningLetterDuration;
flat in vec2 runningLetterFromUV;
flat in vec2 runningLetterToUV;

bool processRunningLetter(in sampler2D letterSprite, inout vec2 uv, in float gameTime, inout vec4 color) {
    if (isRunningLetter < 0.5) {
        return false;
    }
    ivec2 textureSize = textureSize(letterSprite, 0);
    vec2 pixelSize = vec2(float(1)) / textureSize;

    float deltaUV = mod(gameTime * 24000 / (runningLetterDuration * 20), runningLetterToUV.x - runningLetterFromUV.x);
    uv.x += deltaUV;
    if (uv.x >= runningLetterToUV.x) {
        uv.x -= (runningLetterToUV.x - runningLetterFromUV.x);
    }
    color = texture(letterSprite, uv);
    if (color.a <= 0.01) {
        color = texture(letterSprite, runningLetterFromUV);
    }
    return true;
}

#endif