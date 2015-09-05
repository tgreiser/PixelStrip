import java.util.*;
import java.io.*;


class SequenceList {
  ArrayList<String> sequences = new ArrayList<String>();
  int count = 0;
  
  void load() {
    File file = new File(config.get("dataPath") + "\\sequences\\");
    File[] files = file.listFiles();
    this.sequences.clear();
    for (int i = 0; i < files.length; i++) {
      this.sequences.add(files[i].getName());
     // lbi.setColorBackground(this.colorBG);
    }
    this.count = this.sequences.size();
    println("Initialized " + str(this.count) + " sequences");
  }
  
  String getSequence(int currentIndex) {
    if (grid != null && this.sequences != null) { 
      return this.sequences.get(currentIndex);
    }
    return "";
  }
}

/**
 * Data schema:
 * Variable # of steps
 * Each step is # color values where # is the # of columns in the grid
 */

class Sequence {
  int step = 0;
  color[][] data = new color[1][grid.cols];
  int initial_pixel = -1;
  int start = 0;
  int delay = 1;
  boolean flipX;
  boolean flipY;
  int offset = 0;
  int offsetRows = 0;
  int offsetCols = 0;
 
  void init() {
    initStep(0);
  }
  
  /*
  Number of steps
  */
  int length() {
    return data.length;
  }
  
  void initStep(int iS) {
    for (int iX = 0; iX < data[iS].length; iX++) {
      data[iS][iX] = #000000;
    }
  }
  
  /*
   Shift the current step # of pixels. Negative values shift to the left, positive to the right. Values beyond the grid bounds are truncated.
  */
  void shiftData(int amount) {
    color[] d;
    if (amount > 0) {
      d = new color[amount];
      for (int iX = 0; iX < amount; iX++) {
        println("Set " + str(iX) + " to black");
        d[iX] = #000000;
      }
      data[this.step] = concat(d, subset(data[this.step], 0, data[this.step].length - amount));
      println(data[this.step]);
      return;
    } else {
      d = data[this.step];
    }
    int iA = amount < 0 ? 0 : amount;
    for (int iX = iA; iX < data[this.step].length; iX++) {
      if (iX-amount >= data[this.step].length) {
        println("Set " + str(iX) + " to black");
        data[this.step][iX] = #000000;
      } else {
        println("Set " + str(iX) + " to " + str(iX-amount) + " " + str(d[iX-amount]));
        data[this.step][iX] = d[iX-amount];
      }
    }
  }
  
  void flipData() {
    color[] d = new color[data[this.step].length];
    arrayCopy(data[this.step], 0, d, 0, data[this.step].length);
    for (int iX = 0; iX < data[this.step].length; iX++) {
      data[this.step][iX] = d[data[this.step].length - iX - 1];
    }
  }
  
  /*
   * Calculate how many steps have passed since start (based on delay), then set the right step
   */
  void getStep() {
    int iX = floor((millis() - this.start) / this.delay);
    if (iX >= data.length) { return; }
    this.step = iX;
  }
  
  boolean ended() {
    int end = start + delay * data.length;
    return millis() > end;
  }
  
  void addStep() {
    step++;
    color[][] newdata = new color[data.length + 1][grid.cols];
    System.arraycopy(data, 0, newdata, 0, data.length);
    data = newdata;
    initStep(data.length - 1);
  }
  
  void copyStep() {
    addStep();
    arrayCopy(data[data.length - 2], data[data.length - 1]);
  }
  
  void prevStep() {
    if (step > 0) {
      step--;
    }
  }
  
  void nextStep() {
    if (step < data.length - 1) {
      step++;
    }
  }
  
  /*
  Change the order of the steps so they are reversed
  */
  void reverseSteps() {
    color[][] tempdata = new color[data.length][grid.cols];
    arrayCopy(data, tempdata);
    for (int iX = 0; iX < data.length; iX++) {
      println(str(data.length - iX - 1) + " into " + str(iX));
      data[iX] = tempdata[data.length - iX - 1];
    }
  }
  
  void addPixel(int iP, color c) {
    if (initial_pixel == -1) { initial_pixel = iP; }
    data[step][iP] = c;
  }
  
  void removePixel(int iP) {
    data[step][iP] = #000000;
  }
  
  /*
  
  */
  color stepHas(int value) {
    boolean debug = false;
    int r = 0;
    int c = 0;
    if (value == 1115) {
      debug = true; 
      println("Value " + value + " ip " + initial_pixel + " offset " + this.offset+ " offsetRows: " + this.offsetRows + " offsetCols: " + this.offsetCols);
    }
    
    r = grid.calcRow(value);
    if (r >= grid.rows || r < 0) { return #000000; }
    r -= this.offsetRows;
    
    if (flipY) {
      // flip around middle, not initial pixel
      int max = grid.cols - 1;
      
      c = -1 * grid.calcCol(value) + max;
      c = c + this.offsetCols;
      if (debug) println("c: " + c + " from " + initial_pixel);
      if (c >= grid.cols || c < 0) { return #000000; }
    } else {
      // kind of strange how this is different from rows
      c = grid.calcCol(value - this.offset);
      if (c + this.offsetCols >= grid.cols || c + this.offsetCols < 0) { return #000000; }
    }
    
    if (debug) { println("Post flip Value " + value + " r: " + r + " c: " + c); }    
    
    value = (grid.cols*r)+c;
    if (debug) { println("Final value " + value); }
    
    if (value < 0 || value >= data[this.step].length) { return #000000; }
    return data[this.step][value];
  }
  

  /**
   * Save the data to disk
   */
  public void saveData(File file) {
    try {
      FileOutputStream fos = new FileOutputStream(file);
      ObjectOutputStream oos = new ObjectOutputStream(fos);
      Integer initial = initial_pixel;
      oos.writeObject(initial);
      oos.writeObject(data);
      fos.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
  }
 
  /**
   * Load the data from disk 
   */
  public void loadData(File file) {
    color[][] array = null;
    Integer initial = -1;
    try {
      FileInputStream fis = new FileInputStream(file);
      ObjectInputStream ois = new ObjectInputStream(fis);
      initial = (Integer) ois.readObject();
      array = (color[][]) ois.readObject();
      fis.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
    } 
    catch (ClassNotFoundException e) {
      e.printStackTrace();
    }
    this.step = 0;
    initial_pixel = initial;
    data = array;
    //println("Loaded with initial pixel " + initial_pixel);
  }
}

boolean array_contains(Integer array[], int value) {
  for (int iX = 0; iX < array.length; iX++) {
    if (array[iX] == value) { return true; }
  }
  return false;
}
