/*
    Список эффектов:
        removeShadow():
            удаляет тень у текста
        applyShadowModifier(float modifier):
            изменить яркость тени
            modifier - модификатор яркости [0-∞]. Чем он больше, тем тень светлее
        applyShadowAngle(float angle):
            применить угол поворота к тени
            angle - угол поворота тени (в радианах)
        applyColor(vec3 color): 
            изменить цвет текста
            color - цвет текста. Вектор с компонентами r, g, b, которые принимают значения [0; 1]
        applyWaving(float amplitude, float period, float speed):
            применить эффект волны
            amplitude - амплитуда волны (в пикселях)
            period - период волны (соотношение от 0 до 1)
            speed - скорость коллебания (в секундах)
        applyGlare(float modifier, float size, float angle, float duration, float delay):
            применить эффект блеска
            modifier - модификатор яркости [0-∞]. Чем он больше, тем светлее блик
            size - размер блика (соотношение от 0 до 1)
            angle - угол поворота блика (в радианах)
            duration - длительность блика (в секундах)
            delay - задержка между бликами (в секундах)
        applyLinearGradient(vec3 fromColor, vec3 toColor, float angle, float size, float speed):
            применить переливание по градиенту
            fromColor - начальный цвет линейного градиента. Вектор с компонентами r, g, b, которые принимают значения [0; 1]
            toColor - конечный цвет линейного градиента. Вектор с компонентами r, g, b, которые принимают значения [0; 1]
            angle - угол поворота градиента (в радианах)
            size - размер градиента (соотношение от 0 до 1)
            speed - скорость перелива (в секундах)
        applyRainbowGradient(float saturation, float brightness, float angle, float size, float speed):
            применить переливание по радужному градиенту
            saturation - насыщенность градиента [0-1]
            brightness - яркость градиента [0-1]
            angle - угол поворота градиента (в радианах)
            size - размер градиента (соотношение от 0 до 1)
            speed - скорость перелива (в секундах)
        applyChromaticAbberation(float amplitudeX, float amplitudeY, float speed):
            применить хроматическую абберацию
            amplitudeX - амплитуда по горизонтали (в пикселях)
            amplitudeY - амплитуда по вертикали (в пикселях)
            speed - скорость (в секундах)
        applySeed(float amplitudeX, float amplitudeY, float speed):
            применить эффект зерна
            amplitudeX - амплитуда по горизонтали (в пикселях)
            amplitudeY - амплитуда по вертикали (в пикселях)
            speed - скорость (в секундах)
        applyShaking(float amplitudeX, float amplitudeY, float speed):
            применить тряску
            amplitudeX - амплитуда по горизонтали (в пикселях)
            amplitudeY - амплитуда по вертикали (в пикселях)
            speed - скорость (в секундах)
        applyRussianFlag():
            применить расцветку в виде российского флага
        applyUkraineFlag():
            применить расцветку в виде украинского флага
*/

EFFECT(255, 255, 250) {
    applyColor(fromRGB(0, 0, 0));
    removeShadow();
    applyDeltaZ(300);
}

EFFECT(255, 255, 245) {
    applyColor(fromRGB(255, 255, 255));
    applyDeltaZ(300);
}

EFFECT(255, 255, 240) {
    applyColor(fromRGB(170, 170, 170));
    applyDeltaZ(300);
}

EFFECT(255, 255, 235) {
    applyDeltaZ(100);
	applyLinearGradient(fromRGB(255, 255, 255), fromRGB(200, 200, 200), PI / 4, 0.0375, 0.75);
	//applyBlink(3, 3, 0, 0, 0.15, 0.5);
	applyMultiplierAlpha(0.5);
}

EFFECT(255, 255, 230) {
	applyColor(fromRGB(255, 255, 255));
    applyDeltaZ(100);
	applyShaking(0.75, 0.75, 0.4);
	applySeed(0.3, 0.5, 0.001);
	applyLinearGradient(fromRGB(252, 210, 249), fromRGB(255, 255, 255), PI / 4, 1, 0.2);
}


EFFECT(255, 255, 225) {
    applyRainbowGradient(1, 1, 0, 0.5, 0.125);
}

EFFECT(255, 255, 220) {
    applyLinearGradient(fromRGB(212, 71, 138), fromRGB(31, 89, 120), PI / 4, 0.1, 0.5);
}

EFFECT(255, 255, 215) {
    applyLinearGradient(fromRGB(117, 128, 214), fromRGB(71, 186, 128), PI / 4, 0.1, 0.375);
}

EFFECT(255, 255, 210) {
    applyLinearGradient(fromRGB(92, 171, 166), fromRGB(138, 219, 135), PI / 4, 0.1, 0.375);
}

EFFECT(255, 255, 205) {
    applyLinearGradient(fromRGB(94, 69, 183), fromRGB(51, 34, 112), PI / 4, 0.1, 0.375);
}

EFFECT(255, 255, 200) {
    applyColor(fromRGB(255, 255, 255));
    removeShadow();
}

EFFECT(255, 255, 195) {
    applyUraniumRodColor();
    removeShadow();
    applyDeltaZ(300);
}