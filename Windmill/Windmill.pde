public static int SIZE = 20;
public static ArrayList<Point> points = new ArrayList<Point>();

public static double CIRCLE_RADIUS = 1.5;
public static int CIRCLE_RADIUS_RENDERING = 10;
public static color CIRCLE_COLOR = #FFCC00;

public static double ANGLE = 0.0005;

public static int WIDTH = 1080;
public static int HEIGHT = 720;

public static Point pointOfRotation;
public static Point lastPointOfRotation;
public static double rotation;

Line line;

void settings() {
  createPoints();
  pointOfRotation = points.get(0);
  lastPointOfRotation = pointOfRotation;
  line = getLine(pointOfRotation, radians((float) rotation));
  rotation = 0;
  size(WIDTH, HEIGHT);
}

void setup() {
  frameRate(60); 
}

void draw() {
  background(50);
  stroke(0);
  for (Point p : points) {
    fill(CIRCLE_COLOR);
    if(p == pointOfRotation) fill(color(255, 0, 0));
    p.drawCircle();
  }
  
  stroke(color(0, 254, 1));
  for(int i = 0; i < 6; i++) {
    Point newPoint = getNextPoint(line);
    if(newPoint != pointOfRotation && newPoint != lastPointOfRotation) {
      lastPointOfRotation = pointOfRotation;
      pointOfRotation = newPoint;
    }
    line = getLine(pointOfRotation, (float) rotation);
    rotation += ANGLE;
  }
  line.drawLine();
}

void createPoints() {
  points.add(new Point(WIDTH / 2, HEIGHT / 2));

  for (int i = 1; i < SIZE; i++) {
    Point point;
    do {
      point = new Point((int) (WIDTH * 0.8 * random(1f) + WIDTH * 0.1), (int) (HEIGHT * 0.8 * random(1f) + HEIGHT * 0.1));
    } while (points.contains(point) || isColinear(point));
    points.add(point);
  }
}

Point getNextPoint(Line line) {
   loop: for(Point p : points) {
      if(p == pointOfRotation || p == lastPointOfRotation) continue loop;
      if(checkCollision(p, line)) return p;
   }
   return pointOfRotation;
}

Line getLine(Point point, float rotation) {
  int x1 = (int) (point.x + tan(rotation) * point.y);
  int y1 = 0;
  int x2 = (int) (point.x - tan(rotation) * (HEIGHT - point.y));
  int y2 = HEIGHT;
  
  if(x1 < 0) {
     x1 = 0;
     y1 = (int) (point.y - tan(rotation - 1.5 * PI) * point.x);
  }
  if(x1 > WIDTH) {
     x1 = WIDTH;
     y1 = (int) (point.y - tan(0.5 * PI - rotation) * (WIDTH - point.x));
  }
  if(x2 < 0) {
     x2 = 0;
     y2 = (int) (point.y + tan(0.5 * PI - rotation) * point.x);
  }
  if(x2 > WIDTH) {
    x2 = WIDTH;
    y2 = (int) (point.y + tan(rotation - 1.5 * PI) * (WIDTH - point.x));
  }
  return new Line(x1, y1, x2, y2);
}

boolean isColinear(Point point) {
  if (points.size() < 2) return false;
  for (Point p1 : points) {
    for (Point p2 : points) {
      if (p1 == p2) break;
      int a = point.x * (p1.y - p2.y) + p1.x * (p2.y - point.y) + p2.x * (point.y - p1.y);
      if (a == 0) return true;
    }
  }
  return false;
}

boolean checkCollision(Point point, Line line) {
  /*return (Math.abs(
          (line.x2 - line.x1) * point.x
        + (line.y1 - line.y2) * point.y
        + (line.x1 - line.x2) * line.y1
        + (line.y2 - line.y1) * line.x1)
        / Math.sqrt(Math.pow(line.x2 - line.x1, 2) + Math.pow(line.y1 - line.y2, 2))) <= CIRCLE_RADIUS;*/

  double deltaX = line.x2 - line.x1;
  double deltaY = line.y2 - line.y1;
  double a = deltaX * deltaX + deltaY * deltaY;
  double b = 2 * (deltaX * (line.x1 - point.x) + deltaY * (line.y1 - point.y));
  double c = (line.x1 - point.x) * (line.x1 - point.x) + (line.y1 - point.y) * (line.y1 - point.y) - CIRCLE_RADIUS * CIRCLE_RADIUS;
  double discriminant = b * b - 4 * a * c;
  
  if(discriminant < 0) return false;
  
  double quad1 = (-b + Math.sqrt(discriminant))/(2 * a);
  double quad2 = (-b - Math.sqrt(discriminant))/(2 * a);
  
  if(quad1 >= 0 && quad1 <= 1) return true;
  if(quad2 >= 0 && quad2 <= 1) return true;
  return false;
}

class Point {
  int x, y;

  public Point(int x, int y) {
    this.x = x;
    this.y = y;
  }

  public void drawCircle() {
    circle(x, y, CIRCLE_RADIUS_RENDERING);
  }
}

class Line {
  int x1, y1, x2, y2;
  public Line(int x1, int y1, int x2, int y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }

  public void drawLine() {
    line(x1, y1, x2, y2);
  }
}
