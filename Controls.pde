class MyCheckbox {
  color colorActive = #133453;
  color colorBG = #2A4D6E;
  color colorSelected = #267257;

  CheckBox cb;
  boolean value = false;
  
  MyCheckbox(ControlP5 c5, String title, PVector pos, PVector size) {
    this.cb = c5.addCheckBox(title)
      .setPosition(pos.x, pos.y)
      .setSize(int(size.x), int(size.y))
      .setItemsPerRow(1)
      .setSpacingColumn(30)
      .setSpacingRow(5)
      .setColorBackground(this.colorBG)
      .setColorActive(this.colorSelected);
  }
}

class MySlider {
  color colorActive = #133453;
  color colorBG = #2A4D6E;
  color colorSelected = #267257;

  Slider s;
  float value = 0.0;
  
  MySlider(ControlP5 c5, String title, PVector pos, PVector size) {
    this.s = c5.addSlider(title)
      .setPosition(pos.x, pos.y)
      .setSize(int(size.x), int(size.y))
      .setRange(0,1)
      .setColorBackground(this.colorBG)
      .setColorActive(this.colorSelected);
  }
}

class LoadList {
  color colorActive = #133453;
  color colorBG = #2A4D6E;
  color colorSelected = #267257;
  
  ScrollableList list;
  int selectedIndex = -1;
  int count = 0;
  
  LoadList(ControlP5 c5, String title, PVector pos, PVector size) {
    this.list = c5.addScrollableList(title)
      .setPosition(pos.x, pos.y)
      .setSize(int(size.x), int(size.y))
      .setType(ControlP5.LIST)
      .setItemHeight(40)
      .setBarHeight(40)
      .setColorBackground(this.colorBG)
      .setColorActive(this.colorSelected);
    this.list.getCaptionLabel().set(title);
    this.list.getCaptionLabel().getStyle().marginTop = 3;
    this.list.getCaptionLabel().getStyle().marginLeft = 3;
    this.list.getCaptionLabel().setColor(color(255));
    grid.smallFont(this.list.getCaptionLabel());
    grid.smallFont(this.list.getValueLabel());
      
    this.load();
    if (this.length() > 0) { this.selected(0); }
  }
  
  int length() {
    return this.count;
  }
  
  void load() {
    int i = 0;
    for (i=0;i<80;i++) {
       list.addItem("item "+i, i);
       list.setColorBackground(this.colorBG);
     }
     this.count = i - 1;
  }
  
  void selected(int currentIndex) {
    println("currentIndex:  "+currentIndex + " length: " + this.length());
    if (this.length() <= currentIndex) { return; }
    if(this.selectedIndex >= 0){//if something was previously selected
      Map<String,Object> pi = list.getItem(this.selectedIndex);//get the item
      CColor picolor = new CColor();
      picolor.setBackground(this.colorBG);
      pi.put("color", picolor);//and restore the original bg colours
    }
    this.selectedIndex = currentIndex;//update the selected index
    Map<String,Object> ci = this.list.getItem(this.selectedIndex);
    CColor cicolor = new CColor();
    cicolor.setBackground(this.colorSelected);
    ci.put("color", cicolor);//and set the bg colour to be the active/'selected one'...until a new selection is made and resets this, like above
  }
  
   String name() {
     return list.getName();
   }
}

class SequenceLoadList extends LoadList {
  SequenceLoadList(ControlP5 c5, String title, PVector pos, PVector size) {
    super(c5, title, pos, size);
  }
  
  void load() {
    File file = new File(config.get("dataPath") + "\\sequences\\");
    File[] files = file.listFiles();
    this.list.clear();
    for (int i = 0; i < files.length; i++) {
      this.list.addItem(files[i].getName(), i);
     // lbi.setColorBackground(this.colorBG);
    }
    this.count = files.length;
    println("Initialized " + str(this.count) + " sequences");
    if (this.count > 0) {
      this.selected(0);
    }
  }
  
  String getSequence(int currentIndex) {
    Map< String , Object > li = this.list.getItem(currentIndex);
    if (grid != null && li != null) { 
      return li.get("text").toString();
    }
    return "";
  }
  
  /*
  Disabling the selector, change via MIDI channel
  void selected(int currentIndex) {
    super.selected(currentIndex);
    Map< String , Object > li = this.list.getItem(currentIndex);
    if (grid != null && li != null) { 
      String mkey = "text";
      grid.seq_id = li.get(mkey).toString();
      println("Loaded " + grid.seq_id);
    }
  }
  */
}

class PaletteLoadList extends LoadList {
  PaletteLoadList(ControlP5 c5, String title, PVector pos, PVector size) {
    super(c5, title, pos, size);
  }
  
  void load() {
    File file = new File(config.get("dataPath") + "\\palettes\\");
    File[] files = file.listFiles();
    int iX = 0;
    for (int i = 0; i < files.length; i++) {
      String name = files[i].getName();
      if (name.toLowerCase().endsWith(".tsv") == false) { continue; }
      this.list.addItem(name, iX);
      iX++;
    }
    this.count = files.length;
  }
  
  void selected(int currentIndex) {
    super.selected(currentIndex);
    Map<String, Object> li = this.list.getItem(currentIndex);
    if (grid != null && li != null) {
      String pname = li.get("text").toString(); 
      grid.p.load(pname);
      println("Loaded " + pname);
    }
  } 
}
