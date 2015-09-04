import controlP5.*;

class GridController extends Controller {
  int rows = 15;
  int cols = 30;
  int clockDelay = INITIAL_DELAY; 
  
  Pixel[] gpixels;
  boolean isAlternating = true;
  ArrayList<Sequence> sequences = new ArrayList<Sequence>();
  String seq_id = "000.seq";
  
  void setup(PApplet _app) {
    super.setup(_app);
    println("Setting up Grid");
    
    gpixels = new Pixel[rows * cols];
    
    int iP = 0;
    for (int iC = 0; iC < cols; iC++) {
      for (int iR = 0; iR < rows; iR++) {
        gpixels[iP++] = new Pixel();
      }
    }
    println("Initialized " + str(iP) + " pixels");
   
  }
  
  void controlEvent(ControlEvent theEvent) {
    //println("Got control event: " + theEvent.name());
    
  }
  
  /*
  position - start position - PVector type
  flipX *disabled* - reflect along X axis - boolean
  flipY *disabled* - reflect along Y axis - boolean
  patch_num - index number of the data sequence to use
  delay - ms to delay between each step (1-200 is good range)
  */
  void addSeq(PVector position, boolean flipX, boolean flipY, int patch_num, int delay) {
    if (sequences.size() > MAX_SEQUENCES) { return; }
    println("Running addSeq with " + str(patch_num));
    if (patch_num > grid.seqList.count) { patch_num = 0; }
    Sequence s = new Sequence();
    String seq = grid.seqList.getSequence(patch_num);
    println("Got sequence " + seq);
    s.loadData(new File(config.get("dataPath")+"sequences\\" + seq));
    s.flipX = flipX;
    s.flipY = flipY;
    s.start = millis();
    s.delay = delay;
    if (s.delay < 1) { s.delay = 1; }
    
    // need to figure out the offset
    // compare start position (PVector) against sequence.initial_pixel (0-99)
    //int pstart = position.X * 10 + position.Y;
    s.offsetRows = int(position.y) - this.calcRow(s.initial_pixel);
    s.offsetCols = int(position.x) - this.calcCol(s.initial_pixel);
    s.offset = s.offsetCols + (this.cols * s.offsetRows);
    
    //println("initial Y:" + this.calcRow(s.initial_pixel) + " initX: " + this.calcCol(s.initial_pixel));
    //println("posY: " + str(int(position.y)) + " posX: " + position.x);
    //println("offset: " + str(s.offset) + " co: " + str(s.offsetCols) + " ro: " + str(s.offsetRows) + " flipX: " + flipX + " flipY: " + flipY);
    
    // s.offset...
    sequences.add(s);
  }
  
  int calcCol(int value) {
    if (this.rows == 1) { return value; }
    if (this.rows == 2) { return value - this.cols; }
    return value % this.cols;
  }
  
  int calcRow(int value) {
    return floor(value / this.cols);
  }
}

class SimGridController extends GridController {
  float w = 1590; // 1078
  float h = 600; //600;
  float offsetX = 5;
  float offsetY = 5;
  float decay_rate = 0.0;
  PFont pfont = createFont("Terminal",40,false); // use true/false for smooth/no-smooth
  ControlFont font = new ControlFont(pfont,241);
  
  float sw; // square width
  float sh; // square height .. *heh*
  boolean colortest = true;
   
  void setup(PApplet _app) {
    println("SimGrid super");
    super.setup(_app);
        
    
    sw = w / cols;
    sh = h / rows;
    println("Setting up simgrid: sw=" + str(sw) + " sh=" + str(sh));
    println("Done simgrid");
  }
  
  void draw() {
    
    if (colortest) {
      drawColorTest();
    } else {
      drawPixelPad();
    }
  }
  
  void drawColorTest() {
    if (millis() >= 4000) {
      colortest = false;
    } else {
      int iX = 0;
      for (int iC = 0; iC < cols; iC++) {
        for (int iR = 0; iR < rows; iR++) {
          color c = edit.getColor(int(random(127)));
          gpixels[iX].clear();
          gpixels[iX].set(c);
          this.drawPixel(iX, iR, iC);
          iX++;
        }
      }
    }
  }
  
  void drawPixel(int pixelId, int row, int col) {
    gpixels[pixelId].draw();

    float x1 = sw * col;
    float y1 = sh * row;
    
    //if (row == 0) { println("   
    rect(x1 + offsetX, y1 + offsetY, sw , sh);
    if (ENABLE_LED) {
      int opcId = opcTransform(pixelId);
      opc.setPixel(opcId, gpixels[pixelId].rgb);
    }
  }

