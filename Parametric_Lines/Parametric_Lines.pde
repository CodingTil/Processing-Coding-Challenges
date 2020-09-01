private static final int LINES = 40;
private static final float INCREMENT = 0.5;
private static final int WINDOW_SIZE = 800;
private static final int STROKE = 200;

float t;

void settings() {
  size(WINDOW_SIZE, WINDOW_SIZE);
  t = 0;
}

void setup() {
  frameRate(60);
}

void draw() {
  background(50);
  strokeWeight(4);
  translate(WINDOW_SIZE / 2, WINDOW_SIZE / 2);
  for(int line = 0; line < LINES; line++) {
     line(x1(t + line),  x2(t + line), x2(t + line),  y2(t + line));
     stroke(STROKE, STROKE - (line * ((float) STROKE)/LINES));
  }
  t -= INCREMENT;
}

float x1(float t) {
  return sin(t / 30) * 150 + sin(t / 15) * 100;
}

float y1(float t) {
  return cos(t / 15) * 150 + cos(t / 15) * 200;
}

float x2(float t) {
  return sin(t / 10) * 100 + sin(t / 20) * 200;
}

float y2(float t) {
  return cos(t / 15) * 100 + cos(t / 15) * 200;
}
