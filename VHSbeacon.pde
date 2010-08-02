// VHSbeacon - firmware for VHS beacon for blue robot challenge
//

#include <IRremote.h>

#define CAPTURE_RED  0
#define CAPTURE_BLUE 1
#define STATUS_RED   2
#define STATUS_BLUE  3

#define NEUTRAL       0
#define CAPTURED_RED  1
#define CAPTURED_BLUE 2
int beacon_state = NEUTRAL;

#define IS_NEUTRAL (beacon_state == NEUTRAL)
#define IS_RED     (beacon_state == CAPTURED_RED)
#define IS_BLUE    (beacon_state == CAPTURED_BLUE)

unsigned long reset_at = 0;

/* For the Multicolour LEDs */
#define LED_HIGH 64
#define LED_LOW  0
#define LED_R_pin 11
#define LED_G_pin 9
#define LED_B_pin 10

#define LED_OFF 0
#define LED_RED 1
#define LED_GREEN 2
#define LED_BLUE 3

IRsend irsend;
decode_results results;
IRrecv irrecv(4); // send ir input pin as argument

void setup() {
  irrecv.enableIRIn(); // initializes irrecv

  pinMode(LED_R_pin, OUTPUT);
  pinMode(LED_G_pin, OUTPUT);
  pinMode(LED_B_pin, OUTPUT);

  update_LED( LED_RED ); 
  delay(400);
  update_LED( LED_BLUE ); 
  delay(400);
  update_LED( LED_GREEN ); 
  delay(400);
  update_LED( LED_OFF );
}

void loop() {
   unsigned long receive_until = millis() + 100;

   while (millis() < receive_until) {
     if (irrecv.decode(&results)) {
       if ((results.bits == 1) || (results.bits == 2)) {
           switch (results.value) {
               case CAPTURE_RED:
                   beacon_state = CAPTURED_RED;
  //                 reset_at = millis() + 5000;
                   update_LED( LED_RED );
                   break;
               case CAPTURE_BLUE:
                   beacon_state = CAPTURED_BLUE;
 //                  reset_at = millis() + 5000;
                   update_LED( LED_BLUE );
                   break;
           }
       }
       irrecv.resume(); // Receive the next value
     };
   }

   if ((reset_at != 0) && (millis() >= reset_at)) {
     beacon_state = NEUTRAL;
     update_LED( LED_GREEN );
     reset_at = 0;
   }

   receive_until = millis() + 100;
   while (millis() < receive_until) {
     if (IS_NEUTRAL) {
         irsend.sendVHS(STATUS_RED, 2);
     }
     else if (IS_BLUE) {
         irsend.sendVHS(STATUS_RED, 2);
     }
     else if (IS_RED) {
         irsend.sendVHS(STATUS_BLUE, 2);
     }
   }
}

void update_LED ( int LED_COLOUR ) {
  int red = 0;
  int green = 0;
  int blue = 0;
  switch( LED_COLOUR ){
    case LED_OFF:
      break;
    case LED_RED:
      red = LED_HIGH;
      break;
    case LED_BLUE:
      blue = LED_HIGH;
      break;
    case LED_GREEN:
      green = LED_HIGH;
      break;
  }
  analogWrite(LED_R_pin, red);
  analogWrite(LED_G_pin, green);
  analogWrite(LED_B_pin, blue);
}

