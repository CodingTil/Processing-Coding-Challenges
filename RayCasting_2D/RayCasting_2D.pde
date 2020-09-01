import java.util.Collections;
import java.util.Comparator;

public static final int CELL_SIZE = 20;
public static final int GRID_WIDTH = 54;
public static final int GRID_HEIGHT = 36;

public static final int TOP_EDGE_ID = 0;
public static final int LEFT_EDGE_ID = 1;
public static final int BOTTOM_EDGE_ID = 2;
public static final int RIGHT_EDGE_ID = 3;

public static final double ANGLE_OFFSET = 0.001;

public static Cell[][] grid = new Cell[GRID_WIDTH][GRID_HEIGHT];
public static ArrayList<Edge> edges = new ArrayList<Edge>();

public static PVector lightSource = new PVector(0, 0);
public static ArrayList<PVector> lightPoints = new ArrayList<PVector>(); // x = x-location, y = y-location, z = angle;

color cell_color = color(5, 5, 250);
color edge_color = color(5, 250, 250);
color light_color = color(255, 255, 224);

boolean drawEdges = false;
boolean drawLight = false;

void settings() {
  createGrid();
  createEdges();
  size(CELL_SIZE * GRID_WIDTH, CELL_SIZE * GRID_HEIGHT);
}

void setup() {
  frameRate(60);
}

void draw() {
  System.out.println(frameRate);
  
  if ((mouseX > CELL_SIZE) && (mouseX <= GRID_WIDTH * CELL_SIZE) && (mouseY > CELL_SIZE) && (mouseY <= GRID_HEIGHT * CELL_SIZE)) {
    drawLight = true;
    lightSource.x = mouseX;
    lightSource.y = mouseY;
    createLightPoints(100);
  } else {
    drawLight = false;
  }

  background(50);
  if (drawLight) {
    noStroke();
    fill(light_color);
    for (int i = 0; i < lightPoints.size() - 1; i++) {
      PVector v1 = lightPoints.get(i);
      PVector v2 = lightPoints.get(i + 1);
      triangle(lightSource.x, lightSource.y, v1.x, v1.y, v2.x, v2.y);
    }
    PVector v1 = lightPoints.get(0);
    PVector v2 = lightPoints.get(lightPoints.size() - 1);
    triangle(lightSource.x, lightSource.y, v1.x, v1.y, v2.x, v2.y);
  }
  stroke(0);
  for (int x = 0; x < GRID_WIDTH; x++) {
    for (int y = 0; y < GRID_HEIGHT; y++) {
      grid[x][y].drawCell();
    }
  }
  if (drawEdges) {
    for (Edge edge : edges) {
      edge.drawEdge();
    }
  }
}

void keyTyped() {
  if (key == 'e' || key == 'E') {
    drawEdges = !drawEdges;
  }
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    int x = mouseX / CELL_SIZE;
    int y = mouseY / CELL_SIZE;
    if (x != 0 && x != GRID_WIDTH - 1 && y != 0 && y != GRID_HEIGHT - 1) {
      grid[x][y].setActive(true);
      createEdges();
    }
  } else if (mouseButton == RIGHT) {
    int x = mouseX / CELL_SIZE;
    int y = mouseY / CELL_SIZE;
    if (x != 0 && x != GRID_WIDTH - 1 && y != 0 && y != GRID_HEIGHT - 1) {
      grid[x][y].setActive(false);
      createEdges();
    }
  }
}

void createGrid() {
  for (int x = 0; x < GRID_WIDTH; x++) {
    for (int y = 0; y < GRID_HEIGHT; y++) {
      boolean active = false;
      if (x == 0) {
        active = true;
      }
      if (x == GRID_WIDTH - 1) {
        active = true;
      }
      if (y == 0) {
        active = true;
      }
      if (y == GRID_HEIGHT - 1) {
        active = true;
      }
      grid[x][y] = new Cell(x, y, active, cell_color);
    }
  }
}

