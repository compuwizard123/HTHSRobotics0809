/*
  High Technology High School Robotics - MATE ROV
  Kevin Risden 2009
  
  Purpose:
    Control bottomside electronics for underwater ROV
    * Takes serial input from topside arduino
    * Outputs pwm to TLC5940 to control propulsion motors
  
  Hardware:
    1 - Arduino Nano
    1 - TLC5940
  
  Software:
    Standard Header - stdlib.h
    TLC5940 Library - http://code.google.com/p/tlc5940arduino/
    Messenger Library - http://www.arduino.cc/playground/Code/Messenger
*/

#include "stdlib.h" 
#include "tlc_config.h"
#include "Tlc5940.h"
#include <Messenger.h>

Messenger message = Messenger(); //Instantiate Messenger object with the default separator (the space character)

//define joystick top and trigger pins
#define xyTopPin 2
#define xyTriggerPin 4
#define zTTopPin 7
#define zTTriggerPin 8

//declare output pin arrays
int digitalOutputPins[4] = {xyTopPin,xyTriggerPin,zTTopPin,zTTriggerPin};

//declare data var for serial input
int data[8] = {0,0,0,0,0,0,0,0};

//declare channel variable
int chan;

//declare percent x,y,T vars
float xper,yper,Tper;

//declare Motors to x,y,T - {1,2,3,4}
int Motx[4] = {-1,1,1,-1};
int Moty[4] = {-1,-1,1,1};
int MotT[4] = {-1,1,-1,1};

//declare temp var for calculations
float temp;

void setup() {
  ///open serial port at 9600 bps
  Serial.begin(9600);
  
  //initialize the tlc5940 library
  Tlc.init();
  
  //set digitalOutputPins mode to Output
  for(int i=0; i<4; i++) {
    pinMode(digitalOutputPins[i], OUTPUT);
  }
}

void loop() {
  //clear old PWM settings and reset MotPow
  Tlc.clear();  
  float MotPow[6] = {0,0,0,0,0,0};
  
  //get serial information from top
  while ( Serial.available() ) { //check if Serial available
    if ( message.process(Serial.read() ) ){
      int i=0;
      while(message.available()) { //loop through all parts of serial
        data[i] = message.readInt();
        if(i<4) {
          if((data[i]-512)<10&&(data[i]-512)>(-10)) {
            data[i] = 0; 
          } else {
            data[i] = map(data[i], 0, 1023, 0, 4095)-2048; //map serial data from 0-1023 to 0-4095 for tlc pwm
          }
        }
        //Serial.print(data[i]); //echo data received (debugging)
        //Serial.print(" "); //echo space for readability (debugging)
        i++;
      }
      //Serial.println(); //echo new line for next serial (debugging)
    }
  }
  
  //declare x,y,T,z,channel vars
  int x = data[0];
  int y = data[1];
  int T = data[2];
  int z = data[3];
  
  //gets percentage of power for x,y,T
  //if(x>
  xper = x/2048.0;
  yper = y/2048.0;
  Tper = T/2048.0;
  
  //find power for each motor based on x,y,T inputs
  for(int i=0; i<=3; i++) {
    temp = (xper*Motx[i])+(yper*Moty[i])+(Tper*MotT[i]);
    MotPow[i] = (temp > 1) ? 1 : temp; //if % > 1 then = 1
    MotPow[i] = MotPow[i]*4095;
  }
  
  //direct mapping of z to motors 5+6
  MotPow[4] = 2*z;
  MotPow[5] = 2*z;
  
  //loop through data and set tlc pwm for each motor
  for(int i=0; i<6; i++) {
    chan = i*2;
    MotPow[i] = constrain(MotPow[i], -4095, 4095);
    if(MotPow[i]<0) {
      Tlc.set(chan, 0);
      Tlc.set(chan+1, (-1)*MotPow[i]);
    } else {
      Tlc.set(chan, MotPow[i]);
      Tlc.set(chan+1, 0);
    }
  }
  
  //set digital outputs to state of each joystick button
  for(int i=0; i<4; i++) {
    (data[i+4] == 1) ? digitalWrite(digitalOutputPins[i], LOW) : digitalWrite(digitalOutputPins[i], HIGH);
  }
  
  //debugging for motor outputs
  for(int i=0; i<6; i++) {
   Serial.print(i);
   Serial.print(" ");
   Serial.print(MotPow[i]);
   Serial.print(" ");
  }
  Serial.print("      ");
  //debugging for top and trigger buttons
  for(int i=4; i<8; i++) {
    Serial.print(i);
    Serial.print(" ");
    Serial.print(data[i]);
    Serial.print(" ");
  }
  Serial.println();
  
  //send set pwm values to tlc5940
  Tlc.update();
}
