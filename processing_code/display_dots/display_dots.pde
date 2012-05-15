

import oscP5.*;
import netP5.*;

int[] coor1 = new int[2];
int[] coor2 = new int[2];

OscP5 oscP5;



//
// Metaball Class
///////////////////

class Metaball{
  // Shape Members
  float x,y;
  float radius;
  color value;
  // Motion Members
  float mspeedx, msizex, mcenterx;
  float mspeedy, msizey, mcentery;
  
  // Constructor
  Metaball (float cw, float ch){
    //mspeedx = random(1,20);
    //mspeedy = random(1,20);
    msizex = random(cw/32,cw/3);
    msizey = random(ch/32,ch/3);
    mcenterx = random(msizex, cw-msizex);
    mcentery = random(msizey, ch-msizey);
    radius = random((cw+ch)/16,(cw+ch)/8);
    colorMode(HSB, 1.0);
    value = color(random(1.0),random(0.75,1.0),random(0.75,1.0));
    Move(0);
    
  }
  
  // motion control
  void Move (int t){
    if (t == 0) {
    x = coor1[0];
    y = coor1[1];
    }
    else {
      x = coor2[0];
      y = coor2[1];
    }
  }
  
  // influence
  float Influence(float a, float b){
    float d = sqrt(((a-x)*(a-x)) + ((b-y)*(b-y)));
    if (d < radius){
      float dd = (0.707*d)/radius;
      float g = ((dd*dd*dd*dd) - (dd*dd) + 0.25);
      return (4*g);
    }
    else {
      return 0.0;
    }
  }
  
  // draw 
  void Draw(){
    stroke(value);
    fill(value,32);
    ellipse(x, y, radius*2, radius*2);
    noFill();
    ellipse(x, y, radius*2, radius*2);
    ellipse(x, y, 4, 4);
  }
  
  color GetColor(){
    return value;
  }
}



/**
 * Metaballs
 **/


// Canvas Size
int width = 300;
int height = 300;

//Time
float time = 0.0;

//Metaballs
int mbcount;
Metaball[] mbs;

// Misc
float pi = 3.14159265;
float d2r = (2*pi)/360.0;
boolean debug = false;
boolean sav = false;




/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 


// setup
void setup(){
  // Basic Settings
  size(width, height);
  frameRate(30);
  background(0);

  // Init metaballs array
  // randomSeed(7);
  //mbcount = round(random(3,8));
  mbcount = 2;
  mbs = new Metaball[mbcount];
  for (int i=0; i<mbcount; i++){
    mbs[i] = new Metaball(width, height);
  }
  
  // init drawing
  smooth();
  colorMode(RGB,255);
  
  /* create a new instance of oscP5. 
   * 8000 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this, 8012);
}


void draw(){
  // draw init
  time+= 0.5;
  background(0);

  // Metaballs Motion
  for (int m=0; m<mbcount; m++){
    mbs[m].Move(m);
  }

  // Metaballs rendering
  for (int i = 0; i < width; i++){
    for (int j = 0; j < height; j++){
      // init current inf
      float inf = 0.00001;
      float r = 0.0;
      float g = 0.0; 
      float b = 0.0;
      ///*
      for (int m=0; m < mbcount; m++){
        inf += mbs[m].Influence(i, j);
        color col = mbs[m].GetColor();
        float val = mbs[m].Influence(i, j);
        r += val * red(col);
        g += val * green(col);
        b += val * blue(col);
      }
      //*/
      if (inf>0.5){
        stroke (0.5*r,0.5*g,0.5*b);
        //point(i,j);
      }else{
        if (inf>0.4){
          float val = 1.5 * (1 - (20 * abs(inf-0.45)));
          stroke(val * r,val * g,val * b);
          point(i,j);
        }
      }
      
    }
  }

  // Debug display
  if (debug){
    for (int m=0; m<mbcount; m++){
      mbs[m].Draw();
    }
  }
}
/*
void draw() {
  background(0);
  /*ellipse(coor1[0], coor1[1], 80, 80);
  ellipse(coor2[0], coor2[1], 40, 40);
  ellipse(coor2[0], coor2[1], 40, 40);
  mousePressed();
}*/


void mousePressed() {
  /* create a new OscMessage with an address pattern, in this case /test. */
  OscMessage myOscMessage = new OscMessage("/test");
  /* add a value to the OscMessage */
  ellipse(mouseX, mouseY, 80, 80);
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */  
  if(theOscMessage.checkAddrPattern("/new_note") == true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("iff")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      int player = theOscMessage.get(0).intValue();  // get the first osc argument
      float x = theOscMessage.get(1).floatValue(); // get the second osc argument
      float y = theOscMessage.get(2).floatValue(); // get the third osc argument
      print("### received an osc message /test with typetag iff.");
      println(" values: " + player + ", " + x + ", " + y);
      if (player == 0) {
        coor1[0] = int(x * 300);
        coor1[1] = int(y * 300);
      }
      else if (player == 1) {
        coor2[0] = int(x * 300);
        coor2[1] = int(y * 300);
      }
      return;
    }
  }
  println("### received an osc message. with address pattern "+
    theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag() + coor1[0]+coor1[1]);
}
