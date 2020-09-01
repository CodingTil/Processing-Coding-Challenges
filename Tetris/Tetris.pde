import processing.sound.*;

public static final int WIDTH = 549;
public static final int HEIGHT = 672;

public static final long TPS = 750_000; // In nanos

public static final int GRID_OFFSET = 25;

// Everything in this block is relative to the Cell_Size
public static final int GRID_WIDTH = 11;
public static final int GRID_HEIGHT = 22;
public static final int NEXT_WIDTH = 6;
public static final int NEXT_HEIGHT = 4;
public static final int SCORE_WIDTH = 6;
public static final int SCORE_HEIGHT = 1;
public static final int CELL_SIZE = 28;
public static final int NEXT_OFFSET = (GRID_HEIGHT - (NEXT_HEIGHT + 1 + SCORE_HEIGHT)) / 2;

color[] grid;

ArrayList<Integer> removeLines = new ArrayList<Integer>();

color background = color(75);
color removeLine = color(255, 0, 0);
color green = color(0, 164, 80);
color yellow = color(255, 240, 0);
color turquoise = color(3, 175, 238);
color blue = color(48, 49, 143);
color red = color(237, 47, 47);
color orange = color(243, 120, 38);
color violet = color(200, 29, 143);

PFont font;
SoundFile sound;

boolean[] keys = new boolean[4]; // 0 -> Up -> Rotation, 2 -> Left, 3 -> Right, 4 -> Down
boolean[] keysUsed = new boolean[4];

Item currentItem;
Item nextItem;
int itemCount = 0;
int score = 0;
boolean gameOver = false;

int speed = 20;
int speedCount = 0;

void settings() {
  size(WIDTH, HEIGHT);

  createGrid();
  currentItem = randomItem();
  nextItem = randomItem();
}

void setup() {
  font = createFont("Arial", 20, true);
  sound = new SoundFile(this, "Tetris.mp3");
}

Item randomItem() {
  switch((int) random(8)) {
  default:
  case 0: 
    return new L_LEFT(GRID_WIDTH / 2, 0, randomColor());
  case 1: 
    return new L_RIGHT(GRID_WIDTH / 2, 0, randomColor());
  case 2: 
    return new BOX(GRID_WIDTH / 2, 0, randomColor());
  case 3: 
    return new STRAIGHT(GRID_WIDTH / 2, 0, randomColor());
  case 4: 
    return new Z_LEFT(GRID_WIDTH / 2, 0, randomColor());
  case 5: 
    return new Z_RIGHT(GRID_WIDTH / 2, 0, randomColor());
  case 6:
    return new T(GRID_WIDTH / 2, 0, randomColor());
  }
}

color randomColor() {
  switch((int) random(7)) {
  default:
  case 0: 
    return green;
  case 1: 
    return yellow;
  case 2: 
    return turquoise;
  case 3: 
    return blue;
  case 4: 
    return red;
  case 5: 
    return orange;
  case 6: 
    return violet;
  }
}

