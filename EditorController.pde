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
  Group iconStrip;
  Group stepControls;
  Textlabel stepLabel;
  Icon fill;
  color _c;
  int e_length = 0;
  
  Sequence sequence;

  void setup(PApplet _app) {
    super.setup(_app);
    
    sequence = new Sequence();
    sequence.init();
    
    e_length = this.rows * this.cols;
    
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
          
    fill = c5.addIcon("fill", 10)
      .setPosition(width * .5 + height / 5, height * .1)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f043,#00f043)
      .registerTooltip("Fill with current color")
      ;
    
    cb = new ColorBin(c5, "Color History / Palette", new PVector(0, 0), new PVector(0, 0));
    
    iconStrip = c5.addGroup("Pattern Controls")
      .setPosition(0, 0)
      .setSize(0, 0);
    
    // Tooltips don't work in processing 2.2.1+, bummer
    c5.addIcon("shift10Left", 10)
      .setPosition(0, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f100,#00f100)
      .registerTooltip("Shift pattern 10 steps left")
      .setGroup(iconStrip);
      
    c5.addIcon("shiftLeft", 10)
      .setPosition(50, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f104,#00f104)
      .registerTooltip("Shift pattern 1 step left")
      .setGroup(iconStrip);
      
    c5.addIcon("flipY", 10)
      .setPosition(100, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f021,#00f021)
      .registerTooltip("Flip pattern")
      .setGroup(iconStrip);
      
    c5.addIcon("shiftRight", 10)
      .setPosition(150, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f105,#00f105)
      .registerTooltip("Shift pattern 1 step right")
      .setGroup(iconStrip);
      
    c5.addIcon("shift10Right", 10)
      .setPosition(200, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f101,#00f101)
      .registerTooltip("Shift pattern 10 steps right")
      .setGroup(iconStrip);
      
    stepControls = c5.addGroup("Step Controls")
      .setPosition(0, 0)
      .setSize(0, 0);
      
    c5.addIcon("stepPrev", 10)
      .setPosition(0, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f060,#00f060)
      .registerTooltip("Previous Step")
      .setGroup(stepControls);
    c5.addIcon("stepsReverse", 10)
      .setPosition(50, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f0ec,#00f0ec)
      .registerTooltip("Reverse Order")
      .setGroup(stepControls);
    stepLabel = c5.addTextlabel("stepLabel")
      .setPosition(0, 50)
      .setFont(createFont("Terminal", 32))
      .setGroup(stepControls);
    stepLabelUpdate();
    
    c5.addIcon("stepCopy", 10)
      .setPosition(100, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f0fe,#00f0fe)
      .registerTooltip("Copy Step")
      .setGroup(stepControls);
    c5.addIcon("stepAdd", 10)
      .setPosition(150, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f196,#00f196)
      .registerTooltip("Add Step")
      .setGroup(stepControls);
    c5.addIcon("stepNext", 10)
      .setPosition(200, 0)
      .setSize(40, 40)
      .setFont(createFont("fontawesome-webfont.ttf", 40))
      .setFontIcons(#00f061,#00f061)
      .registerTooltip("Next Step")
      .setGroup(stepControls);
  }
  
  void icon(boolean theValue) {
    println("Got icon ", theValue);
  }
  
  void shift10Left(boolean theValue) {
    println("Got shift10Left");
  }
  
  void hide() {
    save.setVisible(false);
    load.setVisible(false);
    newseq.setVisible(false);
    cw.setVisible(false);
    cb.g.setVisible(false);
    paletteList.list.setVisible(false);
    iconStrip.setVisible(false);
    stepControls.setVisible(false);
    fill.setVisible(false);
  }
  
  void show() {
    save.setVisible(true);
    load.setVisible(true);
    newseq.setVisible(true);
    cw.setVisible(true);
    cb.g.setVisible(true);
    paletteList.list.setVisible(true);
    iconStrip.setVisible(true);
    stepControls.setVisible(true);
    fill.setVisible(true);
  }
  
  void stepLabelUpdate() {
    stepLabel.setText(str(sequence.step+1) + " of " + str(sequence.length()));
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
    iconStrip.setPosition(0, height * .1);
    iconStrip.setSize(int(width * .25), int(height * .2));
    stepControls.setPosition(0, height * .3);
    stepControls.setSize(int(width * .25), int(height * .2));
    fill.setPosition(width * .5 + height / 5, height * .1);
    
    stepLabelUpdate();
    
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
    println("Got controlEvent");
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
      for (int iX = 0; iX < p.size(); iX++) {
        cb.add(p.colors[iX]);
      }
    } else {
      if (theEvent.isFrom(c5.get(Icon.class, "shift10Left"))) {
        sequence.shiftData(-10);
      } else if (theEvent.isFrom(c5.get(Icon.class, "shiftLeft"))) {
        sequence.shiftData(-1);
      } else if (theEvent.isFrom(c5.get(Icon.class, "shiftRight"))) {
        sequence.shiftData(1);
      } else if (theEvent.isFrom(c5.get(Icon.class, "shift10Right"))) {
        sequence.shiftData(10);
      } else if (theEvent.isFrom(c5.get(Icon.class, "flipY"))) {
        sequence.flipData();
        // stepControls start here
      } else if (theEvent.isFrom(c5.get(Icon.class, "stepPrev"))) {
        sequence.prevStep();
      } else if (theEvent.isFrom(c5.get(Icon.class, "stepNext"))) {
        sequence.nextStep();
      } else if (theEvent.isFrom(c5.get(Icon.class, "stepAdd"))) {
        sequence.addStep();
      } else if (theEvent.isFrom(c5.get(Icon.class, "stepCopy"))) {
        sequence.copyStep();
      } else if (theEvent.isFrom(c5.get(Icon.class, "stepsReverse"))) {
        sequence.reverseSteps();
      } else if (theEvent.isFrom(fill)) {
        sequence.fill(this._c);
        cb.add(this._c);
      }
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
