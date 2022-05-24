
#include <ros.h>
#include <std_msgs/Int16.h> 
#include <geometry_msgs/Twist.h>
// Handles startup and shutdown of ROS
ros::NodeHandle nh;
 
// Encoder output to Arduino Interrupt pin. Tracks the tick count.
#define ENC_IN_LEFT_A_BACK 19
#define ENC_IN_RIGHT_A_BACK 18


#define ENC_IN_LEFT_A_FRONT 2
#define ENC_IN_RIGHT_A_FRONT 3
 
// Other encoder output to Arduino to keep track of wheel direction
// Tracks the direction of rotation.
#define ENC_IN_LEFT_B_BACK 53
#define ENC_IN_RIGHT_B_BACK 52

#define ENC_IN_LEFT_B_FRONT 47
#define ENC_IN_RIGHT_B_FRONT 46
 
// True = Forward; False = Reverse
boolean Direction_left = true;
boolean Direction_right = true;
 
// Minumum and maximum values for 16-bit integers
// Range of 65,535
const int encoder_minimum = -32768;
const int encoder_maximum = 32767;
 
// Keep track of the number of wheel ticks
std_msgs::Int16 right_wheel_tick_count_BACK;
ros::Publisher rightPub_BACK("right_ticks_back", &right_wheel_tick_count_BACK);
 
std_msgs::Int16 left_wheel_tick_count_BACK;
ros::Publisher leftPub_BACK("left_ticks_back", &left_wheel_tick_count_BACK);


std_msgs::Int16 right_wheel_tick_count_FRONT;
ros::Publisher rightPub_FRONT("right_ticks_front", &right_wheel_tick_count_FRONT);
 
std_msgs::Int16 left_wheel_tick_count_FRONT;
ros::Publisher leftPub_FRONT("left_ticks_front", &left_wheel_tick_count_FRONT);
 
// Time interval for measurements in milliseconds
const int interval = 30;
long previousMillis = 0;
long currentMillis = 0;
 
////////////////// Motor Controller Variables and Constants ///////////////////
 
// Motor A connections - LEFT
const int enA_BACK = 9;
const int in1_BACK = 50;
const int in2_BACK = 51;
  
// Motor B connections - RIGHT
const int enB_BACK = 10; 
const int in3_BACK = 48;
const int in4_BACK = 49;


// Motor A connections - LEFT
const int enA_FRONT = 11;
const int in1_FRONT = 44;
const int in2_FRONT = 45;
  
// Motor B connections - RIGHT
const int enB_FRONT = 12; 
const int in3_FRONT = 43;
const int in4_FRONT = 42;
 
// How much the PWM value can change each cycle
const int PWM_INCREMENT = 1;
 
// Number of ticks per wheel revolution. We won't use this in this code.
const int TICKS_PER_REVOLUTION = 1120;
 
// Wheel radius in meters
const double WHEEL_RADIUS = 0.05969;
 
// Distance from center of the left tire to the center of the right tire in m
const double WHEEL_BASE = 0.3048;
 
// Number of ticks a wheel makes moving a linear distance of 1 meter
// This value was measured manually.
const double TICKS_PER_METER = 2932; // Originally 2880
 
// Proportional constant, which was measured by measuring the 
// PWM-Linear Velocity relationship for the robot.
const int K_P = 10;
const int K_I = 15;
 
// Y-intercept for the PWM-Linear Velocity relationship for the robot
const int b = 52;
 
// Correction multiplier for drift. Chosen through experimentation.
const int DRIFT_MULTIPLIER = 120;
 
// Turning PWM output (0 = min, 255 = max for PWM values)
const int PWM_TURN = 150;
 
// Set maximum and minimum limits for the PWM values
const int PWM_MIN = 80; // about 0.1 m/s
const int PWM_MAX = 250; // about 0.172 m/s
 
// Set linear velocity and PWM variable values for each wheel
double velLeftWheel_BACK = 0;
double velRightWheel_BACK = 0;
double pwmLeftReq_BACK = 0;
double pwmRightReq_BACK = 0;

