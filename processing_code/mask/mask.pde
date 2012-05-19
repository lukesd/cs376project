

import oscP5.*;
import netP5.*;
import geomerative.*;
import processing.opengl.*;




OscP5 oscP5;


/*
 * Characteristic parameters
 * * * * * * * * * * * * * * */

int[] player1Position = new int[2];
int[] player2Position = new int[2];
boolean player1Playing = false;
boolean player2Playing = false;

int[] player1Rectangle = {20, 50, 10, 300};
int[] player2Rectangle = {120, 150, 90, 200};
boolean player1RectangleIndicator = false;
boolean player2RectangleIndicator = false;

int player1Density = 0;
int player2Density = 0;
int[] player1DensityBoundaries = new int[2];
int[] player2DensityBoundaries = new int[2];
boolean player1DensityIndicator = false;
boolean player2DensityIndicator = false;
boolean player1DensityBoundariesIndicator = false;
boolean player2DensityBoundariesIndicator = false;

int time = 0;
boolean timeIndicator = false;

RPolygon c;


/*
 * Drawing functions
 * * * * * * * * * * */

// Sizes
//////////

// Screen size
int screen_width = 300;
int screen_height = 300;

// Bars width
int bar_width = 50;

// Padding
int padding = 30;

// Origin
int x_screen_origin = 2*padding + bar_width;
int y_screen_origin = 2*padding + bar_width + screen_height;
int x_density1_origin = padding;
int y_density1_origin = 2*padding + bar_width + screen_height;
int x_density2_origin = 3*padding + bar_width + screen_width;
int y_density2_origin = 2*padding + bar_width + screen_height;

// Canvas Size
//int width = screen_width + 4*padding + 2*bar_width;
//int height = screen_height + 3*padding + bar_width;
int width = 300;
int height = 300;















// Mask array
public int[] maskArray = new int[screen_width * screen_height];

void createRectangleInScreen(int[] a, int x1, int x2, int y1, int y2) {
  for (int i = y1; i < y2; i++) {
    for (int j = x1; j < x2; j++) {
      a[screen_height * i + j ] = 0;
    }
  }
}

void fillWithN(int[] a, int n) {
  for (int i = 0; i < a.length; i++) {
    a[i] = n;
  }
}

void createMaskArray(int[] a, int[] rect1, int[] rect2) {
  fillWithN(a, 255);
  createRectangleInScreen(a, rect1[0], rect1[1], rect1[2], rect1[3]);
  createRectangleInScreen(a, rect2[0], rect2[1], rect2[2], rect2[3]);
}



void drawPlayer1Rectangle() {
  noFill();
  stroke(0, 0, 255);
  rect(
    x_screen_origin + player1Rectangle[0],
    y_screen_origin - player1Rectangle[3],
    player1Rectangle[1] - player1Rectangle[0],
    player1Rectangle[3] - player1Rectangle[2]
  );
}

void drawPlayer2Rectangle() {
  noFill();
  stroke(0, 0, 255);
  rect(
    x_screen_origin + player2Rectangle[0],
    y_screen_origin - player2Rectangle[3],
    player2Rectangle[1] - player2Rectangle[0],
    player2Rectangle[3] - player2Rectangle[2]
  );
}

void drawPlayer1Density() {
  fill(255, 0, 0);
  rect(
    padding,
    2*padding + bar_width,
    bar_width,
    screen_height*player1Density);
}

void drawPlayer2Density() {
  fill(0, 255, 0);
  rect( 
    3*padding + bar_width + screen_width,
    2*padding + bar_width,
    bar_width,
    screen_height*player2Density);
}

void drawPlayer1DensityBoundaries() {
  noFill();
  stroke(0, 0, 255);
  rect(
    padding,
    y_density1_origin - player1DensityBoundaries[1],
    bar_width,
    player1DensityBoundaries[1] - player1DensityBoundaries[0]
  );
}

void drawPlayer2DensityBoundaries() {
  noFill();
  stroke(0, 0, 255);
  rect(
    x_density2_origin,
    y_density2_origin - player2DensityBoundaries[1],
    bar_width,
    player2DensityBoundaries[1] - player2DensityBoundaries[0]
  );
}

void drawTime() {
  fill(255);
  rect(2*padding + bar_width, padding, time, bar_width);
}




