import de.voidplus.leapmotion.*;


LeapMotion leap;
float fist = 0;
boolean pitchStatus = false;


color[] Colors = { 
  #112D4C, //Space Cadet
  #2DB386, //Jungle Green
  #D72638, //Rose Madder
  #FFFFFF, //White
  #FF570A // Orange Pantone
};

//Defining basic structure for rectangle
int rectWidth = 400;
int rectHeight = int(rectWidth*0.618);
int stX1 = width/2, stY1 = height/2;

//Introducing Bezier points and handles //<>//
float x1,y1,cx1,cy1,cx2,cy2,x2,y2;
float cVald1, cVald2;


float DraggingMode = -1; //<>//
float pWidth = 20;
boolean hidden = false;
boolean swipeCount = false;
int swipe =0;

PVector fingerThumbPosition = new PVector(0, 0, 0);
PVector fingerIndexPosition = new PVector(0, 0, 0);

beziere[] bezs;
JSONObject json;
int ct = 0;

void setup() { //<>//
  size(800, 800);
  smooth();
  loadData();
  //systems = new ArrayList<pinchSystem>();
  leap = new LeapMotion(this).allowGestures();  // All gestures
  //frameRate(10);
  x1 = ((width/2)-(rectWidth/2));
  y1 = ((height/2)-(rectHeight/2))+50;
  x2 = ((width/2)+(rectWidth/2));
  y2 = ((height/2)+(rectHeight/2))-50;;
  cx1 = x1+80;
  cy1 = y1+80;
  cx2 = x2-80;
  cy2 = y2-80;
}

void draw() {
  translate(0,200);

  background(Colors[0]); //<>//
  
  //Draw beziers from json
  for(beziere b : bezs){
      b.display();
  }
  
  if(swipeCount == true){
    for(beziere b : bezs){
      b.display();
    }
  }  

  /*Start Base Structure*/
  structure();
  /*End of Base Structure*/

  textSize(12);
  pinch();
  pinchDragged();
  for (Hand hand : leap.getHands ()) {
    float handGrab = hand.getGrabStrength();
    fist = handGrab;
    Finger fingerThumb = hand.getThumb();
    Finger fingerIndex = hand.getIndexFinger();
    fingerThumbPosition = fingerThumb.getPosition();
    fingerIndexPosition = fingerIndex.getPosition();
    ellipse(fingerThumbPosition.x, fingerThumbPosition.y, 5, 5);  
    ellipse(fingerIndexPosition.x, fingerIndexPosition.y, 5, 5);  
  }
  
  for (Hand hand : leap.getHands ()) {
    float handPinch = hand.getPinchStrength();
    //Drawing Bezier points and Handles
    if (!hidden) {
      fill(Colors[4]);
      ellipse(x1, y1, pWidth, pWidth);
      fill(Colors[3]);  
      ellipse(cx1, cy1, pWidth, pWidth);
      fill(Colors[3]);
      ellipse(cx2, cy2, pWidth, pWidth);
      fill(Colors[4]);
      ellipse(x2, y2, pWidth, pWidth);
      
      //Handle Connectors
      fill(Colors[2]);
      stroke(255);
      strokeWeight(4);
      line(x1, y1, cx1, cy1);
      line(x2, y2, cx2, cy2);
    }
    
  } 
  noFill();
  bezier(
    x1, y1, 
    cx1, cy1, 
    cx2, cy2, 
    x2, y2
    );
}

void pinch() {
  float distance = dist(fingerThumbPosition.x, fingerThumbPosition.y, fingerIndexPosition.x, fingerIndexPosition.y);
  //println(distance);
  if (distance <= 40) {
    pitchStatus = true;
    //println("pinch");
  } else {
    pitchStatus = false;
    DraggingMode = -1;
  }
  
  
}

void pinchDragged() {

  float d1 = dist(fingerThumbPosition.x, fingerThumbPosition.y, x1, y1);
  
  if ((d1 <= 40) && pitchStatus == true)
  {
    y1 = fingerThumbPosition.y;
    cVald1 = y1;
  }
  float d2 = dist(fingerThumbPosition.x, fingerThumbPosition.y, x2, y2);
  if ((d2 <= 30) && pitchStatus == true) 
  {
    //x2 = fingerThumbPosition.x;
    //x2=560;
    y2 = fingerThumbPosition.y;
    cVald2 = y2;
    //pWidth = 30;
  } 
  
  float d3 = dist(fingerThumbPosition.x, fingerThumbPosition.y, cx1, cy1);
  if ((d3 <= 30) && pitchStatus == true) 
  {
  
    cx1 = fingerThumbPosition.x;
    cy1 = fingerThumbPosition.y;
    
  }
  
  float d4 = dist(fingerThumbPosition.x, fingerThumbPosition.y, cx2, cy2);
  if ((d4 <= 30) && pitchStatus == true) 
  {
    cx2 = fingerThumbPosition.x;
    cy2 = fingerThumbPosition.y;
    //pWidth = 30;
  } 
  
  if(pitchStatus == true){
    pWidth = 30;
  } else {
    pWidth = 20;
  }
  //println("x1="+x1+","+"y1="+y1+","+"cx1="+cx1+","+"cy1="+cy1+","+"x2="+x2+","+"y2="+y2+","+"cx2="+cx2+","+"cy2="+cy2+",");
}

