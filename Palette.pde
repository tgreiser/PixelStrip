class Palette {
  color[] colors;
  
  color pick(int input) {
    int pick = int(map(float(input), 0, 127, 0, this.colors.length - 1));
    //int(random(16));
    // black isn't a valid pick, do something else
    if (colors[pick] == color(0, 0, 0)) { return this.pick(int(random(128))); }
    //println("Pick color : " + pick + " input: " + input + " nuM: " + this.colors.length + " color: " + colors[pick]);
    
    return colors[pick];
  }
  
  int size() {
    return this.colors.length;
  }
  
  // Palettes are found in data/palettes/PaletteName.tsv
  // Each line has an HTML color code
  void load(String paletteName) {
    println("Got " + config.get("dataPath") + "palettes\\" + paletteName);
    Table table = loadTable(config.get("dataPath") + "palettes\\" + paletteName);
    
    colors = new color[table.getRowCount()];
    int iX = 0;
    for (TableRow row : table.rows()) {
      colors[iX++] = unhex("FF" + row.getString(0));
    }
  }
}
