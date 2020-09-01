float a = 0;
Box b;
ArrayList<Box> sponge;
void setup() {
  size(800, 800, P3D);
  b = new Box(0, 0, 0, 200);
  sponge = new ArrayList<Box>();
  sponge.add(b);
}

void draw() {
  background(50);
   stroke(255);
   fill(250);
   lights();
   
   translate(width/2, height/2);
   rotateX(a);
   rotateY(a * 0.4);
   rotateZ(a * 0.1);
   for(Box b : sponge) {
      b.show();
   }
   
   a += 0.01;
}

void mousePressed() {
   ArrayList<Box> next = new ArrayList<Box>();
   for(Box b : sponge) {
      ArrayList<Box> newBoxes = b.generate();
      next.addAll(newBoxes);
   }
   sponge = next;
}