/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 


// setup
void setup(){
  /*// Basic Settings
  size(width, height);
  frameRate(25);
  background(0);
  
  PImage img = loadImage("images.jpg");
  PImage maskImg = loadImage("mask1.jpg");
  int[] rect1 = {1, 15, 1, 5};
  int[] rect2 = {20, 28, 1, 15};
  createMaskArray(maskArray, rect1, rect2);
  println(maskArray);
  img.mask(maskArray);
image(img, 0, 0);

  // init drawing
  smooth();
  colorMode(RGB,255);
  
  // create a new instance of oscP5. 
  // 8012 is the port number we are listening for incoming osc messages.
  oscP5 = new OscP5(this, 8012);*/



/*  size(600,600,JAVA2D);

background(#CC9966);

fill(255);

stroke(0);

// "o" is compound because it has a hole

beginShape();

// outer portion

vertex(100,200);

vertex(250,200);

vertex(250,400);

vertex(100,400);

vertex(100,200); // must close manually (if you want the stroke)

// the hole

breakShape();

vertex(80,250);

vertex(150,370);

vertex(200,350);

vertex(200,250);

endShape(CLOSE); // ok to let p5 close it

// "i" is compound because it is disjoint

beginShape();

// base portion

vertex(300,200);

vertex(400,200);

vertex(400,400);

vertex(300,400);

vertex(300,200); // must close manually (if you want the stroke)

// the dot

breakShape();

endShape(CLOSE); // ok to let p5 close it

// now try making a capital greek theta

// (hint: it'll require 2 breakShapes()'s) */





size(width, height, OPENGL);
smooth();

  RPolygon s = RPolygon.createRectangle(
    0,
    0,
    screen_width,
    screen_height
  );
  
  RPolygon r1 = RPolygon.createRectangle(
    x_screen_origin + player1Rectangle[0],
    y_screen_origin - player1Rectangle[3],
    player1Rectangle[1] - player1Rectangle[0],
    player1Rectangle[3] - player1Rectangle[2]
  );
  
  RPolygon r2 = RPolygon.createRectangle(
    x_screen_origin + player2Rectangle[0],
    y_screen_origin - player2Rectangle[3],
    player2Rectangle[1] - player2Rectangle[0],
    player2Rectangle[3] - player2Rectangle[2]
  );
  
  /*RPolygon r1 = RPolygon.createCircle(0,-20,30);
RPolygon r2 = RPolygon.createCircle(20,40,45);
  
  //rectangles = new RPolygon();
  c = new RPolygon();
  c.union(s);
  //rectangles = rectangles.union(r1);
  //rectangles = rectangles.union(r2);
  c = c.diff(r1);
  c = c.diff(r2);*/

c = new RPolygon();
c = c.union(s);
c = c.diff(r1);
c = c.diff(r2);


}

void draw(){
 background(255);
 translate(width/2,height/2);
 
 translate(mouseX-width/2, mouseY-height/2);
 c.draw(g);
 
 translate(mouseX-width/2+10, mouseY-height/2+10);
 c.draw(g);



}


void resetTriggers() {
  player1Playing = false;
  player2Playing = false;
  //player1RectangleIndicator = false;
  //player2RectangleIndicator = false;
  player1DensityIndicator = false;
  player2DensityIndicator = false;
  //player1DensityBoundariesIndicator = false;
  //player2DensityBoundariesIndicator = false;  
  //timeIndicator = false;
}

//void draw() {
  
  //background(0);
  //drawCanevas();
  
//image(img, 25, 0);
  
