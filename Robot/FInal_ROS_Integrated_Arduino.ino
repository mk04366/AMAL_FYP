#include <ros.h>
# include <std_msgs/Int16.h>
# include <geometry_msgs/Twist.h>
# include <std_msgs/Float32.h>
// Handles startup and shutdown of ROS
ros::NodeHandle nh;
//Encoder pins Front Wheels
#define ENC_A_FR 3
#define ENC_B_FR 47

#define ENC_A_FL 2
#define ENC_B_FL 46

//Encoder pins Back Wheels
#define ENC_A_BR 18
#define ENC_B_BR 53

#define ENC_A_BL 19
#define ENC_B_BL 52

float lmotorfront,rmotorfront,lmotorback,rmotorback;
// True = Forward; False = Reverse
boolean Direction_left = true;
boolean Direction_right = true;
// 16bit integer
const int encoder_minimum = -32768;
const int encoder_maximum = 32767;

//Front Tyres ROS nodes publisher
std_msgs::Int16 RWT_front;
ros::Publisher rwheelfront("rwheelfront", &RWT_front);

std_msgs::Int16 LWT_front;
ros::Publisher lwheelfront("lwheelfront", &LWT_front);

//Back Tyres ROS nodes publisher
std_msgs::Int16 RWT_back;
ros::Publisher rwheelback("rwheelback", &RWT_back);

std_msgs::Int16 LWT_back;
ros::Publisher lwheelback("lwheelback", &LWT_back);

// Time interval
const int interval = 30;
long previousMillis = 0;
long currentMillis = 0;

// Motor Front Left
const int enA_FL = 11; 
const int in1_FL = 44;
const int in2_FL = 45;

// Motor Front Right
const int enB_FR = 12;
const int in3_FR = 43;
const int in4_FR = 42;

// Motor Back Left
const int enA_BL = 9; 
const int in1_BL = 50;
const int in2_BL = 51;

// Motor FBack Right
const int enB_BR = 10;
const int in3_BR = 48;
const int in4_BR = 49;
  
// Number of ticks per wheel revolution.
const int TICKS_PER_REVOLUTION = 1120;
 
// Wheel radius in meters
const double WHEEL_RADIUS = 0.05969;
 
// Distance from center of the left tire to the center of the right tire in m
const double WHEEL_BASE = 0.3048;
 
const double TICKS_PER_METER = 2932;


double pwmLeft_front = 0;
double pwmRight_front = 0;

double pwmLeft_back = 0;
double pwmRight_back = 0;

double lastCmdVelReceived = 0;




void right_front_wheel_tick() {
   
  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_B_FR);
 
  if (val == LOW) {
    Direction_right = false; // Reverse
  }
  else {
    Direction_right = true; // Forward
  }
   
  if (Direction_right) {
     
    if (RWT_front.data == encoder_maximum) {
      RWT_front.data = encoder_minimum;
    }
    else {
      RWT_front.data++;  
    }    
  }
  else {
    if (RWT_front.data == encoder_minimum) {
      RWT_front.data = encoder_maximum;
    }
    else {
      RWT_front.data--;  
    }   
  }
}


void left_front_wheel_tick() {
   
  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_B_FL);
 
  if (val == LOW) {
    Direction_left = false; // Reverse
  }
  else {
    Direction_left = true; // Forward
  }
   
  if (Direction_left) {
     
    if (LWT_front.data == encoder_maximum) {
      LWT_front.data = encoder_minimum;
    }
    else {
      LWT_front.data++;  
    }    
  }
  else {
    if (LWT_front.data == encoder_minimum) {
      LWT_front.data = encoder_maximum;
    }
    else {
      LWT_front.data--;  
    }   
  }
}