void draw() {
  if(!sound.isPlaying()) sound.play();
  
  if (!removeLines.isEmpty()) {
    delay(400);
    for (int line : removeLines) {
      for (int px = 0; px < GRID_WIDTH; px++) {
        for (int py = line; py > 0; py--) {
          grid[py * GRID_WIDTH + px] = grid[(py - 1) * GRID_WIDTH + px];
        }
        grid[px] = background;
      }
    }
    removeLines.clear();
  }


  if (!gameOver) {
    delay(50); // 50ms delay;
    speedCount++;

    currentItem.x -= (keys[1] && !keysUsed[1] && doesItemFit(currentItem.shape, currentItem.x - 1, currentItem.y, currentItem.rotation)) ? 1 : 0;
    currentItem.x += (keys[2] && !keysUsed[2] && doesItemFit(currentItem.shape, currentItem.x + 1, currentItem.y, currentItem.rotation)) ? 1 : 0;
    currentItem.y += (keys[3] && !keysUsed[3] && doesItemFit(currentItem.shape, currentItem.x, currentItem.y + 1, currentItem.rotation)) ? 1 : 0;
    currentItem.rotation += (keys[0] && !keysUsed[0] && doesItemFit(currentItem.shape, currentItem.x, currentItem.y, currentItem.rotation + 1)) ? 1 : 0;

    // Reset the keys
    for (int i = 0; i < 4; i++) {
      if (keys[i]) {
        keysUsed[i] = true;
      } else {
        keysUsed[i] = false;
      }
      keys[i] = false;
    }

    if (speedCount == speed) {
      speedCount = 0;
      if (doesItemFit(currentItem.shape, currentItem.x, currentItem.y + 1, currentItem.rotation)) {
        currentItem.y++;
      } else {
        for (int px = 0; px < 4; px++)
          for (int py = 0; py < 4; py++)
            if (currentItem.shape[rotate(px, py, currentItem.rotation)] != false)
              grid[(currentItem.y + py) * GRID_WIDTH + (currentItem.x + px)] = currentItem.c;
        for (int py = 0; py < 4; py++) {
          if (currentItem.y + py < GRID_HEIGHT) {
            boolean line = true;
            for (int px= 0; px < GRID_WIDTH; px++) 
              line &= (grid[(currentItem.y + py) * GRID_WIDTH + px]) != background;
            if (line) {
              for (int px = 0; px < GRID_WIDTH; px++) {
                grid[(currentItem.y + py) * GRID_WIDTH + px] = removeLine;
              }
              removeLines.add(currentItem.y + py);
            }
          }
        }

        score += 25;
        if (!removeLines.isEmpty()) score += (1 << removeLines.size()) * 100;

        currentItem = nextItem;
        nextItem = randomItem();

        gameOver = !doesItemFit(currentItem.shape, currentItem.x, currentItem.y, currentItem.rotation);
      }
    }
  }

  background(30);
  // drawing the grid
  stroke(55);
  strokeWeight(1.3);
  for (int x = 0; x < GRID_WIDTH; x++) {
    for (int y = 0; y < GRID_HEIGHT; y++) {
      fill(grid[y * GRID_WIDTH + x]);
      rect(x * CELL_SIZE + GRID_OFFSET, y * CELL_SIZE + GRID_OFFSET, CELL_SIZE, CELL_SIZE);
    }
  }
  // drawing current item
  for (int px = 0; px < 4; px++)
    for (int py = 0; py < 4; py++)
      if (currentItem.shape[rotate(px, py, currentItem.rotation)] != false) {
        fill(currentItem.c);
        rect((currentItem.x + px) * CELL_SIZE + GRID_OFFSET, (currentItem.y + py) * CELL_SIZE + GRID_OFFSET, CELL_SIZE, CELL_SIZE);
      }
  // drawing the next grid and next item
  stroke(55);
  strokeWeight(1.3);
  for (int x = 0; x < NEXT_WIDTH; x++) {
    for (int y = 0; y < NEXT_HEIGHT; y++) {
      fill(background);
      if (x >= 1 && x <= 4) {
        if (nextItem.shape[rotate(x - 1, y, nextItem.rotation)] != false) {
          fill(nextItem.c);
        }
      }
      rect(x * CELL_SIZE + GRID_OFFSET * 2 + GRID_WIDTH * CELL_SIZE, y * CELL_SIZE + NEXT_OFFSET * CELL_SIZE + GRID_OFFSET, CELL_SIZE, CELL_SIZE);
    }
  }
  // drawing the score field
  fill(background);
  noStroke();
  for (int x = 0; x < SCORE_WIDTH; x++) {
    for (int y = 0; y < SCORE_HEIGHT; y++) {
      rect(x * CELL_SIZE + GRID_OFFSET * 2 + GRID_WIDTH * CELL_SIZE, y * CELL_SIZE + NEXT_OFFSET * CELL_SIZE + NEXT_HEIGHT * CELL_SIZE + CELL_SIZE + GRID_OFFSET, CELL_SIZE, CELL_SIZE);
    }
  }
  // printing score
  textFont(font);
  fill(150);
  noStroke();
  text(score, 5 + GRID_OFFSET * 2 + GRID_WIDTH * CELL_SIZE, CELL_SIZE * 3 / 4 + NEXT_OFFSET * CELL_SIZE + NEXT_HEIGHT * CELL_SIZE + CELL_SIZE + GRID_OFFSET);
}