  /*
   * OPC strips are 64 per rail. We are using 30-length strips, so we have 4 missing LEDs every 2 strips.
   *
   * This will translate the sequential pixel ID to the opc ID
   */
  int opcTransform(int pixelId) {
    int rails = floor(pixelId / 60);
    return pixelId + rails * 4;
  }
  
  void drawPixelPad() {
    stroke(255);
    int iP = 0;
    int seq_size = sequences.size();
    println("Getting steps...");
    
    for (int iX = 0; iX < seq_size; iX++) {
      sequences.get(iX).getStep();
    }
    println("Got steps " + str(seq_size));
    
    for (int iR = 0; iR < rows; iR++) {
      for (int iC = 0; iC < cols; iC++) {
        gpixels[iP].clear();
        for (int iX = 0; iX < seq_size; iX++) {
          color c = sequences.get(iX).stepHas(iP);
          if (c != #000000) {
            //println("Setting pixel " + str(iP));
           // + " R: " + str(red(sequences.get(iX).c)));
            float mult = pow(1 - this.decay_rate, sequences.get(iX).step);
            color c2 = color(red(c) * mult, green(c) * mult, blue(c) * mult);
            //println("step: " + sequences.get(iX).step + " mult:" + mult +" decay_rate" + this.decay_rate);
            //c.alpha -= c.alpha * this.decay_rate;
            gpixels[iP].set(c2);
          }
        }
        this.drawPixel(iP++, iR, iC);
      }
    }

    for (int iX = 0; iX < sequences.size(); iX++) {
      if (sequences.get(iX).ended()) {
        sequences.remove(iX);
      }
    }
    if (ENABLE_LED) { opc.writePixels(); }
  }
}

class PlayGridController extends SimGridController {
  SequenceList seqList = new SequenceList();
  MyCheckbox cbOptions;
  MySlider decaySlider;
  int last;
  
  void setup(PApplet _app) {
    super.setup(_app);
    
    decaySlider = new MySlider(c5, "Decay", new PVector(300, 620), new PVector(50, 320));
    decaySlider.s.setMax(0.333);
    grid.setFont(decaySlider.s.getCaptionLabel());
    grid.setFont(decaySlider.s.getValueLabel());
    
    cbOptions = new MyCheckbox(c5, "Options", new PVector(5, 900), new PVector(60, 40));
    cbOptions.cb.addItem(" Enable LEDs", 0);
    //cbOptions.cb.toggle(0);
    grid.setFont(cbOptions.cb.getItem(0).getCaptionLabel());
  }
  
  void addSeq(PVector position, boolean flipX, boolean flipY, int patch_num, int delay) {
    super.addSeq(position, flipX, flipY, patch_num, delay);
    this.last = millis();
  }
  
  void draw() {
    this.w = width - 10;
    sw = this.w / cols;
    this.h = height * .667;
    sh = this.h / rows;
    
    decaySlider.s.setPosition(width * .25, height * .667 + 16);
    decaySlider.s.setSize(50, int(height * .25));
    
    cbOptions.cb.setPosition(5, height - 100);
    
    super.draw();
    if (millis() - this.last > 20000) {
      // chance to add a sequence
      float r = random(100);
      if (r > 90) {
        int bc = int(random(4));
        int br = int(random(4));
        boolean flipX = false;
        boolean flipY = false;
        if (bc > 1) { flipY = true; }
        if (br <= 1) { flipX = true; }
        super.addSeq(new PVector(bc * 3, br * 3), flipX, flipY, 0, int(random(200)));
      }
    }
  }
  
  void hide() {
    cbOptions.cb.setVisible(false);
    decaySlider.s.setVisible(false);
  }
  
  void show() {
    cbOptions.cb.setVisible(true);
    decaySlider.s.setVisible(true);
  }
  
  void controlEvent(ControlEvent theEvent) {
    super.controlEvent(theEvent);
    
    if (theEvent.name().equals(cbOptions.cb.getName())) {
      println(cbOptions.cb.getArrayValue());
      float[] optVals = theEvent.getArrayValue();
      ENABLE_LED = optVals[0] == 1.0;
    } else if (theEvent.name().equals(decaySlider.s.getName())) {
      this.decay_rate = theEvent.getValue();
    }
  }
  
  void setFont(Label label) {
    label.setFont(grid.font)
      .setSize(32)
      ;
  }
  
  void smallFont(Label label) {
    label.setFont(grid.font)
      .setSize(22)
      ;
  }
}
