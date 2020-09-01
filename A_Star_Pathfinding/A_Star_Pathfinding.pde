import java.util.*;

public static final int GRID_WIDTH = 72;
public static final int GRID_HEIGHT = 48;
public static final int CELL_SIZE = 15;

Cell[][] grid = new Cell[GRID_WIDTH][GRID_HEIGHT];

ArrayList<Node> open = new ArrayList<Node>();
ArrayList<Node> closed = new ArrayList<Node>();

color color_empty = color(255, 255, 255);
color color_start = color(5, 250, 250);
color color_end = color(5, 5, 245);
color color_green = color(5, 245, 5);
color color_used = color(245, 5, 5);
color color_wall = color(20, 20, 60);

UIState state = UIState.EDIT;

double mx, my;
boolean mouseOverGrid = false;

boolean editingWalls = false;
boolean solutionFound = true;

int startX = 3, startY = 3, endX = GRID_WIDTH - 3, endY = GRID_HEIGHT - 3;

enum CellState {
  EMPTY, START, END, GREEN, USED, WALL;
}

enum UIState {
  EDIT, FAST_RUN, SLOW_RUN;
}

void settings() {
  createGrid();
  size(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE);
}

void draw() {
  if (state == UIState.SLOW_RUN && !solutionFound) {
    iter();
  }

  if (mouseX > 0 && mouseX < GRID_WIDTH * CELL_SIZE && mouseY > 0 && mouseY < GRID_HEIGHT * CELL_SIZE) {
    mouseOverGrid = true;
  } else {
    mouseOverGrid = false;
  }

  background(50);
  stroke(50);
  strokeWeight(1);
  for (int x = 0; x < GRID_WIDTH; x++) {
    for (int y = 0; y < GRID_HEIGHT; y++) {
      grid[x][y].drawCell();
    }
  }
}

void keyPressed() {
  if (state == UIState.EDIT) {
    if (mouseOverGrid) {
      if (key == 's' || key == 'S') {
        int x = (int) mouseX / CELL_SIZE;
        int y = (int) mouseY / CELL_SIZE;
        if (grid[x][y].state == CellState.EMPTY) {
          grid[startX][startY].state = CellState.EMPTY;
          grid[x][y].state = CellState.START;
          startX = x;
          startY = y;
          return;
        }
      } else if (key == 'e' || key == 'E') {
        int x = (int) mouseX / CELL_SIZE;
        int y = (int) mouseY / CELL_SIZE;
        if (grid[x][y].state == CellState.EMPTY) {
          grid[endX][endY].state = CellState.EMPTY;
          grid[x][y].state = CellState.END;
          endX = x;
          endY = y;
          return;
        }
      }
    }

    if (key == 'f' || key == 'F') {
      state = UIState.FAST_RUN;
      prepareA_star();
      while (!solutionFound) iter();
      return;
    } else if (key == ' ') {
      state = UIState.SLOW_RUN;
      prepareA_star();
      return;
    }
  } else {
    reset();
  }
}

void mousePressed() {
  if (state == UIState.EDIT && mouseOverGrid) {
    editingWalls = true;
  }
}

void mouseDragged() {
  if (editingWalls) {
    mx = mouseX; 
    my = mouseY;
    int x = (int) mx / CELL_SIZE;
    int y = (int) my / CELL_SIZE;
    if (x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT) {
      if (mouseButton == LEFT) {
        if (grid[x][y].state == CellState.EMPTY) {
          grid[x][y].state = CellState.WALL;
        }
      } else if (mouseButton == RIGHT) {
        if (grid[x][y].state == CellState.WALL) {
          grid[x][y].state = CellState.EMPTY;
        }
      }
    }
  }
}

void mouseReleased() {
  editingWalls = false;
}

void createGrid() {
  for (int x = 0; x < GRID_WIDTH; x++) {
    for (int y = 0; y < GRID_HEIGHT; y++) {
      grid[x][y] = new Cell(x, y, CellState.EMPTY);
    }
  }
  grid[startX][startY].state = CellState.START;
  grid[endX][endY].state = CellState.END;
}

void prepareA_star() {
  open.clear();
  closed.clear();
  open.add(new Node(grid[startX][startY], 0, 0));
}

void reset() {
  state = UIState.EDIT;
  solutionFound = false;
  grid[startX][startY].state = CellState.START;
  grid[endX][endY].state = CellState.END;
  for (int x = 0; x < GRID_WIDTH; x++) {
    for (int y = 0; y < GRID_HEIGHT; y++) {
      if (grid[x][y].state == CellState.GREEN || grid[x][y].state == CellState.USED) {
        grid[x][y].state = CellState.EMPTY;
      }
    }
  }
}

void iter() {
  Node current = getLowestF_Cost();
  open.remove(current);
  closed.add(current);
  if (current.cell.state == CellState.END) {
    solutionFound = true;
    System.out.println("Solution found");
    return;
  }
  if (current.cell.state != CellState.START || current.cell.state != CellState.END)
    current.cell.state = CellState.USED;

  for (Cell neighbour : getNeighbours(current.cell)) {
    double newMovementCost = current.g_cost + dist(current.cell, neighbour);
    Node node = openListContainsCell(neighbour);
    if (node == null) {
      node = new Node(neighbour);
      open.add(node);
      node.g_cost = newMovementCost;
      node.h_cost = dist(neighbour, grid[endX][endY]);
      ;
      if (neighbour.state == CellState.EMPTY)
        neighbour.state = CellState.GREEN;
    } else if (newMovementCost < node.g_cost) {
      node.g_cost = newMovementCost;
      node.h_cost = dist(neighbour, grid[endX][endY]);
    }
  }
}