void createEdges() {
  // Clear everything edge related
  edges.clear();
  for (int y = 0; y < GRID_HEIGHT; y++) {
    for (int x = 0; x < GRID_WIDTH; x++) {
      grid[x][y].edgeIndices = new int[]{-1, -1, -1, -1};
    }
  }

  /*
  // Adding outer grid edges
   Edge topEdge = new Edge(0, 0, GRID_WIDTH, true, edge_color);
   edges.add(topEdge);
   int topEdgeID = edges.indexOf(topEdge);
   for (int x = 0; x < GRID_WIDTH; x++) {
   grid[x][0].edgeIndices[TOP_EDGE_ID] = topEdgeID;
   }
   
   Edge leftEdge = new Edge(0, 0, GRID_HEIGHT, false, edge_color);
   edges.add(leftEdge);
   int leftEdgeID = edges.indexOf(leftEdge);
   for (int y = 0; y < GRID_HEIGHT; y++) {
   grid[0][y].edgeIndices[LEFT_EDGE_ID] = leftEdgeID;
   }
   
   Edge bottomEdge = new Edge(0, GRID_HEIGHT + 1, GRID_WIDTH, true, edge_color);
   edges.add(bottomEdge);
   int bottomEdgeID = edges.indexOf(bottomEdge);
   for (int x = 0; x < GRID_WIDTH; x++) {
   grid[x][GRID_HEIGHT - 1].edgeIndices[BOTTOM_EDGE_ID] = bottomEdgeID;
   }
   
   Edge rightEdge = new Edge(GRID_WIDTH + 1, 0, GRID_HEIGHT, false, edge_color);
   edges.add(rightEdge);
   int rightEdgeID = edges.indexOf(rightEdge);
   for (int y = 0; y < GRID_HEIGHT; y++) {
   grid[GRID_WIDTH - 1][y].edgeIndices[RIGHT_EDGE_ID] = rightEdgeID;
   }
   */


  // Adding inner edges
  for (int y = 0; y < GRID_HEIGHT; y++) {
    for (int x = 0; x < GRID_WIDTH; x++) {

      if (grid[x][y].active) {
        if (y > 0) {
          if (!grid[x][y - 1].active) {
            if (grid[x - 1][y].edgeIndices[TOP_EDGE_ID] != -1) {
              int index = grid[x - 1][y].edgeIndices[TOP_EDGE_ID];
              edges.get(index).addExtentionFactor();
              grid[x][y].edgeIndices[TOP_EDGE_ID] = index;
              grid[x][y - 1].edgeIndices[BOTTOM_EDGE_ID] = index;
            } else {
              Edge edge = new Edge(x, y, 1, true, edge_color);
              edges.add(edge);
              grid[x][y].edgeIndices[TOP_EDGE_ID] = edges.indexOf(edge);
              grid[x][y - 1].edgeIndices[BOTTOM_EDGE_ID] = edges.indexOf(edge);
            }
          }
        }

        if (x > 0) {
          if (!grid[x - 1][y].active) {
            if (grid[x][y - 1].edgeIndices[LEFT_EDGE_ID] != -1) {
              int index = grid[x][y - 1].edgeIndices[LEFT_EDGE_ID];
              edges.get(index).addExtentionFactor();
              grid[x][y].edgeIndices[LEFT_EDGE_ID] = index;
              grid[x - 1][y].edgeIndices[RIGHT_EDGE_ID] = index;
            } else {
              Edge edge = new Edge(x, y, 1, false, edge_color);
              edges.add(edge);
              grid[x][y].edgeIndices[LEFT_EDGE_ID] = edges.indexOf(edge);
              grid[x - 1][y].edgeIndices[RIGHT_EDGE_ID] = edges.indexOf(edge);
            }
          }
        }

        if (y < GRID_HEIGHT - 1) {
          if (!grid[x][y + 1].active) {
            if (grid[x - 1][y].edgeIndices[BOTTOM_EDGE_ID] != -1) {
              int index = grid[x - 1][y].edgeIndices[BOTTOM_EDGE_ID];
              edges.get(index).addExtentionFactor();
              grid[x][y].edgeIndices[BOTTOM_EDGE_ID] = index;
              grid[x][y + 1].edgeIndices[TOP_EDGE_ID] = index;
            } else {
              Edge edge = new Edge(x, y + 1, 1, true, edge_color);
              edges.add(edge);
              grid[x][y].edgeIndices[BOTTOM_EDGE_ID] = edges.indexOf(edge);
              grid[x][y + 1].edgeIndices[TOP_EDGE_ID] = edges.indexOf(edge);
            }
          }
        }

        if (x < GRID_WIDTH - 1) {
          if (!grid[x + 1][y].active) {
            if (grid[x][y - 1].edgeIndices[RIGHT_EDGE_ID] != -1) {
              int index = grid[x][y - 1].edgeIndices[RIGHT_EDGE_ID];
              edges.get(index).addExtentionFactor();
              grid[x][y].edgeIndices[RIGHT_EDGE_ID] = index;
              grid[x + 1][y].edgeIndices[LEFT_EDGE_ID] = index;
            } else {
              Edge edge = new Edge(x + 1, y, 1, false, edge_color);
              edges.add(edge);
              grid[x][y].edgeIndices[RIGHT_EDGE_ID] = edges.indexOf(edge);
              grid[x + 1][y].edgeIndices[LEFT_EDGE_ID] = edges.indexOf(edge);
            }
          }
        }
      }
    }
  }
}

