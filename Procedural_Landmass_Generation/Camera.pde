import java.awt.Robot;
 
class Camera{
 
  public PVector pos;
 
  private Robot robot;
  private PVector vel, acc, normLR, normFB, facing;
  private float horizontalAngle, verticalAngle;
  private float centerX, centerY, centerZ;
  private boolean left, right, forward, backwards, up, down;
 
  private float velocity = 0.2;
  private float fluidity = 0.9;
 
  Camera(int x, int y, int z){
    this.pos = new PVector();     //Camera position
    this.vel = new PVector();     //Camera velocity
    this.acc = new PVector();     //Camera acceleration
 
    this.facing = new PVector();  //Facing direction
    this.normLR = new PVector();  //Local x axis (Left and Right movement)
    this.normFB = new PVector();  //Local y axis (Forward and Backwards movement)
 
    this.pos.x = x; //Starting position given by arguments
    this.pos.y = y;
    this.pos.z = z;
 
    try{
      this.robot = new Robot();
    }catch(Exception e){}
 
    perspective(PI/3.0, (float) width/height, 0.001, 10000);
    noCursor();
  }
 
  public void update(){
 
    //CAMERA MOTION IN 3D SPACE
    if(left)
      this.acc.sub(normLR);
    if(right)
      this.acc.add(normLR);
    if(forward)
      this.acc.sub(normFB);
    if(backwards)
      this.acc.add(normFB);
    if(down)
      this.acc.z -= 1;
    if(up)
      this.acc.z += 1;
 
    if(up == false && down == false && left == false && right == false && forward == false && backwards == false){
      this.acc.mult(fluidity * 0.1);
      this.vel.mult(fluidity); 
    }
 
    this.acc.limit(velocity * 0.1);
    this.vel.add(acc);
    this.vel.limit(velocity);
    this.pos.add(this.vel);
 
    //CAMERA FACING
    this.robot.mouseMove((int)getWindowLocation().x + width/2, (int)getWindowLocation().y + height/2);
    pmouseX = width/2;
    pmouseY = height/2;
 
    this.horizontalAngle += (mouseX - pmouseX) * 0.0021;
    this.verticalAngle += (mouseY - pmouseY) * 0.0021;
 
    if(this.verticalAngle < -PI + 0.1)
      this.verticalAngle = -PI + 0.1;
    if(this.verticalAngle > -0.1)
      this.verticalAngle = -0.1;
 
    this.centerX = this.pos.x + cos(horizontalAngle) * sin(verticalAngle);
    this.centerY = this.pos.y + sin(horizontalAngle) * sin(verticalAngle);
    this.centerZ = this.pos.z - cos(verticalAngle);
 
    this.facing.set(this.centerX - this.pos.x, this.centerY - this.pos.y, this.centerZ - this.pos.z);
    this.facing.normalize();
 
    //CALCULATE LOCAL X & Y AXES
    this.normLR.set(1, -this.facing.x/(this.facing.y + 0.0001), 0);
    if(this.facing.y > 0)
      this.normLR.mult(-1);
    this.normLR.normalize();
 
    this.normFB.set(1, -this.normLR.x/(this.normLR.y + 0.0001), 0);
    if(this.normLR.y > 0)
      this.normFB.mult(-1);
    this.normFB.normalize();
 
    camera(this.pos.x, this.pos.y, this.pos.z, this.centerX, this.centerY, this.centerZ, 0, 0, -1);
  }
 
  public void setVelocity(float newVelocity) {
    this.velocity = newVelocity;
  }
 
  public void setFluidity(float newFluidity) {
    if(newFluidity < 0 || newFluidity > 1) {
      newFluidity = 0.9;
      println("Fluidity requires a value between 0 and 1! New fluidity was set to 0.9 (default).");
    }
    this.fluidity = newFluidity;
  }
 
  private PVector getWindowLocation() {
    PVector l = new PVector();
    com.jogamp.nativewindow.util.Point p = new com.jogamp.nativewindow.util.Point();
    ((com.jogamp.newt.opengl.GLWindow)surface.getNative()).getLocationOnScreen(p);
    l.x = p.getX();
    l.y = p.getY();
    return l;
  }
 
  void keyPressed(){
    if(key == CODED){
      if(keyCode == SHIFT){
        down = true;
      }
    }
    if(key == ' '){
      up = true;
    }
 
    if(key == 'w' || key == 'W'){
      forward = true;
    }
    if(key == 'a' || key == 'A'){
      left = true;
    }
    if(key == 's' || key == 'S'){
      backwards = true;
    }
    if(key == 'd' || key == 'D'){
      right = true;
    }
 
  }
 
  void keyReleased(){
 
    if(key == CODED){
      if(keyCode == SHIFT){
        down = false;
      }
    }
    if(key == ' '){
      up = false;
    }
 
    if(key == 'w' || key == 'W'){
      forward = false;
    }
    if(key == 'a' || key == 'A'){
      left = false;
    }
    if(key == 's' || key == 'S'){
      backwards = false;
    }
    if(key == 'd' || key == 'D'){
      right = false;
    }
 
  }
 
}
