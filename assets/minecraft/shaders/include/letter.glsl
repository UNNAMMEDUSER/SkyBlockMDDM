#version 150

struct Letter {

    vec4 baseColor;
    vec4 topColor;
    vec4 bottomColor;

    vec2 position;
    vec2 localPosition;
    float z;

    vec2 uv;
    vec2 uvMin;
    vec2 uvMax;

    bool shadow;
    bool scaled;
    bool lookup;

};

Letter letter;

bool isInvalidBounds() {
    if(isnan(letter.uv.x) || isnan(letter.uv.y)) {
        return true;
    }
    float epsilon = 0.0001;
    return letter.uv.x < letter.uvMin.x + epsilon || letter.uv.y < letter.uvMin.y + epsilon || letter.uv.x > letter.uvMax.x - epsilon || letter.uv.y > letter.uvMax.y - epsilon;
}

bool isInvalidBounds(vec2 uv, vec2 uvMin, vec2 uvMax, float epsilon) {
    if(isnan(uv.x) || isnan(uv.y)) {
        return true;
    }
    return uv.x < uvMin.x + epsilon || uv.y < uvMin.y + epsilon || uv.x > uvMax.x - epsilon || uv.y > uvMax.y - epsilon;
}

void applyColor(vec3 color) {
    letter.baseColor.rgb = color;
    if (letter.shadow) {
        letter.baseColor.rgb *= 0.25;
    }
}

void applyBottomColor(vec3 color) {
    letter.bottomColor.rgb = color;
    if (letter.shadow) {
        letter.bottomColor.rgb *= 0.25;
    }
}

void applyShadowModifier(float modifier) {
    if (letter.shadow) {
        letter.baseColor.rgb = letter.baseColor.rgb * modifier;
    }
}

void removeShadow() {
    if (letter.shadow) {
        letter.baseColor.a = 0;
    }
}

void applyWaving(float amplitude, float period, float speed) {
    letter.scaled = true;
    letter.uv.y += sin(letter.position.x / ScreenSize.x / period * 10.0 - GameTime * 1200.0 * PI / (speed * 0.5)) * amplitude / 256.0;
}

void applyGlare(float modifier, float size, float angle, float duration, float delay) {
    #ifdef FRAGMENT
        float cycle = mod(GameTime * 1200.0, duration + delay);
        if (cycle > duration) {
            return;
        }
        float stage = cycle / duration;
        float radius = sqrt(float(2));
        float angleCos = cos(angle);
        float angleSin = sin(angle);
        vec2 glareFrom = vec2(0.5) - vec2(radius / 2 + size) * vec2(angleCos, angleSin);
        vec2 glareTo = vec2(0.5) + vec2(radius / 2 + size) * vec2(angleCos, angleSin);
        vec2 glarePoint = glareFrom + (glareTo - glareFrom) * stage;
        vec2 localPosition = gl_FragCoord.xy / ScreenSize.xy;
        float distance = distanceBetween(localPosition, glarePoint, angle);
        letter.topColor = vec4(1.0, 1.0, 1.0, modifier * max(1 - distance / (size * 0.5), 0));
    #else
        size += 0;
    #endif
}

void applyLinearGradient(vec3 fromColor, vec3 toColor, float angle, float size, float speed) {
    #ifdef FRAGMENT 
        float stage = mod(GameTime * 1200 * speed * 2 + (-cos(angle) * gl_FragCoord.x / ScreenSize.x + sin(angle) * gl_FragCoord.y / ScreenSize.y) / size, 2);
        if (stage > 1) {
            stage = (1 - (stage - 1));
        }
        vec3 color = fromColor + (toColor - fromColor) * stage;
        applyColor(color);
        applyBottomColor(color);
    #else
        size += 0;
    #endif
}

void applyRainbowGradient(float saturation, float brightness, float angle, float size, float speed) {
    #ifdef FRAGMENT
        vec3 color = fromHSV(vec3(
            mod(GameTime * 1200 * speed * 2 + (-cos(angle) * gl_FragCoord.x / ScreenSize.x + sin(angle) * gl_FragCoord.y / ScreenSize.y) / size, 1), 
            saturation, 
            brightness
        ));
        applyColor(color);
        applyBottomColor(color);
    #else
        size += 0;
    #endif
}