void createLightPoints(double radius) {
  lightPoints.clear();

  for (Edge edge : edges) {
    // One Ray for each endpoint of the edge
    for (int i = 0; i < 2; i++) {
      double rdx, rdy;
      if (i == 0) {
        rdx = edge.x * CELL_SIZE - lightSource.x;
        rdy = edge.y * CELL_SIZE - lightSource.y;
      } else {
        PVector x2y2 = edge.getX2Y2();
        rdx = x2y2.x * CELL_SIZE - lightSource.x;
        rdy = x2y2.y * CELL_SIZE - lightSource.y;
      }
      double base_angle = atan2((float) rdy, (float) rdx);

      double angle = 0;
      // 3 similar Rays for each endpoint of the edge
      for (int j = 0; j < 3; j++) {
        if (j == 0) angle = base_angle - ANGLE_OFFSET;
        if (j == 1) angle = base_angle;
        if (j == 2) angle = base_angle + ANGLE_OFFSET;

        rdx = radius * cos((float) angle);
        rdy = radius * sin((float) angle);

        double min_t1 = Double.POSITIVE_INFINITY;
        double min_px = 0, min_py = 0, min_angle = 0;
        boolean bValid = false;

        // Check if the ray intersects with any edge
        for (Edge e : edges) {
          PVector x2y2 = e.getX2Y2();
          double sdx = x2y2.x * CELL_SIZE - e.x * CELL_SIZE;
          double sdy = x2y2.y * CELL_SIZE - e.y * CELL_SIZE;

          if (abs((float) (sdx - rdx)) > 0.0f && abs((float) (sdy - rdy)) > 0.0f) {
            double t2 = (rdx * (e.y * CELL_SIZE - lightSource.y) + (rdy * (lightSource.x - e.x * CELL_SIZE))) / (sdx * rdy - sdy * rdx);
            double t1 = (e.x * CELL_SIZE + sdx * t2 - lightSource.x) / rdx;

            if (t1 > 0 && t2 >= 0 && t2 <= 1d) {
              if (t1 < min_t1) {
                min_t1 = t1;
                min_px = lightSource.x + rdx * t1;
                min_py = lightSource.y + rdy * t1;
                min_angle = atan2((float) (min_py - lightSource.y), (float) (min_px - lightSource.x));
                bValid = true;
              }
            }
          }
        }
        if (bValid)
          lightPoints.add(new PVector((float) min_px, (float) min_py, (float) min_angle));
      }
    }
  }
  Collections.sort(lightPoints, new Comparator<PVector>() {
    @Override
      public int compare(PVector a, PVector b) {
      return Float.compare(a.z, b.z);
    }
  }
  );
}

class Cell {
  int x, y;
  boolean active;
  color c;
  int[] edgeIndices = {-1, -1, -1, -1};

  Cell(int x, int y, boolean active, color c) {
    this.x = x;
    this.y = y;
    this.active = active;
    this.c = c;
  }

  void setActive(boolean active) {
    this.active = active;
  }

  void drawCell() {
    if (active) {
      fill(c);
      rect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE);
    }
  }
}

class Edge {
  int x, y, extentionFactor;
  boolean direction; // true = horizontal, false = vertical
  color c;

  Edge(int x, int y, int extentionFactor, boolean direction, color c) {
    this.x = x;
    this.y = y;
    this.extentionFactor = extentionFactor;
    this.direction = direction;
    this.c = c;
  }

  void addExtentionFactor() {
    extentionFactor++;
  }

  void drawEdge() {
    stroke(c);
    if (direction == true) {
      line(x * CELL_SIZE, y * CELL_SIZE, (x + extentionFactor) * CELL_SIZE, y * CELL_SIZE);
    } else {
      line(x * CELL_SIZE, y * CELL_SIZE, x * CELL_SIZE, (y + extentionFactor) * CELL_SIZE);
    }
  }

  PVector getX2Y2() {
    int xP, yP;
    if (direction == true) {
      xP = x + extentionFactor;
      yP = y;
    } else {
      xP = x;
      yP = y + extentionFactor;
    }
    return new PVector(xP, yP);
  }
}
