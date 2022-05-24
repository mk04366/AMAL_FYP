// Encoder output to Arduino Interrupt pin. Tracks the tick count.
#define ENC_IN_LEFT_1_A 19
#define ENC_IN_RIGHT_1_A 18
#define ENC_IN_LEFT_2_A 2
#define ENC_IN_RIGHT_2_A 3


// Other encoder output to Arduino to keep track of wheel direction
// Tracks the direction of rotation.
#define ENC_IN_LEFT_1_B 53
#define ENC_IN_RIGHT_1_B 52
#define ENC_IN_LEFT_2_B 47
#define ENC_IN_RIGHT_2_B 46
 
// True = Forward; False = Reverse
boolean Direction_left = true;
boolean Direction_right = true;
 
// Minumum and maximum values for 16-bit integers
const int encoder_minimum = -32768;
const int encoder_maximum = 32767;
 
// Keep track of the number of wheel ticks
volatile int left_wheel_tick_1 = 0;
volatile int right_wheel_tick_1 = 0;
volatile int left_wheel_tick_2 = 0;
volatile int right_wheel_tick_2 = 0;


// One-second interval for measurements
int interval = 1000;
long previousMillis = 0;
long currentMillis = 0;

// Variable for RPM measuerment
float rpm_right_1 = 0;
float rpm_left_1 = 0;
float rpm_right_2 = 0;
float rpm_left_2 = 0;



// Variable for angular velocity measurement
float ang_velocity_right_1 = 0;
float ang_velocity_right_deg_1 = 0;
float ang_velocity_left_1 = 0;
float ang_velocity_left_deg_1 = 0;

float ang_velocity_right_2 = 0;
float ang_velocity_right_deg_2 = 0;
float ang_velocity_left_2 = 0;
float ang_velocity_left_deg_2 = 0;
 
 
void setup() {
 
  // Open the serial port at 9600 bps
  Serial.begin(9600); 
 
  // Set pin states of the encoder
  pinMode(ENC_IN_LEFT_1_A , INPUT_PULLUP);
  pinMode(ENC_IN_LEFT_1_B , INPUT);
  pinMode(ENC_IN_RIGHT_1_A , INPUT_PULLUP);
  pinMode(ENC_IN_RIGHT_1_B , INPUT);

  pinMode(ENC_IN_LEFT_2_A , INPUT_PULLUP);
  pinMode(ENC_IN_LEFT_2_B , INPUT);
  pinMode(ENC_IN_RIGHT_2_A , INPUT_PULLUP);
  pinMode(ENC_IN_RIGHT_2_B , INPUT);
 
  // Every time the pin goes high, this is a tick
  attachInterrupt(digitalPinToInterrupt(ENC_IN_LEFT_1_A), left_wheel_tick_1, RISING);
  attachInterrupt(digitalPinToInterrupt(ENC_IN_RIGHT_1_A), right_wheel_tick_1, RISING);
  attachInterrupt(digitalPinToInterrupt(ENC_IN_LEFT_2_A), left_wheel_tick_2, RISING);
  attachInterrupt(digitalPinToInterrupt(ENC_IN_RIGHT_2_A), right_wheel_tick_2, RISING);
}
 
void loop() {
 
  // Record the time
  currentMillis = millis();
 
  // If one second has passed, print the number of ticks
  if (currentMillis - previousMillis > interval) {
     
    previousMillis = currentMillis;
 
    Serial.println("Number of Ticks: ");
    Serial.println(right_wheel_tick_count);
    Serial.println(left_wheel_tick_count);
    Serial.println();
  }
}
 
// Increment the number of ticks
void right_wheel_tick_1() {
   
  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_IN_RIGHT_1_B);
 
  if(val == LOW) {
    Direction_right = false; // Reverse
  }
  else {
    Direction_right = true; // Forward
  }
   
  if (Direction_right) {
     
    if (right_wheel_tick_count_1 == encoder_maximum) {
      right_wheel_tick_count_1 = encoder_minimum;
    }
    else {
      right_wheel_tick_count_1++;  
    }    
  }
  else {
    if (right_wheel_tick_count_1 == encoder_minimum) {
      right_wheel_tick_count_1 = encoder_maximum;
    }
    else {
      right_wheel_tick_count_1--;  
    }   
  }
}
 
// Increment the number of ticks
void left_wheel_tick_1() {
   
  // Read the value for the encoder for the left wheel
  int val = digitalRead(ENC_IN_LEFT_1_B);
 
  if(val == LOW) {
    Direction_left = true; // Reverse
  }
  else {
    Direction_left = false; // Forward
  }
   
  if (Direction_left) {
    if (left_wheel_tick_count == encoder_maximum) {
      left_wheel_tick_count = encoder_minimum;
    }
    else {
      left_wheel_tick_count++;  
    }  
  }
  else {
    if (left_wheel_tick_count == encoder_minimum) {
      left_wheel_tick_count = encoder_maximum;
    }
    else {
      left_wheel_tick_count--;  
    }   
  }
}
