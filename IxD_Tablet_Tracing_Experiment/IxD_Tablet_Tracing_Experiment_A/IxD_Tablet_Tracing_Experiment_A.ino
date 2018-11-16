int potPin = A0;
int buttonPin = 4;
int ledPin = 6;

void setup() {
  pinMode(potPin, INPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT);

  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) {
    char input = Serial.read();
    int sensor = analogRead(A0);
    if (input != 'x') {
      digitalWrite(ledPin, LOW); 
    } else {
      digitalWrite(ledPin, HIGH); 
    }
  }// end Serial available check

  delay(100);      
  // Read the value of the potentiometer sensor and assign it 
  // to a variable called 'val'
  int val = analogRead(potPin); // get analog value
  Serial.print(val);
  // Send a TAB symbol for separation
  Serial.print("\t");
  // Read the value of the button and assign it to a variable called 'val'  
  // Send the 'val' and the TAB symbol down the serial port
  val = digitalRead(buttonPin);
  Serial.print(val);
  Serial.println();
}
