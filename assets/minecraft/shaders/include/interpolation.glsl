#version 150

#define PI 3.1415926538

#define LINEAR 1
#define EASE_IN_SINE 2
#define EASE_OUT_SINE 3
#define EASE_IN_OUT_SINE 4
#define EASE_IN_QUAD 5
#define EASE_OUT_QUAD 6
#define EASE_IN_OUT_QUAD 7
#define EASE_IN_CUBIC 8
#define EASE_OUT_CUBIC 9
#define EASE_IN_OUT_CUBIC 10
#define EASE_IN_QUART 11
#define EASE_OUT_QUART 12
#define EASE_IN_OUT_QUART 13
#define EASE_IN_QUINT 14
#define EASE_OUT_QUINT 15
#define EASE_IN_OUT_QUINT 16
#define EASE_IN_EXPO 17
#define EASE_OUT_EXPO 18
#define EASE_IN_OUT_EXPO 19
#define EASE_IN_CIRC 20
#define EASE_OUT_CIRC 21
#define EASE_IN_OUT_CIRC 22
#define EASE_IN_BACK 23
#define EASE_OUT_BACK 24
#define EASE_IN_OUT_BACK 25
#define EASE_IN_ELASTIC 26
#define EASE_OUT_ELASTIC 27
#define EASE_IN_OUT_ELASTIC 28
#define EASE_IN_BOUNCE 29
#define EASE_OUT_BOUNCE 30
#define EASE_IN_OUT_BOUNCE 31

float easeInSine(float x) {
    return 1 - cos((x * PI) / 2);
}

float easeOutSine(float x) {
    return sin((x * PI) / 2);
}

float easeInOutSine(float x) {
    return -(cos(PI * x) - 1) / 2;
}

float easeInQuad(float x) {
    return pow(x, 2);
}

float easeOutQuad(float x) {
    return 1 - pow(1 - x, 2);
}

float easeInOutQuad(float x) {
    return x < 0.5 ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2;
}

float easeInCubic(float x) {
    return pow(x, 3);
}

float easeOutCubic(float x) {
    return 1 - pow(1 - x, 3);
}

float easeInOutCubic(float x) {
    return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
}

float easeInQuart(float x) {
    return pow(x, 4);
}

float easeOutQuart(float x) {
    return 1 - pow(1 - x, 4);
}

float easeInOutQuart(float x) {
    return x < 0.5 ? 8 * x * x * x * x : 1 - pow(-2 * x + 2, 4) / 2;
}

float easeInQuint(float x) {
    return pow(x, 5);
}

float easeOutQuint(float x) {
    return 1 - pow(1 - x, 5);
}

float easeInOutQuint(float x) {
    return x < 0.5 ? 16 * x * x * x * x * x : 1 - pow(-2 * x + 2, 5) / 2;
}

float easeInExpo(float x) {
    return x == 0 ? 0 : pow(2, 10 * x - 10);
}

float easeOutExpo(float x) {
    return x == 1 ? 1 : 1 - pow(2, -10 * x);
}

float easeInOutExpo(float x) {
    return x == 0
        ? 0
        : x == 1
        ? 1
        : x < 0.5 ? pow(2, 20 * x - 10) / 2
        : (2 - pow(2, -20 * x + 10)) / 2;
}

float easeInCirc(float x) {
    return 1 - sqrt(1 - pow(x, 2));
}

float easeOutCirc(float x) {
    return sqrt(1 - pow(x - 1, 2));
}

float easeInOutCirc(float x) {
    return x < 0.5
        ? (1 - sqrt(1 - pow(2 * x, 2))) / 2
        : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2;
}

float easeInBack(float x) {
    return 2.70158 * pow(x, 3) - 1.70158 * pow(x, 2);
}

float easeOutBack(float x) {
    return 1 + 2.70158 * pow(x - 1, 3) + 1.70158 * pow(x - 1, 2);
}

float easeInOutBack(float x) {
    float c1 = 1.70158;
    float c2 = c1 * 1.525;

    return x < 0.5
        ? (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
        : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
}

float easeInElastic(float x) {
    float c4 = (2 * PI) / 3;
    return x == 0
        ? 0
        : x == 1
        ? 1
        : -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4);
}

float easeOutElastic(float x) {
    float c4 = (2 * PI) / 3;

    return x == 0
        ? 0
        : x == 1
        ? 1
        : pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1;
}

float easeInOutElastic(float x) {
    float c5 = (2 * PI) / 4.5;

    return x == 0
        ? 0
        : x == 1
        ? 1
        : x < 0.5
        ? -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
        : (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1;
}

float easeOutBounce(float x) {
    float n1 = 7.5625;
    float d1 = 2.75;

    if (x < 1 / d1) {
        return n1 * x * x;
    } else if (x < 2 / d1) {
        return n1 * (x -= 1.5 / d1) * x + 0.75;
    } else if (x < 2.5 / d1) {
        return n1 * (x -= 2.25 / d1) * x + 0.9375;
    } else {
        return n1 * (x -= 2.625 / d1) * x + 0.984375;
    }
}

float easeInBounce(float x) {
    return 1 - easeOutBounce(1 - x);
}

float easeInOutBounce(float x) {
    return x < 0.5
        ? (1 - easeOutBounce(1 - 2 * x)) / 2
        : (1 + easeOutBounce(2 * x - 1)) / 2;
}

float interpolate(float x, int function) {
    switch (function) {
        case EASE_IN_SINE:
            return easeInSine(x);
        case EASE_OUT_SINE:
            return easeOutSine(x);
        case EASE_IN_OUT_SINE:
            return easeInOutSine(x);
        case EASE_IN_QUAD:
            return easeInQuad(x);
        case EASE_OUT_QUAD:
            return easeOutQuad(x);
        case EASE_IN_OUT_QUAD:
            return easeInOutQuad(x);
        case EASE_IN_CUBIC:
            return easeInCubic(x);
        case EASE_OUT_CUBIC:
            return easeOutCubic(x);
        case EASE_IN_OUT_CUBIC:
            return easeInOutCubic(x);
        case EASE_IN_QUART:
            return easeInQuart(x);
        case EASE_OUT_QUART:
            return easeOutQuart(x);
        case EASE_IN_OUT_QUART:
            return easeInOutQuart(x);
        case EASE_IN_QUINT:
            return easeInQuint(x);
        case EASE_OUT_QUINT:
            return easeOutQuint(x);
        case EASE_IN_OUT_QUINT:
            return easeInOutQuint(x);
        case EASE_IN_EXPO:
            return easeInExpo(x);
        case EASE_OUT_EXPO:
            return easeOutExpo(x);
        case EASE_IN_OUT_EXPO:
            return easeInOutExpo(x);
        case EASE_IN_CIRC:
            return easeInCirc(x);
        case EASE_OUT_CIRC:
            return easeOutCirc(x);
        case EASE_IN_OUT_CIRC:
            return easeInOutCirc(x);
        case EASE_IN_BACK:
            return easeInBack(x);
        case EASE_OUT_BACK:
            return easeOutBack(x);
        case EASE_IN_OUT_BACK:
            return easeInOutBack(x);
        case EASE_IN_ELASTIC:
            return easeInElastic(x);
        case EASE_OUT_ELASTIC:
            return easeOutElastic(x);
        case EASE_IN_OUT_ELASTIC:
            return easeInOutElastic(x);
        case EASE_IN_BOUNCE:
            return easeInBounce(x);
        case EASE_OUT_BOUNCE:
            return easeOutBounce(x);
        case EASE_IN_OUT_BOUNCE:
            return easeInOutBounce(x);
    }
    return x;
}

