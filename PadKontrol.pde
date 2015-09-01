import themidibus.*; //Import the library

class MidiController {
  MidiBus myBus; // The MidiBus
  
}

class PadKontrol extends MidiController implements SimpleMidiListener {
  PadKontrol(PApplet _app) {
    MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
    ArrayList<java.lang.String> ins = new ArrayList<java.lang.String>();
    ins.addAll(java.util.Arrays.asList(MidiBus.availableInputs()));
    
    if (ins.contains("padKONTROL 1 PORT A")) {
      myBus = new MidiBus(_app, "padKONTROL 1 PORT A", "padKONTROL 1 CTRL"); // Create a new MidiBus (PApplet, in_device_name, out_device_name)
      myBus.addMidiListener(this);
    } else {
      println("Skipping padKONTROL, not detected...");
    }
  }
  
  void noteOn(int channel, int pitch, int velocity) {
    // Receive a noteOn
    println();
    println("Note On:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
    
    int br = 0;
    int bc = 0;
    int ledRow = 0;
    if (pitch >= 48) {
      bc = pitch % 48;
      ledRow = pitch - 48;
    } else if (pitch >= 44) {
      br = 1;
      bc = pitch % 44;
      ledRow = pitch - 40;
    } else if (pitch >= 40) {
      br = 2;
      bc = pitch % 40;
      ledRow = pitch - 32;
    } else {
      br = 3;
      bc = pitch % 36;
      ledRow = pitch - 24;
    }
    
    // Pitch 48-51 = strip 0-3
    // pitch 44-47 = strip 4-7
    // pitch 40-43 = strip 8-11
    // pitch 36-39 = strip 12-15
    
    
    
    //println("BC: " + bc + " BR:" + br);
    
    color c = grid.getColor(velocity);
    boolean flipX = false;
    boolean flipY = false;
    if (bc == 1 || bc == 3) { flipY = true; }
   
    println("bc: " + bc + " br: " + br +" fX: " + flipX + " fY: " + flipY);
    
    //grid.addSeq(c, new PVector(0, br * 3), flipX, flipY);
    grid.addSeq(c, new PVector(0, ledRow), false, false);
  }
  
  void noteOff(int channel, int pitch, int velocity) {}
  
  void controllerChange(int channel, int number, int value) {
    // Receive a controllerChange
    println();
    println("Controller Change:");
    println("--------");
    println("Channel:"+channel);
    println("Number:"+number);
    println("Value:"+value);
    
    if (number == 20) {
      // pick a sequence
      grid.seqList.selected(int(map(value, 0, 127, 0, grid.seqList.length()-1)));
    } else if (number == 21) {
      grid.clockDelay = int(map(value, 0, 127, 1, 200));
    }
  }
}