//}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  
  // check if theOscMessage has the address pattern /new_note. 
  if(theOscMessage.checkAddrPattern("/new_note") && theOscMessage.checkTypetag("iff")) {
    getPlayerPosition(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }
  
  // check if theOscMessage has the address pattern /new_note. 
  if(theOscMessage.checkAddrPattern("/rect") && theOscMessage.checkTypetag("iffff")) {
    getRectangleBoundaries(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }
  
  // check if theOscMessage has the address pattern /dens_limit. 
  if(theOscMessage.checkAddrPattern("/dens_limit") && theOscMessage.checkTypetag("iff")) {
    getDensityBoundaries(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }
  
  // check if theOscMessage has the address pattern /dens. 
  if(theOscMessage.checkAddrPattern("/dens") && theOscMessage.checkTypetag("if")) {
    getDensity(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }
  
  // check if theOscMessage has the address pattern /dens. 
  if(theOscMessage.checkAddrPattern("/time") && theOscMessage.checkTypetag("f")) {
    getTime(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }
}

// Get the position of the player(s) from the OSC Message whose format is iff
void getPlayerPosition(OscMessage theOscMessage) {
  
  // parse theOscMessage and extract the values from the osc message arguments.
  int player = theOscMessage.get(0).intValue();  // get the first osc argument
  float x = theOscMessage.get(1).floatValue(); // get the second osc argument
  float y = theOscMessage.get(2).floatValue(); // get the third osc argument
  
  // First player
  if (player == 0) {
    player1Position[0] = int(x * screen_width);
    player1Position[1] = int(y * screen_height);
    player1Playing = true;
  }
  // Second player
  else if (player == 1) {
    player2Position[0] = int(x * screen_width);
    player2Position[1] = int(y * screen_height);
    player2Playing = true;
  }
}

void getRectangleBoundaries(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  int player = theOscMessage.get(0).intValue();  // get the first osc argument
  float y1 = theOscMessage.get(1).floatValue(); // get the second osc argument
  float y2 = theOscMessage.get(2).floatValue(); // get the third osc argument
  float x1 = theOscMessage.get(3).floatValue(); // get the third osc argument
  float x2 = theOscMessage.get(4).floatValue(); // get the third osc argument
  
  // First player
  if (player == 0) {
    player1Rectangle[0] = int(x1 * screen_width);
    player1Rectangle[1] = int(x2 * screen_width);
    player1Rectangle[2] = int(y1 * screen_height);
    player1Rectangle[3] = int(y2 * screen_height);
    player1RectangleIndicator = true;
  }
  // Second player
  else if (player == 1) {
    player2Rectangle[0] = int(x1 * screen_width);
    player2Rectangle[1] = int(x2 * screen_width);
    player2Rectangle[2] = int(y1 * screen_height);
    player2Rectangle[3] = int(y2 * screen_height);
    player2RectangleIndicator = true;
  }
  
  println("### ### Rectangle boundaries for player " + player + ": x1 = " + x1 + ", x2 = " + x2 + " y1 = " + y1 + ", y2 = " + y2);
}

void getDensityBoundaries(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  int player = theOscMessage.get(0).intValue();
  float d1 = theOscMessage.get(1).floatValue();
  float d2 = theOscMessage.get(2).floatValue();
  
  // First player
  if (player == 0) {
    player1DensityBoundaries[0] = int(d1 * screen_height);
    player1DensityBoundaries[1] = int(d2 * screen_height);
    player1DensityBoundariesIndicator = true;
  }
  // Second player
  else if (player == 1) {
    player2DensityBoundaries[0] = int(d1 * screen_height);
    player2DensityBoundaries[1] = int(d2 * screen_height);
    player2DensityBoundariesIndicator = true;
  }
  
  println("### ### Density boundaries for player " + player + ": low = " + d1 +", high = " + d2);
}

void getDensity(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  int player = theOscMessage.get(0).intValue();
  float d = theOscMessage.get(1).floatValue();
  
  // First player
  if (player == 0) {
    player1Density = int(d * screen_height);
    player1DensityIndicator = true;
  }
  // Second player
  else if (player == 1) {
    player2Density = int(d * screen_height);
    player2DensityIndicator = true;
  }
}

void getTime(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  float t = theOscMessage.get(0).floatValue();
  
  time = int(t * screen_width);
  timeIndicator = true;
  
  println("### ### Time: " + t);
}












/*
int intVar = 0;
String stringVar = "a string";
int[] arrayVar = {1,2,3,4};

void setup() {
  changeInt(intVar);
  println(intVar);
  changeString(stringVar);
  println(stringVar);
  changeArray(arrayVar);
  println(arrayVar);
}

void changeInt(int intIn) {
  intIn = 1;
}

void changeString(String stringIn) {
  stringIn = "nothing...";
}

void changeArray(int[] arrayIn) {
  for (int i = 0; i < 2; i++) {
  arrayIn[i] = 10;
  }
}*/

