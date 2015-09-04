class EditorController extends SimGridController {
  int rows = 1;
  int cols = 30;
  Button save;
  Button load;
  Button newseq;
  ColorWheel cw;
  ColorBin cb;
  PaletteLoadList paletteList;
  Palette p;
  color _c;
  int e_length = 0;
  
  Sequence sequence;

  void setup(PApplet _app) {
    super.setup(_app);
    
    save = c5.addButton("Save")
      .setPosition(20, 950)
      .setColorBackground(color(0))
      .setSize(114, 38);
    grid.setFont(save.getCaptionLabel());
      
    load = c5.addButton("Load")
      .setPosition(140, 950)
      .setColorBackground(color(0))
      .setSize(114, 38);
    grid.setFont(load.getCaptionLabel());
      
    newseq = c5.addButton("New")
      .setPosition(260, 950)
      .setColorBackground(color(0))
      .setSize(114, 38);
    grid.setFont(newseq.getCaptionLabel());
    
    p = new Palette();
    //p.load("NES.tsv");
    paletteList = new PaletteLoadList(c5, "Palettes", new PVector(width*.75, height * .5), new PVector(width * .25, height * .5));
    
    _c = #ff0000;
    cw = c5.addColorWheel("color picker", int(width * .5), int(height * .1), height / 5)
          .setRGB(this._c)
          ;
    cb = new ColorBin(c5, "Color History / Palette", new PVector(0, 0), new PVector(0, 0));
      
    sequence = new Sequence();
    sequence.init();
    
    e_length = this.rows * this.cols;
  }
  
  void hide() {
    save.setVisible(false);
    load.setVisible(false);
    newseq.setVisible(false);
    cw.setVisible(false);
    paletteList.list.setVisible(false);
  }
  
  void show() {
    save.setVisible(true);
    load.setVisible(true);
    newseq.setVisible(true);
    cw.setVisible(true);
    paletteList.list.setVisible(true);
  }
  
  void draw() {
    
    this.w = width - 10;
    sw = this.w / cols;
    
    paletteList.list.setPosition(width*.75, height * .5);
    paletteList.list.setSize(int(width * .25), int(height * .5));
    
    cw.setPosition(width * .5, height * .1);
    cb.g.setPosition(width * .75, height * .1);
    //cb.g.setSize(int(width * .25), int( (height * .5) - sh - 16));
    save.setPosition(20, height-50);
    load.setPosition(140, height-50);
    newseq.setPosition(260, height-50);
    
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
    
    cb.draw();
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
      this._c = cw.getRGB();
    } else if (theEvent.name().equals(paletteList.name())) {
      int pick = (int)theEvent.getValue();
      println("Picked " + pick);
      paletteList.selected(pick);
    }
  }
  
    // calculate the grid # and set the pixel to red, or back to black
    // need to accound for grid.offsetX/Y
  void mouseReleased() {
    int click = cb.detectClick();
    println("mouseReleased: " + str(click));
    if (click != -1 && cb.colors[click] != #000000) { cw.setRGB(cb.colors[click]); }
    
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
      cb.add(this._c);
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
  
  // Picks a color from the current palette
  color getColor(int input) {
    //if (this.velocity_colors == false) { input = int(random(128)); }
    return p.pick(input);
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
