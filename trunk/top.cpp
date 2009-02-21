/*
  High Technology High School Robotics - MATE ROV
  Kevin Risden 2009
  
  Purpose:
    Control topside electronics for underwater ROV.
    * Takes input from 2 Joysticks
    * Outputs axis and button states to serial at 9600 baud 
  
  Hardware:
    1 - Arduino Nano
    2 - Joysticks
    
  Software:
    None
*/

//define joystick axis pins
#define Joy1xPin 0
#define Joy1yPin 1
#define Joy2xPin 2
#define Joy2yPin 3

//define top and trigger buttons
#define xyTopPin 2
#define xyTriggerPin 3
#define zTTopPin 4
#define zTTriggerPin 5

//declare input var for input
#include "WProgram.h"
void setup();
void loop();
int input = 0;

//declare input pin arrays
int analogInputPins[4] = {Joy1xPin,Joy1yPin,Joy2xPin,Joy2yPin};
int digitalInputPins[4] = {xyTopPin,xyTriggerPin,zTTopPin,zTTriggerPin};

void setup() {
  //open the serial port at 9600 bps
  Serial.begin(9600);
  
  //set digitalInputPins mode to Input
  for(int i=0; i<4; i++){
    pinMode(digitalInputPins[i], INPUT);
  }
}

void loop() {
  //read the analog input on pins 0-3
  //analog pins 0-3 = inputs from joysticks
  for(int i=0;i<4;i++) {
    input = analogRead(analogInputPins[i]);
    Serial.print(input); //echo input received (debugging)
    Serial.print(" "); //echo space for readability (debugging)
  }
  //read the digital input on pins 0-3
  //analog pins 0-3 = inputs from joysticks
  for(int i=0;i<4;i++) {
    input = digitalRead(digitalInputPins[i]);
    Serial.print(input); //echo input received (debugging)
    Serial.print(" "); //echo space for readability (debugging)
  }
  Serial.println(); //echo new line for next serial (debugging)
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