void loadData(){
   //Load JSON File
   json = loadJSONObject("data.json");
   
   JSONArray bezData = json.getJSONArray("bezs");
   
   //The size of the array
   bezs = new beziere[bezData.size()];
   
   for(int i = 0; i < bezData.size(); i++){
     //Get object in Array
     JSONObject bezObj = bezData.getJSONObject(i);
     
     //get Position object     
     JSONObject position = bezObj.getJSONObject("position");
   
     //Getting properties and values.
     float x1 = position.getFloat("x1");
     float y1 = position.getFloat("y1");
     float cx1 = position.getFloat("cx1");
     float cy1 = position.getFloat("cy1");
     float cx2 = position.getFloat("cx2");
     float cy2 = position.getFloat("cy2");
     float x2 = position.getFloat("x2");
     float y2 = position.getFloat("y2");
     
     //Put object in array
     bezs[i] = new beziere(x1,y1,  cx1, cy1,  cx2, cy2, x2, y2);  
     //println(i+" : "+bezs[i]);
   }
}

void leapOnSwipeGesture(SwipeGesture g, int state){
  int     id               = g.getId();
  Finger  finger           = g.getFinger();
  PVector position         = g.getPosition();
  PVector positionStart    = g.getStartPosition();
  PVector direction        = g.getDirection();
  float   speed            = g.getSpeed();
  long    duration         = g.getDuration();
  float   durationSeconds  = g.getDurationInSeconds();
  
  //Write DATA to Json on swipe
  swipeCount = true;
  swipe = 1;
  println("Data Saved");
  writeJson();
  swipe = 0;
}


public class beziere{
  float x1,y1, cx1, cy1, cx2, cy2, x2, y2;
  boolean over = false;
  
 //Create the beziere
 
   beziere(float x1_,float y1_,float cx1_, float cy1_, float cx2_, float cy2_, float x2_,float y2_){
      x1 = x1_;
      y1 = y1_;
      cx1 = cx1_;
      cy1 = cy1_;
      cx2 = cx2_;
      cy2 = cy2_;
      x2 = x2_;
      y2 = y2_;
    }
    
    
    
  //Display Bezier
 public void display(){
    
    stroke(150);
    strokeWeight(1);
    noFill();
    //background(255);
    bezier(x1,y1,  cx1, cy1,  cx2, cy2, x2, y2);
     
  }
  
}
// JSON

void writeJson(){
  if(swipe == 1){
      println(swipe);
    //  //write json
    //  //Create New JSON position object
      JSONObject newPos = new JSONObject();

    //  //Creating New Json position object
      JSONObject position = new JSONObject();
      position.setFloat("x1", x1);
      position.setFloat("y1", y1);
      position.setFloat("cx1", cx1);
      position.setFloat("cy1", cy1);
      position.setFloat("cx2", cx2);
      position.setFloat("cy2", cy2);
      position.setFloat("x2", x2);
      position.setFloat("y2", y2);
      //println("x1="+x1+","+"y1="+y1+","+"cx1="+cx1+","+"cy1="+cy1+","+"x2="+x2+","+"y2="+y2+","+"cx2="+cx2+","+"cy2="+cy2+",");
      
      //Add position to bezs
      newPos.setJSONObject("position", position);
      //println("x1="+x1+","+"y1="+y1+","+"cx1="+cx1+","+"cy1="+cy1+","+"x2="+x2+","+"y2="+y2+","+"cx2="+cx2+","+"cy2="+cy2+",");
      
      //Write data to json
      JSONArray bezData = json.getJSONArray("bezs");
      bezData.append(newPos);
      
      saveJSONObject(json,"dataCopy.json");
      swipeCount = false;
      swipe = 0;
    }

}





void structure(){  
  //Draw graph for in rectangle
    pushStyle();
      fill(0);
      
      //DRAW A CENTER POINT
      ellipse(width/2, height/2,3,3);
      stroke(Colors[3]);
      strokeCap(SQUARE);

      //Define starting co-ordinate variable for line
      stX1 = width/2-180;
      stY1 = height/2-180;
      strokeWeight(4);
      
      line((width/2)-(rectWidth/2),(height/2)-(rectHeight/2),(width/2)-(rectWidth/2),(height/2)+(rectHeight/2));
      line((width/2)+(rectWidth/2),(height/2)-(rectHeight/2),(width/2)+(rectWidth/2),(height/2)+(rectHeight/2));
      
      //Print horizontal line measures
      int newX1 = (width/2)-(rectWidth/2);
      int newY1 = ((height/2)-(rectHeight/2));
      int newX2 = (width/2)-(rectWidth/2);
      int newY2 = (height/2)+(rectHeight/2);
      int increment = rectHeight/10;
      
      for(int i = newY1+2, j=0,k=100;i<=newY2;i+=increment, j+=10,k-=10){
        //println("Inc = "+i);
        strokeWeight(4);
        fill(Colors[2]);
        line(newX1,i,newX1+10,i); 
        line(newX1+rectWidth,i,newX1+rectWidth-10,i); 
        fill(Colors[3]);
        textAlign(RIGHT);
        text(j, newX1-10,i+5);
        textAlign(LEFT);
        text(k, newX1+rectWidth+10,i+5);
      }
      
      int beginRate =  int(map(cVald1, newY1,newY2,0,100));
      text(beginRate, newX1-50, height);
      
    popStyle();
  
  
    //Display Texts
    pushMatrix();
    fill(Colors[3]);
    textSize(18);
    textAlign(CENTER);
    String s1 = "Rate your life at AAU until now?";
    String s2 = "Swipe once you are done.";
    text(s1, width/2-200, 200, height/2, 200);
    text(s2, width/2-200, 550, width/2, 550);
    popMatrix();
    
    pushMatrix();
    fill(Colors[3]);
    textSize(12);
    textAlign(CENTER);
    text("Beginning", newX2, newY2+20);
    text("Now", (width/2)+(rectWidth/2), newY2+20);
    
    text("Sad", newX2, newY1-20);
    text("Happy", (width/2)+(rectWidth/2), newY1-20);
    popMatrix();


}
