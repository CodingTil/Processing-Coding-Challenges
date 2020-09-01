import java.util.Random;
import java.lang.Math;

float[][] generateNoiseMap(int mapSize, int seed, float scale, int octaves, float persistance, float lacunarity, PVector offset) {
  float[][] noiseMap = new float[mapSize][mapSize];

  Random random = new Random(seed);
  PVector[] octaveOffsets = new PVector[octaves];
  for (int i = 0; i < octaves; i++) {
    float offsetX = -100000 + random.nextFloat() * (100000 - (-100000)) + offset.x;
    float offsetY = -100000 + random.nextFloat() * (100000 - (-100000)) + offset.y;
    octaveOffsets[i] = new PVector(offsetX, offsetY);
  }

  if (scale <= 0) scale = 0.0001;

  float maxNoiseHeight = Float.MIN_VALUE;
  float minNoiseHeight = Float.MAX_VALUE;

  for (int y = 0; y < mapSize; y++) {
    for (int x = 0; x < mapSize; x++) {

      float amplitude = 1;
      float frequency = 1;
      float noiseHeight = 0;

      for (int i = 0; i < octaves; i++) {
        float sampleX = x / scale * frequency + octaveOffsets[i].x;
        float sampleY = y / scale * frequency + octaveOffsets[i].y;

        float perlinValue = noise(sampleX, sampleY) * 2 - 1;
        noiseHeight += perlinValue * amplitude;

        amplitude *= persistance;
        frequency *= lacunarity;
      }

      if (noiseHeight > maxNoiseHeight) maxNoiseHeight = noiseHeight;
      if (noiseHeight < minNoiseHeight) minNoiseHeight = noiseHeight;

      noiseMap[x][y] = noiseHeight;
    }
  }

  for (int y = 0; y < mapSize; y++) {
    for (int x = 0; x < mapSize; x++) {
      if (abs(maxNoiseHeight - minNoiseHeight) < Math.pow(10, -5)) {
        noiseMap[x][y] = minNoiseHeight;
      } else {
        noiseMap[x][y] = (noiseMap[x][y] - minNoiseHeight)/(maxNoiseHeight - minNoiseHeight);
      }
    }
  }

  return noiseMap;
}
