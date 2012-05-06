

import oscP5.*;
import netP5.*;


OscP5 oscP5;

/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 

void setup() {
  size(640, 960);
  frameRate(25);
  
  /* create a new instance of oscP5. 
   * 8000 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this, 8000);
  
  /* create a new NetAddress. a NetAddress is used when sending osc messages
   * with the oscP5.send method.
   */
  
  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress("127.0.0.1", 8000);
}


void draw() {
  background(0);
  ellipse(mouseX, mouseY, 80, 80);
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
  /* get and print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
}