void right_back_wheel_tick() {
   
  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_B_BR);
 
  if (val == LOW) {
    Direction_right = false; // Reverse
  }
  else {
    Direction_right = true; // Forward
  }
   
  if (Direction_right) {
     
    if (RWT_back.data == encoder_maximum) {
      RWT_back.data = encoder_minimum;
    }
    else {
      RWT_back.data++;  
    }    
  }
  else {
    if (RWT_back.data == encoder_minimum) {
      RWT_back.data = encoder_maximum;
    }
    else {
      RWT_back.data--;  
    }   
  }
}


void left_back_wheel_tick() {
   
  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_B_BL);
 
  if (val == LOW) {
    Direction_left = false; // Reverse
  }
  else {
    Direction_left = true; // Forward
  }
   
  if (Direction_left) {
     
    if (LWT_back.data == encoder_maximum) {
      LWT_back.data = encoder_minimum;
    }
    else {
      LWT_back.data++;  
    }    
  }
  else {
    if (LWT_back.data == encoder_minimum) {
      LWT_back.data = encoder_maximum;
    }
    else {
      LWT_back.data--;  
    }   
  }
}



void pwmrmf(const std_msgs::Float32& msg)
{
  rmotorfront = msg.data;
  }
void pwmlmf(const std_msgs::Float32& msg)
{
  lmotorfront = msg.data;
  }
void pwmrmb(const std_msgs::Float32& msg)
{
  rmotorback = msg.data;
  }
void pwmlmb(const std_msgs::Float32& msg)
{
  lmotorback = msg.data;
  }


//Instantiating subscriber nodes which takes data from differential_drive package
ros::Subscriber<std_msgs::Float32> rmotor_F("rmotorfront",&pwmrmf);
ros::Subscriber<std_msgs::Float32> lmotor_F("lmotorfront",&pwmlmf);
ros::Subscriber<std_msgs::Float32> rmotor_B("rmotorback",&pwmrmb);
ros::Subscriber<std_msgs::Float32> lmotor_B("lmotorback",&pwmlmb);

void setup() {
 
  // Set pin states of the encoder Forward
  pinMode(ENC_A_FR, INPUT_PULLUP);
  pinMode(ENC_B_FR, INPUT);
  pinMode(ENC_A_FL, INPUT_PULLUP);
  pinMode(ENC_B_FL, INPUT);

  // Set pin states of the encoder Back
  pinMode(ENC_A_BR, INPUT_PULLUP);
  pinMode(ENC_B_BR, INPUT);
  pinMode(ENC_A_BL, INPUT_PULLUP);
  pinMode(ENC_B_BL, INPUT);
  

  // Every time the pin goes high, this is a tick
  attachInterrupt(digitalPinToInterrupt(ENC_A_FR), left_front_wheel_tick, RISING);
  attachInterrupt(digitalPinToInterrupt(ENC_A_FL), right_front_wheel_tick, RISING);
  
  attachInterrupt(digitalPinToInterrupt(ENC_A_BR), left_back_wheel_tick, RISING);
  attachInterrupt(digitalPinToInterrupt(ENC_A_BL), right_back_wheel_tick, RISING);
   
  // Motor control pins Front
  pinMode(enA_FL, OUTPUT);
  pinMode(enB_FR, OUTPUT);
  pinMode(in1_FL, OUTPUT);
  pinMode(in2_FL, OUTPUT);
  pinMode(in3_FR, OUTPUT);
  pinMode(in4_FR, OUTPUT);

  // Motor control pins Back
  pinMode(enA_BL, OUTPUT);
  pinMode(enB_BR, OUTPUT);
  pinMode(in1_BL, OUTPUT);
  pinMode(in2_BL, OUTPUT);
  pinMode(in3_BR, OUTPUT);
  pinMode(in4_BR, OUTPUT);
  
  
  // Turn off motors - Initial state
  digitalWrite(in1_FL, LOW);
  digitalWrite(in2_FL, LOW);
  digitalWrite(in3_FR, LOW);
  digitalWrite(in4_FR, LOW);

  digitalWrite(in1_BL, LOW);
  digitalWrite(in2_BL, LOW);
  digitalWrite(in3_BR, LOW);
  digitalWrite(in4_BR, LOW);

  // Set the motor speed
  analogWrite(enA_FL, 0); 
  analogWrite(enB_FR, 0);
  analogWrite(enA_BL, 0); 
  analogWrite(enB_BR, 0);
  
  // ROS Setup
  nh.getHardware()->setBaud(115200);
  nh.initNode();
  //Publishing encoder values
  nh.advertise(rwheelfront);
  nh.advertise(lwheelfront);
  nh.advertise(rwheelback);
  nh.advertise(lwheelback);
  //subscribing to these topics to get PWM values
  nh.subscribe(rmotor_F);
  nh.subscribe(lmotor_F);
  nh.subscribe(rmotor_B);
  nh.subscribe(lmotor_B);
}


