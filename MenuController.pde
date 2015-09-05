class MenuController extends Controller {
  RadioButton mode;
  
  Sequence sequence;

  void setup(PApplet _app) {
    super.setup(_app);
    
    mode = c5.addRadioButton("Mode")
      .setPosition(5, 800)
      .setColorBackground(color(55))
      .setSize(60, 40)
      .addItem(" Edit", 1.0)
      .addItem(" Play", 2.0)
      .setNoneSelectedAllowed(false)
      .setColorActive(#267257)
      ;
      
    grid.setFont(mode.getItem(0).getCaptionLabel());

    mode.getItem(1).getCaptionLabel()
      .setFont(grid.font)
      .setSize(32)
      ;
  }
  
  void draw() {
    mode.setPosition(5, height - 150);
  }
  
  void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(mode)) {
      float val = theEvent.getValue(); 
      if (val == 1.0) {
        editMode();
      } else if (val == 2.0) {
        playMode();
      }
    }
  }
  
  void editMode() {
    ctrls[1] = edit;
    edit.show();
    grid.hide();
  }
  
  void playMode() {
    grid.seqList.load();
    ctrls[1] = grid;
    edit.hide();
    grid.show();
  }
}
