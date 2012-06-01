      

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

int[] player1Rectangle = new int[4];
int[] player2Rectangle = new int[4];
boolean player1RectangleIndicator = false;
boolean player2RectangleIndicator = false;

int maxNumberOfNotes = 64;
int player1RemainingNotes = maxNumberOfNotes;
int player2RemainingNotes = maxNumberOfNotes;
boolean player1RemainingNotesIndicator = false;
boolean player2RemainingNotesIndicator = false;

int time = 0;
boolean timeIndicator = false;

int remainingPatterns = 8;
boolean remainingPatternsIndicator = true;

// Mask
RPolygon rectanglesMask;
RPolygon rectanglesMaskBorder;


/*
 * Drawing functions
 * * * * * * * * * * */

// Sizes
//////////

// Screen size
//int screen_width = 640;
//int screen_height = 880; 
int screen_width = 512;
int screen_height = 704;

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
int width = screen_width + 4*padding + 2*bar_width;
int height = screen_height + 3*padding + bar_width;


// Canevas functions
//////////////////////

void drawScreen() {
  rect(x_screen_origin, y_screen_origin - screen_height , screen_width, screen_height);
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
  displayTimeText();
}

// Dynamic objects functions
//////////////////////////////

void drawPlayer1() {
  noFill();
  stroke(255, 0, 0);
  ellipse(x_screen_origin + player1Position[0], y_screen_origin - screen_height + player1Position[1], 80, 80);
}

void drawActivePlayer1() {
  stroke(255, 0, 0);
  fill(255, 0, 0);
  ellipse(x_screen_origin + player1Position[0], y_screen_origin - screen_height + player1Position[1], 80, 80);
}

void drawPlayer2() {
  noFill();
  stroke(0, 255, 0);
  ellipse(x_screen_origin + player2Position[0], y_screen_origin - screen_height  + player2Position[1], 80, 80);
}

void drawActivePlayer2() {
  stroke(0, 255, 0);
  fill(0, 255, 0);
  ellipse(x_screen_origin + player2Position[0], y_screen_origin - screen_height  + player2Position[1], 80, 80);
}

void drawPlayer1RemainingNotes() {
  fill(255, 0, 0);
  stroke(255, 0, 0);
  rect(
    padding,
    y_density1_origin - int(player1RemainingNotes/float(maxNumberOfNotes) * screen_height),
    bar_width,
    int(player1RemainingNotes/float(maxNumberOfNotes) * screen_height));
}

void drawPlayer2RemainingNotes() {
  fill(0, 255, 0);
  stroke(0, 255, 0);
  rect( 
    x_density2_origin,
    y_density2_origin - int(player2RemainingNotes/float(maxNumberOfNotes) * screen_height),
    bar_width,
    int(player2RemainingNotes/float(maxNumberOfNotes) * screen_height));
}

void displayPlayer1RemainingNotesText() {
  fill(255);
  textAlign(CENTER);
  textSize(padding * .8);
  text(str(player1RemainingNotes), padding + 0.5*bar_width, y_density1_origin - int(player1RemainingNotes/float(maxNumberOfNotes) * screen_height));
}

void displayPlayer2RemainingNotesText() {
  fill(255);
  textAlign(CENTER);
  textSize(padding * .8);
  text(str(player2RemainingNotes), 3*padding + screen_width + 1.5*bar_width, y_density1_origin - int(player2RemainingNotes/float(maxNumberOfNotes) * screen_height));
}

void drawTime() {
  fill(255);
  rect(2*padding + bar_width, padding, time, bar_width);
}

void displayTimeText() {
  fill(255);
  textAlign(CENTER);
  textSize(padding * .8);
  if (remainingPatterns != 1) {
    text("Time (" + str(remainingPatterns) + " patterns remaining)", 2*padding + bar_width + 0.5*screen_width, padding*0.9);
  }
  else {
    text("Time (last pattern remaining)", 2*padding + bar_width + 0.5*screen_width, padding*0.9);
  }
}

/*
void displayRemainingPatterns() {
  fill(255);
  textAlign(CENTER);
  textSize(bar_width);
  text(str(remainingPatterns), 3*padding + screen_width + bar_width*1.5, padding + bar_width*0.9);
}
*/