//void timerIsr(){
//  Timer1.detachInterrupt();//stopthetimer
//  right_wheel_enc.data=knobRight.read();
//  left_wheel_enc.data=knobLeft.read();
//  right_wheel_enc_pub.publish(&right_wheel_enc);
//  left_wheel_enc_pub.publish(&left_wheel_enc);
//  Timer1.attachInterrupt(timerIsr);
//  //enablethetimer
//}
void loop() {
  
  nh.spinOnce();

  
  lwheelfront.publish( &LWT_front );
  rwheelfront.publish( &RWT_front );
  lwheelback.publish( &LWT_back );
  rwheelback.publish( &RWT_back );

  
  if(lmotorfront > 0 && rmotorfront > 0)
  {
    digitalWrite(in1_FL,HIGH);
    digitalWrite(in2_FL,LOW);
    digitalWrite(in3_FR,HIGH);
    digitalWrite(in4_FR,LOW);

    digitalWrite(in1_BL,HIGH);
    digitalWrite(in2_BL,LOW);
    digitalWrite(in3_BR,HIGH);
    digitalWrite(in4_BR,LOW);    
  }

  
  else if(lmotorfront < 0 && rmotorfront < 0)
  {
    digitalWrite(in1_FL,LOW);
    digitalWrite(in2_FL,HIGH);
    digitalWrite(in3_FR,LOW);
    digitalWrite(in4_FR,HIGH);

    digitalWrite(in1_BL,LOW);
    digitalWrite(in2_BL,HIGH);
    digitalWrite(in3_BR,LOW);
    digitalWrite(in4_BR,HIGH);
  }


  
  else if(lmotorfront > 0 && rmotorfront < 0)
  {
    digitalWrite(in1_FL,LOW);
    digitalWrite(in2_FL,HIGH);
    digitalWrite(in3_FR,HIGH);
    digitalWrite(in4_FR,LOW);

    digitalWrite(in1_BL,LOW);
    digitalWrite(in2_BL,HIGH);
    digitalWrite(in3_BR,HIGH);
    digitalWrite(in4_BR,LOW);
  }


  
  else if(lmotorfront < 0 && rmotorfront > 0)
  {
    digitalWrite(in1_FL,HIGH);
    digitalWrite(in2_FL,LOW);
    digitalWrite(in3_FR,LOW);
    digitalWrite(in4_FR,HIGH);

    digitalWrite(in1_BL,HIGH);
    digitalWrite(in2_BL,LOW);
    digitalWrite(in3_BR,LOW);
    digitalWrite(in4_BR,HIGH);
  }


  else
  {
    digitalWrite(in1_FL,LOW);
    digitalWrite(in2_FL,LOW);
    digitalWrite(in3_FR,LOW);
    digitalWrite(in4_FR,LOW);

    digitalWrite(in1_BL,LOW);
    digitalWrite(in2_BL,LOW);
    digitalWrite(in3_BR,LOW);
    digitalWrite(in4_BR,LOW);
  }



  
  analogWrite(enA_FL, abs(lmotorfront));
  analogWrite(enB_FR, abs(rmotorfront));
  analogWrite(enA_BL, abs(lmotorback));
  analogWrite(enB_BR, abs(rmotorback));
  Serial.println(LWT_back.data);
  delay(25);
}
