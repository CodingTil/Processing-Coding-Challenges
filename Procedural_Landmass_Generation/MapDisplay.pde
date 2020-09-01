class MapDisplay extends PApplet {

  private static final int windowSize = 800;

  final float[][] noiseMap;

  MapDisplay(float[][] noiseMap) {
    this.noiseMap = noiseMap;
  }

  void settings() {
    size(windowSize, windowSize, P2D);
  }

  void setup() {
    background(0);

    int width = noiseMap.length;
    int height = noiseMap[0].length;

    loadPixels();

    for (int y = 0; y < windowSize; y++) {
      for (int x = 0; x < windowSize; x++) {
        float currentHeight = noiseMap[(int) map(x, 0, windowSize, 0, width)][(int) map(y, 0, windowSize, 0, height)];
        pixels[y*windowSize+x] = TerrainType.getColorForFloat(currentHeight);
      }
    }

    updatePixels();
  }

  void draw() {
    noLoop();
  }
}