double velLeftWheel_FRONT = 0;
double velRightWheel_FRONT = 0;
double pwmLeftReq_FRONT = 0;
double pwmRightReq_FRONT = 0;
 
// Record the time that the last velocity command was received
double lastCmdVelReceived = 0;
 
/////////////////////// Tick Data Publishing Functions ////////////////////////
 
// Increment the number of ticks
void right_wheel_tick_back() {
   
  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_IN_RIGHT_B_BACK);
 
  if (val == LOW) {
    Direction_right = false; // Reverse
  }
  else {
    Direction_right = true; // Forward
  }
   
  if (Direction_right) {
     
    if (right_wheel_tick_count_BACK.data == encoder_maximum) {
      right_wheel_tick_count_BACK.data = encoder_minimum;
    }
    else {
      right_wheel_tick_count_BACK.data++;  
    }    
  }
  else {
    if (right_wheel_tick_count_BACK.data == encoder_minimum) {
      right_wheel_tick_count_BACK.data = encoder_maximum;
    }
    else {
      right_wheel_tick_count_BACK.data--;  
    }   
  }
}



 
// Increment the number of ticks
void left_wheel_tick_back() {
   
  // Read the value for the encoder for the left wheel
  int val = digitalRead(ENC_IN_LEFT_B_BACK);
 
  if (val == LOW) {
    Direction_left = true; // Reverse
  }
  else {
    Direction_left = false; // Forward
  }
   
  if (Direction_left) {
    if (left_wheel_tick_count_BACK.data == encoder_maximum) {
      left_wheel_tick_count_BACK.data = encoder_minimum;
    }
    else {
      left_wheel_tick_count_BACK.data++;  
    }  
  }
  else {
    if (left_wheel_tick_count_BACK.data == encoder_minimum) {
      left_wheel_tick_count_BACK.data = encoder_maximum;
    }
    else {
      left_wheel_tick_count_BACK.data--;  
    }   
  }
}




void right_wheel_tick_FRONT() {
   
  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_IN_RIGHT_B_FRONT);
 
  if (val == LOW) {
    Direction_right = false; // Reverse
  }
  else {
    Direction_right = true; // Forward
  }
   
  if (Direction_right) {
     
    if (right_wheel_tick_count_FRONT.data == encoder_maximum) {
      right_wheel_tick_count_FRONT.data = encoder_minimum;
    }
    else {
      right_wheel_tick_count_FRONT.data++;  
    }    
  }
  else {
    if (right_wheel_tick_count_FRONT.data == encoder_minimum) {
      right_wheel_tick_count_FRONT.data = encoder_maximum;
    }
    else {
      right_wheel_tick_count_FRONT.data--;  
    }   
  }
}



 
// Increment the number of ticks
void left_wheel_tick_FRONT() {
   
  // Read the value for the encoder for the left wheel
  int val = digitalRead(ENC_IN_LEFT_B_FRONT);
 
  if (val == LOW) {
    Direction_left = true; // Reverse
  }
  else {
    Direction_left = false; // Forward
  }
   
  if (Direction_left) {
    if (left_wheel_tick_count_FRONT.data == encoder_maximum) {
      left_wheel_tick_count_FRONT.data = encoder_minimum;
    }
    else {
      left_wheel_tick_count_FRONT.data++;  
    }  
  }
  else {
    if (left_wheel_tick_count_FRONT.data == encoder_minimum) {
      left_wheel_tick_count_FRONT.data = encoder_maximum;
    }
    else {
      left_wheel_tick_count_FRONT.data--;  
    }   
  }
}








 
/////////////////////// Motor Controller Functions ////////////////////////////
 
