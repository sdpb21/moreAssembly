int intX=0;
int intY=0;
int intZ=0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); // Initializes serial port
  while(!Serial){
    ; // wait for serial port to connect. Needed for native USB
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  intX=analogRead(A0);
  intY=analogRead(A1);
  intZ=analogRead(A2);
  Serial.print("X: ");
  Serial.print(intX);
  Serial.print(" Y: ");
  Serial.print(intY);
  Serial.print(" Z: ");
  Serial.println(intZ);
  delay(500);
}
