import java.util.*;
import java.io.*;

/**
 * Data schema:
 * Variable # of steps
 * Each step is 100 boolean values
 */

class Sequence {
  int step = 0;
  Boolean[][] data = new Boolean[1][100];
  int initial_pixel = -1;
  color c;
  boolean flipX;
  boolean flipY;
  int offset = 0;
  int offsetRows = 0;
  int offsetCols = 0;
 
  void init() {
    initStep(0);
  }
  
  void initStep(int iS) {
    for (int iX = 0; iX < data[iS].length; iX++) {
      data[iS][iX] = false;
    }
  }
  
  void addStep() {
    step++;
    Boolean[][] newdata = new Boolean[data.length + 1][100];
    System.arraycopy(data, 0, newdata, 0, data.length);
    data = newdata;
    initStep(data.length - 1);
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
  
  void addPixel(int iP) {
    if (initial_pixel == -1) { initial_pixel = iP; }
    data[step][iP] = true;
  }
  
  void removePixel(int iP) {
    data[step][iP] = false;
  }
  
  /*
  Disabled cause not working yet
  */
  boolean stepHas(int value) {
    boolean debug = false;
    int r = 0;
    int c = 0;
    if (value == 1115) {
      debug = true; 
      println("Value " + value + " ip " + initial_pixel + " offset " + this.offset+ " offsetRows: " + this.offsetRows + " offsetCols: " + this.offsetCols);
    }
    
    // flip around initial_pixel
    // -x + (2 * row|col)
    if (flipX) {
      int ri = grid.calcRow(initial_pixel);
      r = -1 * grid.calcRow(value) + (2 * ri);
      r = r + this.offsetRows;
      if (debug) println("ri: " + ri + " from " + initial_pixel);
      if (r >= grid.rows || r < 0) { return false; }
    } else {
      r = grid.calcRow(value);
      if (r >= grid.rows || r < 0) { return false; }
      r -= this.offsetRows;
    }
    if (flipY) {
      // flip around middle, not initial pixel
      int max = grid.cols - 1;
      
      c = -1 * grid.calcCol(value) + max;
      c = c + this.offsetCols;
      if (debug) println("c: " + c + " from " + initial_pixel);
      if (c >= grid.cols || c < 0) { return false; }
    } else {
      // kind of strange how this is different from rows
      c = grid.calcCol(value - this.offset);
      if (c + this.offsetCols >= grid.cols || c + this.offsetCols < 0) { return false; }
    }
    
    if (debug) { println("Post flip Value " + value + " r: " + r + " c: " + c); }    
    
    value = (grid.cols*r)+c;
    if (debug) { println("Final value " + value); }
    
    if (value < 0 || value >= data[this.step].length) { return false; }
    return data[this.step][value];
  }
  
  boolean stepHasDisabled(int value) {
    boolean debug = false;
    if (value == 1273) {
      debug = true; 
      println("Value " + value + " offset " + this.offset+ " offsetRows: " + this.offsetRows + " offsetCols: " + this.offsetCols);
    }
    value = value - this.offset;
    int r = grid.calcRow(value);
    int c = grid.calcCol(value);
    if (debug) { println("Value " + value + " r: " + r + " c: " + c); }
    
    if (r + this.offsetRows >= grid.rows || r + this.offsetRows < 0) { return false; }
    if (c + this.offsetCols >= grid.cols || c + this.offsetCols < 0) { return false; }
    
    if (debug) { println("Value " + value + " offsetRows: " + this.offsetRows + " offsetCols: " + this.offsetCols); }
    
    value = (grid.cols*r)+c;
    if (debug) { println("Final value " + value); }
    if (value < 0 || value >= data[this.step].length) { return false; }
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
    Boolean[][] array = null;
    Integer initial = -1;
    try {
      FileInputStream fis = new FileInputStream(file);
      ObjectInputStream ois = new ObjectInputStream(fis);
      initial = (Integer) ois.readObject();
      array = (Boolean[][]) ois.readObject();
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
    println("Loaded with initial pixel " + initial_pixel);
  }
}

boolean array_contains(Integer array[], int value) {
  for (int iX = 0; iX < array.length; iX++) {
    if (array[iX] == value) { return true; }
  }
  return false;
}