// Calculate the left wheel linear velocity in m/s every time a 
// tick count message is rpublished on the /left_ticks topic. 
void calc_vel_left_wheel_BACK(){
   
  // Previous timestamp
  static double prevTime = 0;
   
  // Variable gets created and initialized the first time a function is called.
  static int prevLeftCount_BACK = 0;
 
  // Manage rollover and rollunder when we get outside the 16-bit integer range 
  int numOfTicks = (65535 + left_wheel_tick_count_BACK.data - prevLeftCount_BACK) % 65535;
 
  // If we have had a big jump, it means the tick count has rolled over.
  if (numOfTicks > 10000) {
        numOfTicks = 0 - (65535 - numOfTicks);
  }
 
  // Calculate wheel velocity in meters per second
  velLeftWheel_BACK = numOfTicks/TICKS_PER_METER/((millis()/1000)-prevTime);
 
  // Keep track of the previous tick count
  prevLeftCount_BACK = left_wheel_tick_count_BACK.data;
 
  // Update the timestamp
  prevTime = (millis()/1000);
 
}
 
// Calculate the right wheel linear velocity in m/s every time a 
// tick count message is published on the /right_ticks topic. 
void calc_vel_right_wheel_BACK(){
   
  // Previous timestamp
  static double prevTime = 0;
   
  // Variable gets created and initialized the first time a function is called.
  static int prevRightCount_BACK = 0;
 
  // Manage rollover and rollunder when we get outside the 16-bit integer range 
  int numOfTicks = (65535 + right_wheel_tick_count_BACK.data - prevRightCount_BACK) % 65535;
 
  if (numOfTicks > 10000) {
        numOfTicks = 0 - (65535 - numOfTicks);
  }
 
  // Calculate wheel velocity in meters per second
  velRightWheel_BACK = numOfTicks/TICKS_PER_METER/((millis()/1000)-prevTime);
 
  prevRightCount_BACK = right_wheel_tick_count_BACK.data;
   
  prevTime = (millis()/1000);
 
}


//FRONT WHEELS
void calc_vel_left_wheel_FRONT(){
   
  // Previous timestamp
  static double prevTime = 0;
   
  // Variable gets created and initialized the first time a function is called.
  static int prevLeftCount_FRONT = 0;
 
  // Manage rollover and rollunder when we get outside the 16-bit integer range 
  int numOfTicks = (65535 + left_wheel_tick_count_FRONT.data - prevLeftCount_FRONT) % 65535;
 
  // If we have had a big jump, it means the tick count has rolled over.
  if (numOfTicks > 10000) {
        numOfTicks = 0 - (65535 - numOfTicks);
  }
 
  // Calculate wheel velocity in meters per second
  velLeftWheel_FRONT = numOfTicks/TICKS_PER_METER/((millis()/1000)-prevTime);
 
  // Keep track of the previous tick count
  prevLeftCount_FRONT = left_wheel_tick_count_FRONT.data;
 
  // Update the timestamp
  prevTime = (millis()/1000);
 
}
 