void applyChromaticAbberation(float amplitudeX, float amplitudeY, float speed) {
    letter.scaled = true;
    float noiseX = noise(GameTime * 12000.0 * speed) - 0.5;
    float noiseY = noise((GameTime + 1.5) * 12000.0 * speed) - 0.5;
    vec2 offset = vec2(0.5 / 256, 0.0) + vec2(0.5, 1.0) * vec2(noiseX, noiseY) * vec2(amplitudeX, amplitudeY) / 256;

    vec2 uv = letter.uv + offset;
    vec4 textureColor1 = texture(Sampler0, uv);
    textureColor1.rgb *= textureColor1.a;
    if (isInvalidBounds(uv, letter.uvMin, letter.uvMax, 0.0001)) {
        textureColor1 = vec4(0.0);
    }

    uv = letter.uv - offset;
    vec4 textureColor2 = texture(Sampler0, uv);
    textureColor2.rgb *= textureColor2.a;
    if(isInvalidBounds(uv, letter.uvMin, letter.uvMax, 0.0001)) {
        textureColor2 = vec4(0.0);
    }

    letter.bottomColor = (textureColor1 * vec4(1.0, 0.25, 0.0, 1.0)) + (textureColor2 * vec4(0.0, 0.75, 1.0, 1.0));
    letter.bottomColor.rgb *= letter.baseColor.rgb;
}

void applySeed(float amplitudeX, float amplitudeY, float speed) {
    letter.scaled = true;   
    float noiseX = noise(GameTime * 12000.0 * speed + random(letter.uv.x * letter.uv.x * letter.uv.y * 1000000) * 10000) - 0.5;
    float noiseY = noise((GameTime + 1.5) * 12000.0 * speed + random(letter.uv.x * letter.uv.y * letter.uv.y * 1000000) * 10000) - 0.5;
    vec2 offset = vec2(0.5 / 256, 0.0) + vec2(0.5, 1.0) * vec2(noiseX, noiseY) * vec2(amplitudeX, amplitudeY) / 256;
    vec2 uv = letter.uv + offset;
    vec4 textureColor = texture(Sampler0, uv);
    if (isInvalidBounds(uv, letter.uvMin, letter.uvMax, 0.0001)) {
        textureColor = vec4(0.0);
    }
    float alpha = letter.baseColor.a * textureColor.a;
    applyBottomColor(textureColor.rgb);
    letter.baseColor.a = alpha;
    letter.bottomColor.a = alpha;
}

void applyShadowAngle(float angle) {
    if (letter.shadow) {
        vec2 offset = vec2(round(-cos(angle)) + 1, round(sin(angle)) + 1) / vec2(256.0);
        letter.uv += offset;
        letter.scaled = true;
    }
}

void applyStroke(vec3 color, float thickness) {
    letter.scaled = true;
    vec2 delta = thickness / vec2(256.0);

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (x == 0 && y == 0) {
                continue;
            }
            vec2 uv = letter.uv + vec2(x, y) * delta;
            if (isInvalidBounds(uv, letter.uvMin, letter.uvMax, 0.0001)) {
                continue;
            }
            vec4 textureColor = texture(Sampler0, uv);
            if (textureColor.a < 0.01) {
                continue;
            }
            applyBottomColor(color);
            letter.bottomColor.a = textureColor.a;
            return;
        }
    }
}

void applyShaking(float amplitudeX, float amplitudeY, float speed) {
    letter.scaled = true;
    float noiseX = noise(GameTime * 12000.0 * speed + letter.position.x + letter.position.y) - 0.5;
    float noiseY = noise((GameTime + 1.5) * 12000.0 * speed + letter.position.x + letter.position.y) - 0.5;
    vec2 offset = vec2(noiseX, noiseY) * vec2(amplitudeX, amplitudeY) / 256;
    letter.uv += offset;
}

void applyRussianFlag() {
    int y = int(floor((letter.uv.y - letter.uvMin.y) * 256));
    if (y <= 2) {
        applyColor(vec3(0.93, 0.93, 0.93));
    } else if (y <= 5) {
        applyColor(vec3(0.26, 0.3, 0.69));
    } else {
        applyColor(vec3(0.69, 0.26, 0.26));
    }
}

