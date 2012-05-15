

import oscP5.*;
import netP5.*;





OscP5 oscP5;


/*
 * Characteristic parameters
 * * * * * * * * * * * * * * */

int[] player1Position = new int[2];
int[] player2Position = new int[2];
boolean player1Playing = false;
boolean player2Playing = false;

int[] player1Rectangle = new int[4];
int[] player2Rectangle = new int[4];
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



/*
 * Drawing functions
 * * * * * * * * * * */

// Sizes
//////////

// Screen size
int screen_width = 300;
int screen_height = 300;

// Bars width
int bar_width = 30;

// Padding
int padding = 20;

// Origin
int x_screen_origin = 2*padding + bar_width;
int y_screen_origin = 2*padding + bar_width;

// Canvas Size
int width = screen_width + 4*padding + 2*bar_width;
int height = screen_height + 3*padding + bar_width;


// Canevas functions
//////////////////////

void drawScreen() {
  rect(x_screen_origin, y_screen_origin, screen_width, screen_height);
}

void drawLeftBar() {
  rect(padding, 2*padding + bar_width, bar_width, screen_height);
}

void drawRightBar() {
  rect(3*padding + bar_width + screen_width, 2*padding + bar_width, bar_width, screen_height);
}

void drawTopBar() {
  rect(2*padding + bar_width, padding, screen_width, bar_width);
}

void drawCanevas() {
  noFill();
  stroke(255);
  drawScreen();
  drawLeftBar();
  drawRightBar();
  drawTopBar();
}

// Dynamic objects functions
//////////////////////////////

void drawPlayer1() {
  noFill();
  stroke(255);
  ellipse(x_screen_origin + player1Position[0], y_screen_origin + player1Position[1], 80, 80);
}

void drawActivePlayer1() {
  fill(255);
  ellipse(x_screen_origin + player1Position[0], y_screen_origin + player1Position[1], 80, 80);
}

void drawPlayer2() {
  noFill();
  stroke(255);
  ellipse(x_screen_origin + player2Position[0], y_screen_origin + player2Position[1], 40, 40);
}

void drawActivePlayer2() {
  fill(255);
  ellipse(x_screen_origin + player2Position[0], y_screen_origin + player2Position[1], 80, 80);
}

void drawPlayer1Rectangle() {
  noFill();
  stroke(255, 0, 0);
  rect(
    x_screen_origin + player1Rectangle[2],
    y_screen_origin + player1Rectangle[1],
    player1Rectangle[3] - player1Rectangle[2],
    player1Rectangle[1] - player1Rectangle[0]
  );
}

void drawPlayer2Rectangle() {
  noFill();
  stroke(0, 255, 0);
  rect(
    x_screen_origin + player2Rectangle[2],
    y_screen_origin + player2Rectangle[1],
    player2Rectangle[3] - player2Rectangle[2],
    player2Rectangle[1] - player2Rectangle[0]
  );
}

void drawPlayer1Density() {
  fill(255, 0, 0);
  rect(padding, 2*padding + bar_width, bar_width, screen_height*player1Density);
}

void drawPlayer2Density() {
  fill(0, 255, 0);
  rect(3*padding + bar_width + screen_width, 2*padding + bar_width, bar_width, screen_height*player2Density);
}

void drawPlayer1DensityBoundaries() {
  noFill();
  stroke(255, 0, 0);
  rect(
    padding,
    2*padding + bar_width + player1DensityBoundaries[1],
    bar_width,
    player1DensityBoundaries[1] - player1DensityBoundaries[0]
  );
}

void drawPlayer2DensityBoundaries() {
  noFill();
  stroke(0, 255, 0);
  rect(
    3*padding + bar_width + screen_width,
    2*padding + bar_width + player2DensityBoundaries[1],
    bar_width,
    player2DensityBoundaries[1] - player2DensityBoundaries[0]
  );
}

void drawTime() {
  fill(255);
  rect(2*padding + bar_width, padding, screen_width, bar_width*time);
}








/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 


// setup
void setup(){
  // Basic Settings
  size(width, height);
  frameRate(25);
  background(0);

  // init drawing
  smooth();
  colorMode(RGB,255);
  
  // create a new instance of oscP5. 
  // 8012 is the port number we are listening for incoming osc messages.
  oscP5 = new OscP5(this, 8012);
}


void resetTriggers() {
  player1Playing = false;
  player2Playing = false;
  player1RectangleIndicator = false;
  player2RectangleIndicator = false;
  player1DensityIndicator = false;
  player2DensityIndicator = false;
  player1DensityBoundariesIndicator = false;
  player2DensityBoundariesIndicator = false;
  timeIndicator = false;
}

void draw() {
  
  background(0);
  drawCanevas();
  
  
  // Player1
  if (player1Playing) {
    drawActivePlayer1();
  }
  else {
    drawPlayer1();
  }
  
  // Player2
  if (player2Playing) {
    drawActivePlayer2();
  }
  else {
    drawPlayer2();
  }
  
  // Player1 Rectangle
  if (player1RectangleIndicator) {
    drawTime();
  }
  
  // Player2 Rectangle
  if (player2RectangleIndicator) {
    drawTime();
  }
  
  // Player1 Density
  if (player1DensityIndicator) {
    drawPlayer1Density();
  }
  
  // Player2 Density
  if (player2DensityIndicator) {
    drawPlayer2Density();
  }
  
  // Player1 Density Boundaries
  if (player1DensityBoundariesIndicator) {
    drawPlayer1DensityBoundaries();
  }
  
  // Player2 Density Boundaries
  if (player2DensityBoundariesIndicator) {
    drawPlayer2DensityBoundaries();
  }
  
  // Time
  if (timeIndicator) {
    drawTime();
  }
  
  
  resetTriggers();
}


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
  float x1 = theOscMessage.get(1).floatValue(); // get the second osc argument
  float x2 = theOscMessage.get(2).floatValue(); // get the third osc argument
  float y1 = theOscMessage.get(3).floatValue(); // get the third osc argument
  float y2 = theOscMessage.get(4).floatValue(); // get the third osc argument
  
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
  int player = theOscMessage.get(0).intValue();  // get the first osc argument
  float d1 = theOscMessage.get(1).floatValue(); // get the second osc argument
  float d2 = theOscMessage.get(1).floatValue(); // get the second osc argument
  
  // First player
  if (player == 0) {
    player1DensityBoundaries[0] = int(d1 * screen_height);
    player1DensityBoundaries[0] = int(d2 * screen_height);
    player1DensityBoundariesIndicator = true;
  }
  // Second player
  else if (player == 1) {
    player2DensityBoundaries[0] = int(d1 * screen_height);
    player2DensityBoundaries[0] = int(d2 * screen_height);
    player2DensityBoundariesIndicator = true;
  }
  
  println("### ### Density boundaries for player " + player + ": low = " + d1 +", high = " + d2);
}

void getDensity(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  int player = theOscMessage.get(0).intValue();  // get the first osc argument
  float d = theOscMessage.get(1).floatValue(); // get the second osc argument
  
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
  float t = theOscMessage.get(1).floatValue(); // get the second osc argument
  
  time = int(t * screen_width);
  timeIndicator = true;
}