double dist(Cell c1, Cell c2) {
  double a = abs(c1.x - c2.x);
  double b = abs(c1.y - c2.y);
  double min, max;
  if (a > b) {
    min = b;
    max = a;
  } else {
    min = a;
    max = b;
  }
  return sqrt(2) * min + (max - min);
}

Node openListContainsCell(Cell cell) {
  for (Node node : open) {
    if (node.cell == cell) return node;
  }
  return null;
}

Node getLowestF_Cost() {
  Node lowest = null;
  double f = Double.POSITIVE_INFINITY;

  for (Node node : open) {
    if (node.f_cost() < f) {
      lowest = node;
      f = node.f_cost();
    }
  }

  return lowest;
}

ArrayList<Cell> getNeighbours(Cell cell) {
  ArrayList<Cell> list = new ArrayList<Cell>();
  int x = cell.x;
  int y = cell.y;
  if (x == 0) {
    if (y == 0) {
      addEmptyCellToList(grid[1][0], list);
      addEmptyCellToList(grid[1][1], list);
      addEmptyCellToList(grid[0][1], list);
    } else if (y == GRID_HEIGHT - 1) {
      addEmptyCellToList(grid[0][GRID_HEIGHT - 2], list);
      addEmptyCellToList(grid[1][GRID_HEIGHT - 2], list);
      addEmptyCellToList(grid[1][GRID_HEIGHT - 1], list);
    } else {
      addEmptyCellToList(grid[0][y - 1], list);
      addEmptyCellToList(grid[1][y - 1], list);
      addEmptyCellToList(grid[1][y], list);
      addEmptyCellToList(grid[1][y + 1], list);
      addEmptyCellToList(grid[0][y + 1], list);
    }
  } else if (x == GRID_WIDTH - 1) {
    if (y == 0) {
      addEmptyCellToList(grid[GRID_WIDTH - 2][0], list);
      addEmptyCellToList(grid[GRID_WIDTH - 2][1], list);
      addEmptyCellToList(grid[GRID_WIDTH - 1][1], list);
    } else if (y == GRID_HEIGHT - 1) {
      addEmptyCellToList(grid[GRID_WIDTH - 1][GRID_HEIGHT - 2], list);
      addEmptyCellToList(grid[GRID_WIDTH - 2][GRID_HEIGHT - 2], list);
      addEmptyCellToList(grid[GRID_WIDTH - 2][GRID_HEIGHT - 1], list);
    } else {
      addEmptyCellToList(grid[GRID_WIDTH - 1][y - 1], list);
      addEmptyCellToList(grid[GRID_WIDTH - 2][y - 1], list);
      addEmptyCellToList(grid[GRID_WIDTH - 2][y], list);
      addEmptyCellToList(grid[GRID_WIDTH - 2][y + 1], list);
      addEmptyCellToList(grid[GRID_WIDTH - 1][y + 1], list);
    }
  } else {
    if (y == 0) {
      addEmptyCellToList(grid[x - 1][0], list);
      addEmptyCellToList(grid[x - 1][1], list);
      addEmptyCellToList(grid[x][1], list);
      addEmptyCellToList(grid[x + 1][1], list);
      addEmptyCellToList(grid[x + 1][0], list);
    } else if (y == GRID_HEIGHT - 1) {
      addEmptyCellToList(grid[x - 1][GRID_HEIGHT - 1], list);
      addEmptyCellToList(grid[x - 1][GRID_HEIGHT - 2], list);
      addEmptyCellToList(grid[x][GRID_HEIGHT - 2], list);
      addEmptyCellToList(grid[x + 1][GRID_HEIGHT - 2], list);
      addEmptyCellToList(grid[x + 1][GRID_HEIGHT - 1], list);
    } else {
      addEmptyCellToList(grid[x - 1][y - 1], list);
      addEmptyCellToList(grid[x][y - 1], list);
      addEmptyCellToList(grid[x + 1][y - 1], list);
      addEmptyCellToList(grid[x + 1][y], list);
      addEmptyCellToList(grid[x + 1][y + 1], list);
      addEmptyCellToList(grid[x][y + 1], list);
      addEmptyCellToList(grid[x - 1][y + 1], list);
      addEmptyCellToList(grid[x - 1][y], list);
    }
  }
  return list;
}

void addEmptyCellToList(Cell cell, ArrayList<Cell> list) {
  if (cell.state != CellState.WALL) {
    list.add(cell);
  }
}

public class Cell {
  int x, y;
  CellState state;

  public Cell(int x, int y, CellState state) {
    this.x = x;
    this.y = y;
    this.state = state;
  }

  void drawCell() {
    switch(state) {
    case EMPTY:
      fill(color_empty);
      break;
    case START:
      fill(color_start);
      break;
    case END:
      fill(color_end);
      break;
    case GREEN:
      fill(color_green);
      break;
    case USED:
      fill(color_used);
      break;
    case WALL:
      fill(color_wall);
      break;
    default:
      fill(color_empty);
      break;
    }
    rect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE);
  }
}

class Node {
  Cell cell;
  double g_cost;
  double h_cost;

  Node(Cell cell) {
    this(cell, Double.POSITIVE_INFINITY, Double.POSITIVE_INFINITY);
  }

  Node(Cell cell, double g_cost, double h_cost) {
    this.cell = cell;
    this.g_cost = g_cost;
    this.h_cost = h_cost;
  }

  double f_cost() {
    return g_cost + h_cost;
  }
}