void generateRectanglesMask() {
  // Generate the canevas
  RPolygon s = RPolygon.createRectangle(
    x_screen_origin,
    y_screen_origin - screen_height,
    screen_width,
    screen_height
  );
  
  // Generate Rectangle 1
  RPolygon r1 = RPolygon.createRectangle(
    x_screen_origin + player1Rectangle[0],
    y_screen_origin - player1Rectangle[3],
    player1Rectangle[1] - player1Rectangle[0],
    player1Rectangle[3] - player1Rectangle[2]
  );&&
  
  // Generate Rectangle 2
  RPolygon r2 = RPolygon.createRectangle(
    x_screen_origin + player2Rectangle[0],
    y_screen_origin - player2Rectangle[3],
    player2Rectangle[1] - player2Rectangle[0],
    player2Rectangle[3] - player2Rectangle[2]
  );
  
  // Compute the mask
  rectanglesMask = new RPolygon();
  rectanglesMask = rectanglesMask.union(s);
  rectanglesMask = rectanglesMask.diff(r1);
  rectanglesMask = rectanglesMask.diff(r2);
  
  rectanglesMaskBorder = new RPolygon();
  rectanglesMaskBorder = rectanglesMaskBorder.union(r1);
  rectanglesMaskBorder = rectanglesMaskBorder.union(r2);
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
  //player1RectangleIndicator = false;
  //player2RectangleIndicator = false;
  //player1DensityIndicator = false;
  //player2DensityIndicator = false;
  //player1DensityBoundariesIndicator = false;
  //player2DensityBoundariesIndicator = false;  
  //timeIndicator = false;
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
  
  // Player1 Remaining Notes
  if (player1RemainingNotesIndicator && (player1RectangleIndicator || player2RectangleIndicator)) {
    drawPlayer1RemainingNotes();
    displayPlayer1RemainingNotesText();
  }
  
  // Player2 Remaining Notes
  if (player2RemainingNotesIndicator && (player1RectangleIndicator || player2RectangleIndicator)) {
    drawPlayer2RemainingNotes();
    displayPlayer2RemainingNotesText();
  }
  
  // Time
  if (timeIndicator) {
    drawTime();
  }
  
  /*
  if (remainingPatternsIndicator) {
    displayRemainingPatterns();
  }
  */
   
  if (player1RectangleIndicator || player2RectangleIndicator) {
  
    // Generate the mask
    generateRectanglesMask();
    
    // Draw the grey mask
    fill(50,50,50,230);
    stroke(255);
    rectanglesMask.draw(g);
    
    // Draw the mask inner border
    noFill();
    stroke(0, 0, 255);
    rectanglesMaskBorder.draw(g);
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
  
  // check if theOscMessage has the address pattern /rect. 
  if(theOscMessage.checkAddrPattern("/rect") && theOscMessage.checkTypetag("iffff")) {
    getRectangleBoundaries(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }

  // check if theOscMessage has the address pattern /rect_on. 
  if(theOscMessage.checkAddrPattern("/rect_on") && theOscMessage.checkTypetag("ii")) {
    getRectanglesToDisplay(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }

  // check if theOscMessage has the address pattern /dens_limit.
  if(theOscMessage.checkAddrPattern("/notes_remaining") && theOscMessage.checkTypetag("ii")) {
    getRemainingNotes(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }
  
  // check if theOscMessage has the address pattern /time. 
  if(theOscMessage.checkAddrPattern("/time") && theOscMessage.checkTypetag("f")) {
    getTime(theOscMessage);
    println("### received an osc message with address pattern "
      + theOscMessage.addrPattern()
      + " and typetag "
      + theOscMessage.typetag());
  }
  
  // check if theOscMessage has the address pattern /remaining. 
  if(theOscMessage.checkAddrPattern("/remaining") && theOscMessage.checkTypetag("i")) {
    getRemainingPatterns(theOscMessage);
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
    //player1RectangleIndicator = true;
  }
  // Second player
  else if (player == 1) {
    player2Rectangle[0] = int(x1 * screen_width);
    player2Rectangle[1] = int(x2 * screen_width);
    player2Rectangle[2] = int(y1 * screen_height);
    player2Rectangle[3] = int(y2 * screen_height);
    //player2RectangleIndicator = true;
  }
  
  //println("### ### Rectangle boundaries for player " + player + ": x1 = " + x1 + ", x2 = " + x2 + " y1 = " + y1 + ", y2 = " + y2);
}

void getRemainingNotes(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  int player = theOscMessage.get(0).intValue();
  int n = theOscMessage.get(1).intValue();
  
  // First player
  if (player == 0) {
    player1RemainingNotes = n;
    player1RemainingNotesIndicator = true;
  }
  // Second player
  else if (player == 1) {
    player2RemainingNotes = n;
    player2RemainingNotesIndicator = true;
  }
}

void getTime(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  float t = theOscMessage.get(0).floatValue();
  
  time = int(t * screen_width);
  timeIndicator = true;
  
  //println("### ### Time: " + t);
}

void getRemainingPatterns(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  int n = theOscMessage.get(0).intValue();
  
  remainingPatterns = n;
  remainingPatternsIndicator = true;
  
  //println("### ### Remaining patterns: " + remainingPatterns);
}

void getRectanglesToDisplay(OscMessage theOscMessage) {
  // parse theOscMessage and extract the values from the osc message arguments.
  int player = theOscMessage.get(0).intValue();
  int io = theOscMessage.get(1).intValue();
  
  // First player
  if (player == 0) {
    if (io == 1) {
      player1RectangleIndicator = true;
    }
    else {
      player1RectangleIndicator = false;
    }
    
  }
  // Second player
  else if (player == 1) {
    if (io == 1) {
      player2RectangleIndicator = true;
    }
    else {
      player2RectangleIndicator = false;
    }
  }
  
  println("### ### Display rectangle " + player + ": " + io);
}
