class Keyboard {
  Keyboard(PApplet _app) {
  }
  
  void keyPressed() {
    if (key == CODED) {
      println("Key code " + keyCode);
    } else if (key == '1') {
      this.addSeq(0, 0);
    } else if (key == '2') {
      this.addSeq(0, 1);
    } else if (key == '3') {
      this.addSeq(0, 2);
    } else if (key == '4') {
      this.addSeq(0, 3);
    } else if (key == 'q') {
      this.addSeq(1, 0);
    } else if (key == 'w') {
      this.addSeq(1, 1);
    } else if (key == 'e') {
      this.addSeq(1, 2);
    } else if (key == 'r') {
      this.addSeq(1, 3);
    } else if (key == 'a') {
      this.addSeq(2, 0);
    } else if (key == 's') {
      this.addSeq(2, 1);
    } else if (key == 'd') {
      this.addSeq(2, 2);
    } else if (key == 'f') {
      this.addSeq(2, 3);
    } else if (key == 'z') {
      this.addSeq(3, 0);
    } else if (key == 'x') {
      this.addSeq(3, 1);
    } else if (key == 'c') {
      this.addSeq(3, 2);
    } else if (key == 'v') {
      this.addSeq(3, 3);
    } else {
      println("Key " + key);
    }
  }
  
  void addSeq(int br, int bc) {
    
    color c = grid.getColor(int(random(128)));
    boolean flipX = false;
    boolean flipY = false;
    if (bc > 1) { flipY = true; }
    if (br <= 1) { flipX = true; }
    
    println("bc: " + bc + " br: " + br +" fX: " + flipX + " fY: " + flipY);
    
    grid.addSeq(c, new PVector(bc * 3, br * 3), flipX, flipY);
  }
}