void applyUkraineFlag() {
    int y = int(floor((letter.uv.y - letter.uvMin.y) * 256));
    if (y <= 3) {
        applyColor(vec3(0.26, 0.3, 0.69));
    } else {
        applyColor(vec3(0.72, 0.67, 0.22));
    }
}

void applyUraniumRodColor() {
    int y = int(floor((letter.uv.y - letter.uvMin.y) * 256));
    if (y > 1 && y <= 4) {
        applyColor(vec3(0.325, 0.322, 0.294));
    } else {
        applyColor(vec3(0.247, 0.243, 0.227));
    }
}

void applyZ(float z) {
    if (letter.shadow) {
        z += 0.01;
    }

    letter.z = z;
}

void applyDeltaZ(float z) {
    applyZ(letter.z + z);
}

void applyBlink(float fadeInTime, float fadeOutTime, float inDuration, float outDuration, float minAlpha, float maxAlpha) {
    float localSecond = mod(GameTime * 24000 / 20, (fadeInTime + fadeOutTime + inDuration + outDuration));
	float alphaDelta = maxAlpha - minAlpha;
    if (localSecond <= fadeInTime) {
        letter.baseColor.a *= sin(localSecond / fadeInTime * PI / 2) * alphaDelta + minAlpha;
    } else if (localSecond <= fadeInTime + inDuration) {
        letter.baseColor.a *= maxAlpha;
    } else if (localSecond <= fadeOutTime + inDuration + fadeInTime) {
        letter.baseColor.a *= sin((1 - (localSecond - inDuration - fadeInTime) / fadeOutTime) * PI / 2) * alphaDelta + minAlpha;
    } else {
        letter.baseColor.a *= minAlpha;
    }
}

void applyMultiplierAlpha(float a) {
    letter.baseColor.a *= a;
}

#define EFFECT(r, g, b) return true; case ((uint(r / 4.0) << 24) | (uint(g / 4.0) << 16) | (uint(b / 4.0) << 8) | (uint(255))):

bool applyEffects() {
    uint rgb = toRGB(floor(round(letter.baseColor.rgb * 255.0) * 0.25) / 255.0);
    if (letter.shadow) {
        rgb = toRGB(letter.baseColor.rgb);
    }
    switch (rgb) {
        case 0x00000000u:
    #moj_import <effects.glsl>
        return true;
    }
    return false;
}

#ifdef FRAGMENT

flat in float shadow;
flat in float skip;
flat in float scaled;

in vec4 vertexPosition;
in vec3 vertexPosition0;
in vec3 vertexPosition1;
in vec3 vertexPosition2;
in vec3 vertexPosition3;

in vec3 vertexUv0;
in vec3 vertexUv1;
in vec3 vertexUv2;
in vec3 vertexUv3;