// Calculate the right wheel linear velocity in m/s every time a 
// tick count message is published on the /right_ticks topic. 
void calc_vel_right_wheel_FRONT(){
   
  // Previous timestamp
  static double prevTime = 0;
   
  // Variable gets created and initialized the first time a function is called.
  static int prevRightCount_FRONT = 0;
 
  // Manage rollover and rollunder when we get outside the 16-bit integer range 
  int numOfTicks = (65535 + right_wheel_tick_count_FRONT.data - prevRightCount_FRONT) % 65535;
 
  if (numOfTicks > 10000) {
        numOfTicks = 0 - (65535 - numOfTicks);
  }
 
  // Calculate wheel velocity in meters per second
  velRightWheel_FRONT = numOfTicks/TICKS_PER_METER/((millis()/1000)-prevTime);
 
  prevRightCount_FRONT = right_wheel_tick_count_FRONT.data;
   
  prevTime = (millis()/1000);
 
}










 
// Take the velocity command as input and calculate the PWM values.
void calc_pwm_values(const geometry_msgs::Twist& cmdVel) {
   
  // Record timestamp of last velocity command received
  lastCmdVelReceived = (millis()/1000);
  long currT = micros();
  float deltaT = ((float) (currT - prevT))/( 1.0e6 );
  prevT = currT;
//  int error_left_back = cmdVel.linear.x - ACTUAL_VEL_LEFT_BACK;
//  int error_right_back = cmdVel.linear.x - ACTUAL_VEL_RIGHT_BACK; 
//  int error_left_front = cmdVel.linear.x - ACTUAL_VEL_LEFT_FRONT; 
//  int error_right_front = cmdVel.linear.x - ACTUAL_VEL_RIGHT_FRONT;
  int error_left_back = cmdVel.linear.x;
  int error_right_back = cmdVel.linear.x; 
  int error_left_front = cmdVel.linear.x; 
  int error_right_front = cmdVel.linear.x; 
  // Calculate the PWM value given the desired velocity 
  pwmLeftReq_BACK = K_P * cmdVel.linear.x + b;
  pwmLeftReq_FRONT = pwmLeftReq_BACK;
  pwmRightReq_FRONT = K_P * cmdVel.linear.x + b;
  pwmRightReq_BACK = pwmRightReq_FRONT;
 
  // Check if we need to turn 
  if (cmdVel.angular.z != 0.0) {
 
    // Turn left
    if (cmdVel.angular.z > 0.0) {
      pwmLeftReq = -PWM_TURN;
      pwmRightReq = PWM_TURN;
    }
    // Turn right    
    else {
      pwmLeftReq = PWM_TURN;
      pwmRightReq = -PWM_TURN;
    }
  }
  // Go straight
  else {
     
    // Remove any differences in wheel velocities 
    // to make sure the robot goes straight
    static double prevDiff = 0;
    static double prevPrevDiff = 0;
    double currDifference = velLeftWheel - velRightWheel; 
    double avgDifference = (prevDiff+prevPrevDiff+currDifference)/3;
    prevPrevDiff = prevDiff;
    prevDiff = currDifference;
 
    // Correct PWM values of both wheels to make the vehicle go straight
    pwmLeftReq -= (int)(avgDifference * DRIFT_MULTIPLIER);
    pwmRightReq += (int)(avgDifference * DRIFT_MULTIPLIER);
  }
 
  // Handle low PWM values
  if (abs(pwmLeftReq) < PWM_MIN) {
    pwmLeftReq = 0;
  }
  if (abs(pwmRightReq) < PWM_MIN) {
    pwmRightReq = 0;  
  }  
}
 
