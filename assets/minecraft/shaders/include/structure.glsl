#version 150

#define TEXTURE_SIZE int(32)

#define BLOCK_FALL_IN_DURATION int(500)
#define BLOCK_FALL_IN_DELAY int(125)
#define IDLE_DURATION int(1500)
#define BLOCK_FALL_OUT_DURATION int(250)
#define BLOCK_FALL_OUT_DELAY int(20)

#define BLOCK_FALL_IN_DELTA_Y int(-50)
#define BLOCK_FALL_IN_OPACITY float(0)

#define BLOCK_FALL_OUT_DELTA_Y int(20)
#define BLOCK_FALL_OUT_OPACITY float(0)

#define DELTA_X_PER_X int(-(TEXTURE_SIZE / 2 - TEXTURE_SIZE / 16))
#define DELTA_X_PER_Y int(0)
#define DELTA_X_PER_Z int((TEXTURE_SIZE / 2 - TEXTURE_SIZE / 16))

#define DELTA_Y_PER_X int(TEXTURE_SIZE / 4 - 1)
#define DELTA_Y_PER_Y int(-TEXTURE_SIZE / 2)
#define DELTA_Y_PER_Z int(TEXTURE_SIZE / 4 - 1)

#define BASE_DELTA_Y int(TEXTURE_SIZE / 2)
#define DELTA_Y_PER_HEIGHT_UNIT int(TEXTURE_SIZE)

const vec4 structureMarkerColor = vec4(21, 44, 193, 1) / 255;
const vec4 finalStructureMarkerColor = vec4(21, 44, 194, 1) / 255;

int calculateBlockBaseDeltaX(int index, int sizeX, int sizeY, int sizeZ) {
    if (index == 0) {
        return -TEXTURE_SIZE / 2;
    } else {
        ivec3 position = fromIndex(index, sizeX, sizeY, sizeZ);
        return position.x * DELTA_X_PER_X 
                + position.y * DELTA_X_PER_Y 
                + position.z * DELTA_X_PER_Z
                - (TEXTURE_SIZE + 1) * index
                - TEXTURE_SIZE / 2;
    }
}

int calculateBlockBaseDeltaY(int index, int sizeX, int sizeY, int sizeZ) {
    ivec3 position = fromIndex(index, sizeX, sizeY, sizeZ);
    return position.x * DELTA_Y_PER_X 
                + position.y * DELTA_Y_PER_Y 
                + position.z * DELTA_Y_PER_Z 
                - TEXTURE_SIZE / 2 
                - TEXTURE_SIZE * sizeY / 2
                + max(sizeX, sizeZ) * TEXTURE_SIZE / 2;
}

void processStructure() {
    vec4 color = texture(Sampler0, UV);
	bool isFinal = finalStructureMarkerColor == color;
    if (structureMarkerColor != color && !isFinal) {
        return;
    }
    int r = int(round(newColor.r * 255));
    int g = int(round(newColor.g * 255));
    int b = int(round(newColor.b * 255));
    int blockX = (r >> 4) % 16;
    int sizeX = r % 16;
    int blockY = (g >> 4) % 16;
    int sizeY = g % 16;
    int blockZ = (b >> 4) % 16;
    int sizeZ = b % 16;

    newColor.r = 1;
    newColor.g = 1;
    newColor.b = 1;
    if (sizeX == 0 || sizeY == 0 || sizeZ == 0) {
        return;
    }
	
	if (isFinal) {
	    UV /= 2;
	}
    
    int blockIndex = toIndex(blockX, blockY, blockZ, sizeX, sizeY, sizeZ);
    int blocksCount = sizeX * sizeY * sizeZ;
    
    int fallInDurationMillis = BLOCK_FALL_IN_DELAY * (blocksCount - 1) + BLOCK_FALL_IN_DURATION;
    int fallOutDurationMillis = BLOCK_FALL_OUT_DELAY * (blocksCount - 1) + BLOCK_FALL_OUT_DURATION;
    int durationMillis = fallInDurationMillis + IDLE_DURATION + fallOutDurationMillis;

    int currentAnimationMillis = int(round(GameTime * 24000 * 50)) % durationMillis;

    int deltaX = calculateBlockBaseDeltaX(blockIndex, sizeX, sizeY, sizeZ); 
    int deltaY = calculateBlockBaseDeltaY(blockIndex, sizeX, sizeY, sizeZ);

    ivec3 position = fromIndex(blockIndex, sizeX, sizeY, sizeZ);

    newPosition.x += deltaX;
    newPosition.z += blockIndex;
    if (currentAnimationMillis <= fallInDurationMillis) {
        int startAnimationMillis = BLOCK_FALL_IN_DELAY * blockIndex;
        float stage = 0;
        if (currentAnimationMillis >= startAnimationMillis) {
            if (currentAnimationMillis >= startAnimationMillis + BLOCK_FALL_IN_DURATION) {
                stage = 1;
            } else {
                stage = float(currentAnimationMillis - startAnimationMillis) / float(BLOCK_FALL_IN_DURATION);
            }
        }


        float positionStage = easeInOutCubic(stage);
        float colorStage = easeInOutCubic(stage);

        newPosition.y += deltaY + int(round((1 - positionStage) * BLOCK_FALL_IN_DELTA_Y));
        newColor.a = colorStage;
    } else if (currentAnimationMillis <= fallInDurationMillis + IDLE_DURATION) {
        newPosition.y += deltaY;

		if (isFinal) {
		    UV.y += 0.5;
		}
    } else {
        int startAnimationMillis = BLOCK_FALL_OUT_DELAY * blockIndex;
        float stage = 0;
        int localAnimationMillis = currentAnimationMillis - fallInDurationMillis - IDLE_DURATION;
        if (localAnimationMillis >= startAnimationMillis) {
            if (localAnimationMillis >= startAnimationMillis + BLOCK_FALL_OUT_DURATION) {
                stage = 1;
            } else {
                stage = float(localAnimationMillis - startAnimationMillis) / float(BLOCK_FALL_OUT_DURATION);
            }
        }


        float positionStage = easeInOutCubic(stage);
        float colorStage = easeInOutCubic(stage);

        newPosition.y += deltaY + int(round(positionStage * BLOCK_FALL_OUT_DELTA_Y));
        newColor.a = (1 - colorStage);

        if (isFinal) {
		    UV.y += 0.5;
		}
    }
    
}