bool process() {
    if (skip > 0.5) {
        return false;
    }

    letter.lookup = true;
    letter.shadow = shadow > 0.5;
    letter.baseColor = baseColor;
    letter.bottomColor = letter.topColor = vec4(0);

    vec2 uv0 = vertexUv0.xy / vertexUv0.z;
    vec2 uv1 = vertexUv1.xy / vertexUv1.z;
    vec2 uv2 = vertexUv2.xy / vertexUv2.z;
    vec2 uv3 = vertexUv3.xy / vertexUv3.z;
    vec2 uvMin = min(uv0, min(uv1, min(uv2, uv3)));
    vec2 uvMax = max(uv0, max(uv1, max(uv2, uv3)));
    vec2 uvSize = uvMax - uvMin;

    vec2 position0 = vertexPosition0.xy / vertexPosition0.z;
    vec2 position1 = vertexPosition1.xy / vertexPosition1.z;
    vec2 position2 = vertexPosition2.xy / vertexPosition2.z;
    vec2 position3 = vertexPosition3.xy / vertexPosition3.z;
    vec2 positionMin = min(position0, min(position1, min(position2, position3)));
    vec2 positionMax = max(position0, max(position1, max(position2, position3)));
    vec2 size = positionMax - positionMin;

    letter.uvMin = uvMin;
    letter.uvMax = uvMax;
    letter.localPosition = (vertexPosition.xy - positionMin) / size;
    letter.localPosition.y = 1 - letter.localPosition.y;
    letter.uv = scaled > 0.5 ? letter.localPosition * uvSize + uvMin : texCoord0;
    letter.position = 0.5 * (positionMin + positionMax) * uvSize * 256.0 / size;
    if (letter.shadow) { 
        letter.position += vec2(-1.0, 1.0);
    }
    applyEffects();
    if (isInvalidBounds()) {
        letter.lookup = false;
    }

    vec4 localColor = letter.lookup ? texture(Sampler0, letter.uv) : vec4(0);
    letter.topColor.a *= localColor.a;

    fragColor = mix(vec4(letter.bottomColor.rgb, letter.bottomColor.a * letter.baseColor.a), localColor * letter.baseColor, localColor.a);
    fragColor.rgb = mix(fragColor.rgb, letter.topColor.rgb, letter.topColor.a);
    fragColor *= textureColor * ColorModulator;

    if (fragColor.a < 0.1) {
        discard;
    }

    fragColor = linear_fog(fragColor, vertexDistance, FogStart, FogEnd, FogColor);
    return true;
}
#endif

#ifdef VERTEX

flat out float shadow;
flat out float skip;
flat out float scaled;

out vec4 vertexPosition;
out vec3 vertexPosition0;
out vec3 vertexPosition1;
out vec3 vertexPosition2;
out vec3 vertexPosition3;

out vec3 vertexUv0;
out vec3 vertexUv1;
out vec3 vertexUv2;
out vec3 vertexUv3;

bool process() {
    gl_Position = ProjMat * ModelViewMat * vec4(newPosition, 1.0);
    ivec2 textureSize = textureSize(Sampler0, 0);

    skip = 0.0;
    scaled = 0.0;

    shadow = fract(newPosition.z) < 0.01 ? 1.0 : 0.0;

    letter.shadow = shadow > 0.5;
    letter.baseColor = Color;
    letter.scaled = false;
    letter.z = newPosition.z;

    if (!applyEffects()) {
        shadow = 0;
        if (newPosition.z == 0.0 && letter.shadow) {
            letter.shadow = false;
            if (applyEffects()) {
                shadow = 0;
            } else {
                skip = 1;
                return false;
            }
        } else {
            skip = 1;
            return false;
        }
    }

    if (textureSize != ivec2(256, 256)) {
        skip = 1;
        return false;
    }

    vec2 corner = vec2(0.0);
    vertexPosition0 = vertexPosition1 = vertexPosition2 = vertexPosition3 = vec3(0.0);
    vertexUv0 = vertexUv1 = vertexUv2 = vertexUv3 = vec3(0.0);
    switch (gl_VertexID % 4) {
        case 0:
            vertexPosition0 = vec3(gl_Position.xy, 1.0);
            vertexUv0 = vec3(UV.xy, 1.0);
            corner = vec2(-1.0, 1.0);
            break;
        case 1:
            vertexPosition1 = vec3(gl_Position.xy, 1.0);
            vertexUv1 = vec3(UV.xy, 1.0);
            corner = vec2(-1.0, -1.0);
            break;
        case 2:
            vertexPosition2 = vec3(gl_Position.xy, 1.0);
            vertexUv2 = vec3(UV.xy, 1.0);
            corner = vec2(1.0, -1.0);
            break;
        case 3:
            vertexPosition3 = vec3(gl_Position.xy, 1.0);
            vertexUv3 = vec3(UV.xy, 1.0);
            corner = vec2(1.0, 1.0);
            break;
    }

    newPosition.z = letter.z;
    gl_Position = ProjMat * ModelViewMat * vec4(newPosition, 1.0);
    if (letter.scaled) {
        gl_Position.xy += corner * 0.2;
        scaled = 1.0;
    }

    vertexPosition = gl_Position;
    vertexDistance = length((ModelViewMat * vec4(newPosition, 1.0)).xyz);
    vertexColor = baseColor * textureColor;
    texCoord0 = UV;
    return true;
}

#endif