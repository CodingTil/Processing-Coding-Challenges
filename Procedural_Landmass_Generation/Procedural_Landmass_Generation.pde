import java.lang.Math;

static final int mapChunkSize = 241;

/**
 * temporary
 * clamp between 0 and 6
 */
private int levelOfDetail = 0;

float maxViewDist = 450;
float[][] noiseMap;
PShape map;
Camera cam;

void settings() {
  fullScreen(P3D);
}

void setup() {
  noiseMap = generateNoiseMap(mapChunkSize, 0, 30, 8, 0.5, 2, new PVector(0, 0));

  /*
  MapDisplay mapDisplay = new MapDisplay(noiseMap);
   String[] args = {"MapDisplay"};
   PApplet.runSketch(args, mapDisplay);
   */

  cam = new Camera(0, 0, 10);
  cam.setVelocity(0.5);
  cam.setFluidity(0.4);

  map = generateTerrainMesh(noiseMap, levelOfDetail);
  
  textMode(MODEL);
  textFont(loadFont("BerlinSansFBDemi-Bold-48.vlw"), 48);
}

void draw() {
  background(#96B4FC);
  
  //3D
  lightFalloff(100, 100, 100);
  lights();
  shape(map);
  
  //HUD
  camera();
  hint(DISABLE_DEPTH_TEST);
  fill(#9B21C1);
  text(frameRate, 10, 10 + textAscent());
  text("X:" + cam.pos.x + " Y:" + cam.pos.y, height - 10, 10 + textAscent());
  hint(ENABLE_DEPTH_TEST);
  
  //Camera Update
  cam.update();
}

void keyPressed() {
  cam.keyPressed();
}

void keyReleased() {
  cam.keyReleased();
}