void set_pwm_values() {
 
  // These variables will hold our desired PWM values
  static int pwmLeftOut = 0;
  static int pwmRightOut = 0;
 
  // If the required PWM is of opposite sign as the output PWM, we want to
  // stop the car before switching direction
  static bool stopped = false;
  if ((pwmLeftReq * velLeftWheel < 0 && pwmLeftOut != 0) ||
      (pwmRightReq * velRightWheel < 0 && pwmRightOut != 0)) {
    pwmLeftReq = 0;
    pwmRightReq = 0;
  }
 
  // Set the direction of the motors
  if (pwmLeftReq > 0) { // Left wheel forward
    digitalWrite(in1, HIGH);
    digitalWrite(in2, LOW);
  }
  else if (pwmLeftReq < 0) { // Left wheel reverse
    digitalWrite(in1, LOW);
    digitalWrite(in2, HIGH);
  }
  else if (pwmLeftReq == 0 && pwmLeftOut == 0 ) { // Left wheel stop
    digitalWrite(in1, LOW);
    digitalWrite(in2, LOW);
  }
  else { // Left wheel stop
    digitalWrite(in1, LOW);
    digitalWrite(in2, LOW); 
  }
 
  if (pwmRightReq > 0) { // Right wheel forward
    digitalWrite(in3, HIGH);
    digitalWrite(in4, LOW);
  }
  else if(pwmRightReq < 0) { // Right wheel reverse
    digitalWrite(in3, LOW);
    digitalWrite(in4, HIGH);
  }
  else if (pwmRightReq == 0 && pwmRightOut == 0) { // Right wheel stop
    digitalWrite(in3, LOW);
    digitalWrite(in4, LOW);
  }
  else { // Right wheel stop
    digitalWrite(in3, LOW);
    digitalWrite(in4, LOW); 
  }
 
  // Increase the required PWM if the robot is not moving
  if (pwmLeftReq != 0 && velLeftWheel == 0) {
    pwmLeftReq *= 1.5;
  }
  if (pwmRightReq != 0 && velRightWheel == 0) {
    pwmRightReq *= 1.5;
  }
 
  // Calculate the output PWM value by making slow changes to the current value
  if (abs(pwmLeftReq) > pwmLeftOut) {
    pwmLeftOut += PWM_INCREMENT;
  }
  else if (abs(pwmLeftReq) < pwmLeftOut) {
    pwmLeftOut -= PWM_INCREMENT;
  }
  else{}
   
  if (abs(pwmRightReq) > pwmRightOut) {
    pwmRightOut += PWM_INCREMENT;
  }
  else if(abs(pwmRightReq) < pwmRightOut) {
    pwmRightOut -= PWM_INCREMENT;
  }
  else{}
 
  // Conditional operator to limit PWM output at the maximum 
  pwmLeftOut = (pwmLeftOut > PWM_MAX) ? PWM_MAX : pwmLeftOut;
  pwmRightOut = (pwmRightOut > PWM_MAX) ? PWM_MAX : pwmRightOut;
 
  // PWM output cannot be less than 0
  pwmLeftOut = (pwmLeftOut < 0) ? 0 : pwmLeftOut;
  pwmRightOut = (pwmRightOut < 0) ? 0 : pwmRightOut;
 
  // Set the PWM value on the pins
  analogWrite(enA, pwmLeftOut); 
  analogWrite(enB, pwmRightOut); 
}
 
// Set up ROS subscriber to the velocity command
ros::Subscriber<geometry_msgs::Twist> subCmdVel("cmd_vel", &calc_pwm_values );
 
void setup() {
 
  // Set pin states of the encoder
  pinMode(ENC_IN_LEFT_A , INPUT_PULLUP);
  pinMode(ENC_IN_LEFT_B , INPUT);
  pinMode(ENC_IN_RIGHT_A , INPUT_PULLUP);
  pinMode(ENC_IN_RIGHT_B , INPUT);
 
  // Every time the pin goes high, this is a tick
  attachInterrupt(digitalPinToInterrupt(ENC_IN_LEFT_A), left_wheel_tick, RISING);
  attachInterrupt(digitalPinToInterrupt(ENC_IN_RIGHT_A), right_wheel_tick, RISING);
   
  // Motor control pins are outputs
  pinMode(enA, OUTPUT);
  pinMode(enB, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);
  
  // Turn off motors - Initial state
  digitalWrite(in1, LOW);
  digitalWrite(in2, LOW);
  digitalWrite(in3, LOW);
  digitalWrite(in4, LOW);
  
  // Set the motor speed
  analogWrite(enA, 0); 
  analogWrite(enB, 0);
 
  // ROS Setup
  nh.getHardware()->setBaud(115200);
  nh.initNode();
  nh.advertise(rightPub);
  nh.advertise(leftPub);
  nh.subscribe(subCmdVel);
}
 
void loop() {
   
  nh.spinOnce();
   
  // Record the time
  currentMillis = millis();
 
  // If the time interval has passed, publish the number of ticks,
  // and calculate the velocities.
  if (currentMillis - previousMillis > interval) {
     
    previousMillis = currentMillis;
 
    // Publish tick counts to topics
    leftPub.publish( &left_wheel_tick_count );
    rightPub.publish( &right_wheel_tick_count );
 
    // Calculate the velocity of the right and left wheels
    calc_vel_right_wheel();
    calc_vel_left_wheel();
     
  }
   
  // Stop the car if there are no cmd_vel messages
  if((millis()/1000) - lastCmdVelReceived > 1) {
    pwmLeftReq = 0;
    pwmRightReq = 0;
  }
 
  set_pwm_values();
}
