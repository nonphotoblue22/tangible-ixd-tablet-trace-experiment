// STEP 0: LIBRARIES
import processing.serial.*;

// STEP 1: VARS

// Layers so that stuff doesn't get redrawn
// declaring new PGraphics Objects in the program
PGraphics copyLayer;
PGraphics pointLayer;

// Fonts I'm planning to use
String spartanBold; // League Spartan = [380];
String crimsonTextReg; // Crimson Text = [170];

// Initializing new PFont Objects for reference later
PFont titleFont, bodyCopyFont, xyTextFont;
// Initializing new Strings and StringArrays for text to use later
boolean status = false;
String statusText = "OFF";
String xyText = "";

String titleCopy = "Write a word below";
String GeneratedText[] = {
  "Fruit",
  "Apple",
  "Wordpress",
  "Derp",
  "Make it Stop",
  "Please",
  "Thank you",
  "Oh Snap"
};
int topPaddingBodyCopy = 45;

// set up an array to hold all the fonts available to you
String[] myFonts;

// this iterator will allow us to use the draw() loop as a for() loop
int iterator = 0;

//Arduino Value stuff...
String value;
int potLevel, buttonVal = 0;
float brushSize = 5;
Serial myPort;

void setup(){
  size(800, 600);
  // construct PGraphics image for stuff later
  copyLayer = createGraphics(width, height);
  pointLayer = createGraphics(width, height);
  
  // PFont.list() function returns the array of the names of all of the fonts available to you
  // you'll populate our pre-made array with those names
  myFonts = PFont.list();
  
  // and use printArray() function to display them in the terminal
  spartanBold = myFonts[380];
  crimsonTextReg = myFonts[170];
  
  // constructors for new font objects to reference later
  titleFont = createFont(spartanBold, 18, true);
  bodyCopyFont = createFont(crimsonTextReg, 12, true);
  
  // constructors to serial connection + print to makesure what's connected
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[3], 9600);

  
  println("setup() complete.");
}

void draw(){
  String bodyCopy[] = {
  "Record Writing:" + statusText,
  "Press button to generate your handwriting to text format",
  "Generated text:" + xyText,
  // Generated Text to be Tesseracted: https://github.com/tesseract-ocr/tesseract
  // LOL
  };
  // set status text;
  if (status == true){
    statusText = "ON";
  } else {
    statusText = "OFF";
  }
  
  background(255);

  // begin buffer for PGraphics
  copyLayer.beginDraw();
    // run all the stuff for first layer of pGraphics object called copyLayer
    copyLayer.background(255); // create bg
    copyLayer.fill(200);
    copyLayer.noStroke();
    copyLayer.rect(7,82.5,10,10);
    copyLayer.fill(0);
    copyLayer.ellipse(12,87,5,5);
    copyLayer.fill(102); // set Fill
    copyLayer.textFont(titleFont); // set font to title copy
    copyLayer.textAlign(LEFT, TOP); // set the alignment to center
    copyLayer.text(titleCopy, 25, 18*2); // Title + Body Copy
    copyLayer.textFont(bodyCopyFont); // set new text font
    // loop throught body copy to display all strings in Text
    for (int i = 0; i < bodyCopy.length; i++) {
      copyLayer.text(bodyCopy[i], 25, topPaddingBodyCopy+(18*(i+1)));
    }
  copyLayer.endDraw(); // end buffer for PGraphics

  image(copyLayer, 0, 0); // show image

  // mouse pointer vars running each loop
  String xPos = str(mouseX);
  String yPos = str(mouseY);
  String mousePosition = xPos + ", " + yPos;
  // make cursor appear the size of brush
  ellipse(mouseX, mouseY, brushSize, brushSize);
  // begin buffer for PGraphics
  pointLayer.beginDraw();
    //run all the junk
    pointLayer.textFont(bodyCopyFont); // set font
    pointLayer.fill(199); // set fill
    pointLayer.noStroke();
    //pointLayer.ellipse(mouseX, mouseY, 1, 1); // draw point
    // if mousePressed is true, then draw the text on the screen!
    if (mousePressed == true) {
      status = true;
      // three values show up for this... why? is a mouse press need to be cleaned up?
      println(mousePosition);
      pointLayer.fill(60);
      //pointLayer.ellipse(mouseX, mouseY, 1, 1);
      //pointLayer.text(mousePosition, int(xPos), int(yPos));
      pointLayer.ellipse(int(xPos), int(yPos), brushSize, brushSize);
      // send over to Arduino to make LED go on.
      myPort.write('x');
    } else {
      status = false;
      // send to turn off.
      myPort.write('o');
    } //end mousePressed listener.
    
    if (buttonVal == 1) {
      pointLayer.clear();
    }
    
  pointLayer.endDraw();// end buffer for PGraphics
  
  image(pointLayer, 0, 0); // show image
  
  // arduino values
  // if serial data on our port is available
  if ( myPort.available() > 0) {
    // read a chunk of it until we get to the EOL character (see the Arduino sketch)
    // and store it in the 'value' container
    value = myPort.readStringUntil('\n');         
  }
  // here is some cleanup:
  // let's make sure the value is not null
  // it can happen if there is a communication error - we can disregard those errors
  if( value != null ){
    // trim some possible white space junk
    // just in case
    value = value.trim();
    // make an array of integers; split the String we received from the serial port ('value')
    // into chunks at the "TAB" symbols; convert the resulting chunks into integers
    int mysensors[] = int(split(value, '\t'));
    
    //make sure we have all 3 values
    if(mysensors.length == 2){
      //assign those values to the corrresponding variables
      potLevel = mysensors[0];
      buttonVal = mysensors[1];
    }
  }
  brushSize = map(potLevel, 0, 1024, 1, 25);
  println(brushSize);

}