void keyReleased() {
  onKey();
}

void keyPressed() {
  onKey();
}

void onKey() {
  if (key == CODED) {
    if (keyCode == UP) {
      keys[0] = true;
    }
    if (keyCode == LEFT) {
      keys[1] = true;
    }
    if (keyCode == RIGHT) {
      keys[2] = true;
    }
    if (keyCode == DOWN) {
      keys[3] = true;
    }
  }
}

void createGrid() {
  grid = new color[GRID_WIDTH * GRID_HEIGHT];
  for (int x = 0; x < GRID_WIDTH; x++) {
    for (int y = 0; y < GRID_HEIGHT; y++) {
      grid[y * GRID_WIDTH + x] = background;
    }
  }
}

boolean doesItemFit(boolean[] shape, int x, int y, int rotation) {
  for (int px = 0; px < 4; px++) {
    for (int py = 0; py < 4; py++) {
      int index = rotate(px, py, rotation);
      int fieldIndex = (y + py) * GRID_WIDTH + (x + px);

      if (x + px >= 0 && x + px < GRID_WIDTH) {
        if (y + py >= 0 && y + py < GRID_HEIGHT) {
          if (shape[index] != false &&  grid[fieldIndex] != background) {
            return false;
          }
        } else if (shape[index] != false) {
          return false;
        }
      } else if (shape[index] != false) {
        return false;
      }
    }
  }
  return true;
}

abstract class Item {
  int x, y;
  final boolean[] shape;
  final color c;
  int rotation;

  Item(int x, int y, boolean[] shape, color c) {
    this(x, y, shape, 0, c);
  }

  Item(int x, int y, boolean[] shape, int rotation, color c) {
    this.shape = shape;
    this.rotation = rotation;
    this.c = c;
  }

  void rotateShape() {
    rotation = (rotation + 1) % 4;
  }
}

int rotate(int px, int py, int r) {
  int pi = 0;
  switch (r % 4) {
  case 0:     
    pi = py * 4 + px;
    break;
  case 1:
    pi = 12 + py - (px * 4);
    break;
  case 2:
    pi = 15 - (py * 4) - px;
    break;
  case 3:
    pi = 3 - py + (px * 4);
    break;
  }

  return pi;
}

class L_LEFT extends Item {
  L_LEFT(int x, int y, color c) {
    super(x, y, new boolean[] 
      {false, false, false, false, 
      false, true, true, false, 
      false, false, true, false, 
      false, false, true, false}, c);
  }
}

class L_RIGHT extends Item {
  L_RIGHT(int x, int y, color c) {
    super(x, y, new boolean[] 
      {false, false, false, false, 
      false, true, true, false, 
      false, true, false, false, 
      false, true, false, false}, c);
  }
}

class BOX extends Item {
  BOX(int x, int y, color c) {
    super(x, y, new boolean[] 
      {false, false, false, false, 
      false, true, true, false, 
      false, true, true, false, 
      false, false, false, false}, c);
  }
}

class STRAIGHT extends Item {
  STRAIGHT(int x, int y, color c) {
    super(x, y, new boolean[] 
      {false, false, true, false, 
      false, false, true, false, 
      false, false, true, false, 
      false, false, true, false}, c);
  }
}

class T extends Item {
  T(int x, int y, color c) {
    super(x, y, new boolean[] 
      {false, false, false, false, 
      false, true, false, false, 
      true, true, true, false, 
      false, false, false, false}, c);
  }
}

class Z_LEFT extends Item {
  Z_LEFT(int x, int y, color c) {
    super(x, y, new boolean[] 
      {false, true, false, false, 
      false, true, true, false, 
      false, false, true, false, 
      false, false, false, false}, c);
  }
}

class Z_RIGHT extends Item {
  Z_RIGHT(int x, int y, color c) {
    super(x, y, new boolean[] 
      {false, false, true, false, 
      false, true, true, false, 
      false, true, false, false, 
      false, false, false, false}, c);
  }
}
