#version 150

#define MEDIUM_TEXTURE_SIZE int(24)

#define MEDIUM_BLOCK_FALL_IN_DURATION int(333)
#define MEDIUM_BLOCK_FALL_IN_DELAY int(82)
#define MEDIUM_IDLE_DURATION int(1000)
#define MEDIUM_BLOCK_FALL_OUT_DURATION int(167)
#define MEDIUM_BLOCK_FALL_OUT_DELAY int(13)

#define MEDIUM_BLOCK_FALL_IN_DELTA_Y int(-25)
#define MEDIUM_BLOCK_FALL_IN_OPACITY int(0)

#define MEDIUM_BLOCK_FALL_OUT_DELTA_Y int(10)
#define MEDIUM_BLOCK_FALL_OUT_OPACITY int(0)

#define MEDIUM_DELTA_X_PER_X int(-(MEDIUM_TEXTURE_SIZE / 2 - MEDIUM_TEXTURE_SIZE / 16 - 1))
#define MEDIUM_DELTA_X_PER_Y int(0)
#define MEDIUM_DELTA_X_PER_Z int((MEDIUM_TEXTURE_SIZE / 2 - MEDIUM_TEXTURE_SIZE / 16 - 1))

#define MEDIUM_DELTA_Y_PER_X int(MEDIUM_TEXTURE_SIZE / 4 - 1)
#define MEDIUM_DELTA_Y_PER_Y int(-MEDIUM_TEXTURE_SIZE / 2)
#define MEDIUM_DELTA_Y_PER_Z int(MEDIUM_TEXTURE_SIZE / 4 - 1)

#define MEDIUM_BASE_DELTA_Y int(MEDIUM_TEXTURE_SIZE / 2)
#define MEDIUM_DELTA_Y_PER_HEIGHT_UNIT int(MEDIUM_TEXTURE_SIZE)

const vec4 mediumStructureMarkerColor = vec4(21, 44, 193, 3) / 255;
const vec4 finalMediumStructureMarkerColor = vec4(21, 44, 194, 3) / 255;

int mediumCalculateBlockBaseDeltaX(int index, int sizeX, int sizeY, int sizeZ) {
    if (index == 0) {
        return -MEDIUM_TEXTURE_SIZE / 2;
    } else {
        ivec3 position = fromIndex(index, sizeX, sizeY, sizeZ);
        return position.x * MEDIUM_DELTA_X_PER_X 
                + position.y * MEDIUM_DELTA_X_PER_Y 
                + position.z * MEDIUM_DELTA_X_PER_Z
                - (MEDIUM_TEXTURE_SIZE + 1) * index
                - MEDIUM_TEXTURE_SIZE / 2;
    }
}

int mediumCalculateBlockBaseDeltaY(int index, int sizeX, int sizeY, int sizeZ) {
    ivec3 position = fromIndex(index, sizeX, sizeY, sizeZ);
    return position.x * MEDIUM_DELTA_Y_PER_X 
                + position.y * MEDIUM_DELTA_Y_PER_Y 
                + position.z * MEDIUM_DELTA_Y_PER_Z 
                - MEDIUM_TEXTURE_SIZE / 2 
                - MEDIUM_TEXTURE_SIZE * sizeY / 2
                + max(sizeX, sizeZ) * MEDIUM_TEXTURE_SIZE / 2;
}

void processStructureMedium() {
    vec4 color = texture(Sampler0, UV);
	bool isFinal = finalMediumStructureMarkerColor == color;
    if (mediumStructureMarkerColor != color && !isFinal) {
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
    
    int fallInDurationMillis = MEDIUM_BLOCK_FALL_IN_DELAY * (blocksCount - 1) + MEDIUM_BLOCK_FALL_IN_DURATION;
    int fallOutDurationMillis = MEDIUM_BLOCK_FALL_OUT_DELAY * (blocksCount - 1) + MEDIUM_BLOCK_FALL_OUT_DURATION;
    int durationMillis = fallInDurationMillis + MEDIUM_IDLE_DURATION + fallOutDurationMillis;

    int currentAnimationMillis = int(round(GameTime * 24000 * 50)) % durationMillis;

    int deltaX = mediumCalculateBlockBaseDeltaX(blockIndex, sizeX, sizeY, sizeZ); 
    int deltaY = mediumCalculateBlockBaseDeltaY(blockIndex, sizeX, sizeY, sizeZ);

    ivec3 position = fromIndex(blockIndex, sizeX, sizeY, sizeZ);

    newPosition.x += deltaX;
    newPosition.z += blockIndex;
    if (currentAnimationMillis <= fallInDurationMillis) {
        int startAnimationMillis = MEDIUM_BLOCK_FALL_IN_DELAY * blockIndex;
        float stage = 0;
        if (currentAnimationMillis >= startAnimationMillis) {
            if (currentAnimationMillis >= startAnimationMillis + MEDIUM_BLOCK_FALL_IN_DURATION) {
                stage = 1;
            } else {
                stage = float(currentAnimationMillis - startAnimationMillis) / float(MEDIUM_BLOCK_FALL_IN_DURATION);
            }
        }


        float positionStage = easeInOutCubic(stage);
        float colorStage = easeInOutCubic(stage);

        newPosition.y += deltaY + int(round((1 - positionStage) * MEDIUM_BLOCK_FALL_IN_DELTA_Y));
        newColor.a = colorStage;
    } else if (currentAnimationMillis <= fallInDurationMillis + MEDIUM_IDLE_DURATION) {
        newPosition.y += deltaY;

		if (isFinal) {
		    UV.y += 0.5;
		}
    } else {
        int startAnimationMillis = MEDIUM_BLOCK_FALL_OUT_DELAY * blockIndex;
        float stage = 0;
        int localAnimationMillis = currentAnimationMillis - fallInDurationMillis - MEDIUM_IDLE_DURATION;
        if (localAnimationMillis >= startAnimationMillis) {
            if (localAnimationMillis >= startAnimationMillis + MEDIUM_BLOCK_FALL_OUT_DURATION) {
                stage = 1;
            } else {
                stage = float(localAnimationMillis - startAnimationMillis) / float(MEDIUM_BLOCK_FALL_OUT_DURATION);
            }
        }


        float positionStage = easeInOutCubic(stage);
        float colorStage = easeInOutCubic(stage);

        newPosition.y += deltaY + int(round(positionStage * MEDIUM_BLOCK_FALL_OUT_DELTA_Y));
        newColor.a = (1 - colorStage);
    }
    
}