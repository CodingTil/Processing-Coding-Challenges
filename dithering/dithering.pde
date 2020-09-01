PImage original;
PImage dithered;
int factor = 1;

void settings() {
  original = loadImage("baby_yoda.jpg");
  size(original.width, original.height * 2);
}

void setup() {
  dithered = dither(original.copy(), factor);
  image(original, 0, 0);
  image(dithered, 0, original.height);
}

PImage dither(PImage image, int factor) {
  image.loadPixels();
  for (int y = 0; y < image.height - 1; y++) {
    for (int x = 1; x < image.width - 1; x++) {
      int index = index(x, y, image.width);
      color oldPixel = image.pixels[index];
      color newPixel = findClosest(oldPixel, factor);
      image.pixels[index] = newPixel;
      
      color error = calcError(oldPixel, newPixel);
      image.pixels[index(x + 1, y, image.width)] = addColor(image.pixels[index(x + 1, y, image.width)], scalarColor(error, 7f/16f));
      image.pixels[index(x - 1, y + 1, image.width)] = addColor(image.pixels[index(x - 1, y + 1, image.width)], scalarColor(error, 3f/16f));
      image.pixels[index(x, y + 1, image.width)] = addColor(image.pixels[index(x, y + 1, image.width)], scalarColor(error, 5f/16f));
      image.pixels[index(x + 1, y + 1, image.width)] = addColor(image.pixels[index(x + 1, y + 1, image.width)], scalarColor(error, 1f/16f));
    }
  }
  image.updatePixels();

  return image;
}

color findClosest(color c, int factor) {
  float r = red(c);
  float g = green(c);
  float b = blue(c);

  r = round(factor * r / 255) * (255 / factor);
  g = round(factor * g / 255) * (255 / factor);
  b = round(factor * b / 255) * (255 / factor);

  return color(r, g, b);
}

color calcError(color original, color copy) {
  float r = red(original) - red(copy);
  float g = green(original) - green(copy);
  float b = blue(original) - blue(copy);
  return color(r, g, b);
}

color scalarColor(color c, float scalar) {
  float r = red(c);
  float g = green(c);
  float b = blue(c);

  r *= scalar;
  g *= scalar;
  b *= scalar;

  return color(r, g, b);
}

color addColor(color c1, color c2) {
  float r = red(c1) + red(c2);
  float g = green(c1) + green(c2);
  float b = blue(c1) + blue(c2);
  return color(r, g, b);
}

int index(int x, int y, int width) {
  return y * width + x;
}
