class EditorController extends SimGridController {
  int rows = 1;
  int cols = 30;
  Button save;
  Button load;
  Button newseq;
  ColorWheel cw;
  color _c;
  int e_length = 0;
  
  Sequence sequence;

  void setup(PApplet _app) {
    super.setup(_app);
    
    save = c5.addButton("Save")
      .setPosition(400, 800)
      .setColorBackground(color(0))
      .setSize(114, 38);
    grid.setFont(save.getCaptionLabel());
      
    load = c5.addButton("Load")
      .setPosition(520, 800)
      .setColorBackground(color(0))
      .setSize(114, 38);
    grid.setFont(load.getCaptionLabel());
      
    newseq = c5.addButton("New")
      .setPosition(640, 800)
      .setColorBackground(color(0))
      .setSize(114, 38);
    grid.setFont(newseq.getCaptionLabel());
    
    _c = #ff0000;
    cw = c5.addColorWheel("picker", 5, 300, 200)
          .setRGB(this._c)
          ;
      
    sequence = new Sequence();
    sequence.init();
    
    e_length = this.rows * this.cols;
  }
  
  void hide() {
    save.setVisible(false);
    load.setVisible(false);
    newseq.setVisible(false);
    cw.setVisible(false);
  }
  
  void show() {
    save.setVisible(true);
    load.setVisible(true);
    newseq.setVisible(true);
    cw.setVisible(true);
  }
  
  void draw() {
    stroke(255);
    int iP = 0;
    for (int iR = 0; iR < rows; iR++) {
      for (int iC = 0; iC < cols; iC++) {
        gpixels[iP].clear();
        
        color c = sequence.stepHas(iP);
        gpixels[iP].set(c);
        
        this.drawPixel(iP++, iR, iC);
      }
    } 
  }
  
  void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(save)) {
      save();
    } else if (theEvent.isFrom(load)) {
      selectInput("What sequence would you like to load?", "loadCallback", new File(config.get("dataPath")+"sequences\\000.seq"));
    } else if (theEvent.isFrom(newseq)) {
      sequence = new Sequence();
      sequence.init();
    } else if (theEvent.isFrom(cw)) {
      this._c = c5.get(ColorWheel.class,"picker").getRGB();
    }
  }
  
    // calculate the grid # and set the pixel to red, or back to black
    // need to accound for grid.offsetX/Y
  void mouseReleased() {
    if (mouseX < grid.offsetX || mouseY < grid.offsetY) { return; }
    println("mouseX " + str(mouseX) + " offsetX " + str(grid.offsetX) + " gpixels length " + str(gpixels.length));
    int iC = (mouseX - int(grid.offsetX)) / int(sw);
    int iR = (mouseY - int(grid.offsetY)) / int(sh);
    int iP = (iR * grid.cols) + iC;
    println("Got " + str(iC) + " x " + str(iR) + " - " + str(iP));
    println("Limit rows " + str(edit.rows) + " cols " + str(edit.cols));
    if (iP > this.e_length - 1) { return; }
    if (iR >= edit.rows || iC >= edit.cols) { return; }
    
    println("Passed!");
    
    if (gpixels[iP].rgb == color(0, 0, 0)) {
      println("Set custom color");
      sequence.addPixel(iP, this._c);
    } else {
      println("Set black");
      sequence.removePixel(iP);
      //gpixels[iP].clear();
      //println(gpixels[iP].rgb);
    }
  }
  
  void keyPressed() {
    if (key == CODED) {
      if (keyCode == RIGHT) {
        sequence.nextStep();
      } else if (keyCode == LEFT) {
        sequence.prevStep();
      }
    } else if (key == 10) {
      // sequence add step, advance, then clear
      sequence.addStep();
    }
  }
  
  void save() {
    println("Running selectOutput..");
    selectOutput("Where would you like to save your sequence?", "saveCallback", new File(config.get("dataPath")+"sequences\\000.seq"));
  }
  
  void saveCallback(File selection) {
    if (selection == null) { return; }
    String fn = selection.getAbsolutePath();
    println("Saving " + fn);
    
    // Serialize the sequence data
    File file = new File(fn);
    sequence.saveData(file);
  }
  
  void loadCallback(File selected) { 
    if (selected == null) { return; }
    sequence.loadData(selected);
  }
}
