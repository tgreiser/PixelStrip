import controlP5.*;

import java.net.*;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.GraphicsConfiguration;
import java.awt.Rectangle;
import java.util.Arrays;

ControlP5 c5;

OPC opc;
PlayGridController grid;
EditorController edit;
MenuController menu;
Keyboard kb;
Controller[] ctrls;
StringDict config;
String server = "127.0.0.1";
//"192.168.0.12";
boolean ENABLE_LED = false;
boolean DRAW_GRID = true;
boolean FULL_SCREEN = false;
int INITIAL_DELAY = 100;
int MAX_SEQUENCES = 64;

PadKontrol midi;
Rectangle monitor = new Rectangle();

color cb1 = #728CA6;
color cb2 = #4A6B8A;
color cb3 = #2A4D6E;
color cb4 = #133453;
color cb5 = #041E37;

color cp1 = #827FB2;
color cp2 = #585594;
color cp3 = #363377;
color cp4 = #1D1959;
color cp5 = #0B083B;

color cg1 = #72AB97;
color cg2 = #478E75;
color cg3 = #267257;
color cg4 = #0E553C;
color cg5 = #003925;

void setup() {
  
  
  if (FULL_SCREEN) {
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    GraphicsDevice[] gs = ge.getScreenDevices();
    // gs[1] gets the *second* screen. gs[0] would get the primary screen
    GraphicsDevice gd = gs[0];
    GraphicsConfiguration[] gc = gd.getConfigurations();
    monitor = gc[0].getBounds();
    println(monitor.x + " " + monitor.y + " " + monitor.width + " " + monitor.height);
    size(monitor.width, monitor.height);
  } else {
    size(1600, 1000);
    if (frame != null) {
      frame.setResizable(true);
    }
  }
  background(0);
  c5 = new ControlP5(this);
  if (ENABLE_LED) { opc = new OPC(this, server, 7890); }
  
  config = new StringDict();
  config.set("dataPath", dataPath("") + "\\");
  
  midi = new PadKontrol(this);
  kb = new Keyboard(this);
  
  ctrls = new Controller[2];
  grid = new PlayGridController();
  edit = new EditorController();
  menu = new MenuController();
  
  // have to setup grid because it isn't loaded in ctrls
  println("Initial grid setup from PApplet"); //<>//
  grid.setup(this);
  
  ctrls[0] = menu;
  ctrls[1] = edit;
  
  for (Controller c : ctrls) {
    c.setup(this);
  }
  
  menu.mode.activate(" Play");
}

void init() {
  super.init();
}

void draw() {
  if (FULL_SCREEN) {
    frame.setLocation(monitor.x, monitor.y);
    frame.setAlwaysOnTop(true); 
  }
  background(0);
  
  for (Controller c : ctrls) {
    c.draw();
  }
}

void mouseReleased() {
  for (Controller c : ctrls) {
    c.mouseReleased();
  }
}

void mouseDragged() {
  for (Controller c : ctrls) {
    c.mouseDragged();
  }
}

void keyPressed() {
  for (Controller c : ctrls) {
    c.keyPressed();
  }
  kb.keyPressed();
}

void controlEvent(ControlEvent theEvent) {
  for (Controller c : ctrls) {
    if (c != null) c.controlEvent(theEvent);
  }
}

void saveCallback(File selected) {
  edit.saveCallback(selected);
}

void loadCallback(File selected) {
  edit.loadCallback(selected);
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

void customize(ListBox ddl, String label) {
  // a convenience function to customize a DropdownList
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.getCaptionLabel().set(label);
  ddl.getCaptionLabel().getStyle().marginTop = 3;
  ddl.getCaptionLabel().getStyle().marginLeft = 3;
  ddl.getCaptionLabel().setColor(cg1);
  ddl.getValueLabel().getStyle().marginTop = 3;
  
  //ddl.scroll(0);
  ddl.setColorBackground(cb3);
  ddl.setColorActive(cb4);
}
