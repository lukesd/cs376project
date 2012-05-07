

import oscP5.*;
import netP5.*;

int[] coor1 = new int[2];
int[] coor2 = new int[2];

OscP5 oscP5;

/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 

void setup() {
  size(600, 600);
  frameRate(25);
  
  /* create a new instance of oscP5. 
   * 8000 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this, 8012);
  
  /* create a new NetAddress. a NetAddress is used when sending osc messages
   * with the oscP5.send method.
   */
  
  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress("127.0.0.1", 8000);
}


void draw() {
  background(0);
  ellipse(coor1[0], coor1[1], 80, 80);
  ellipse(coor2[0], coor2[1], 40, 40);
}


void mousePressed() {
  /* create a new OscMessage with an address pattern, in this case /test. */
  OscMessage myOscMessage = new OscMessage("/test");
  /* add a value to the OscMessage */
  int[] coordinates = new int[2];
  coordinates[0] = mouseX;
  coordinates[1] = mouseY;
  myOscMessage.add(coordinates);
  /* send the OscMessage to a remote location specified in myNetAddress */
  oscP5.send(myOscMessage, myBroadcastLocation);
}


void keyPressed() {
  OscMessage m;
  switch(key) {
    case('c'):
      /* connect to the broadcaster */
      m = new OscMessage("/server/connect", new Object[0]);
      oscP5.flush(m, myBroadcastLocation);  
      break;
    case('d'):
      /* disconnect from the broadcaster */
      m = new OscMessage("/server/disconnect", new Object[0]);
      oscP5.flush(m, myBroadcastLocation);  
      break;

  }  
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
      if (player == 1) {
        coor1[0] = int(x * 600);
        coor1[1] = int(y * 600);
      }
      else if (player == 2) {
        coor2[0] = int(x * 600);
        coor2[1] = int(y * 600);
      }
      return;
    }
  }
  println("### received an osc message. with address pattern "+
          theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
}
