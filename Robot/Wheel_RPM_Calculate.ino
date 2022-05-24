/*
   Author: Automatic Addison
   Website: https://automaticaddison.com
   Description: Calculate the angular velocity in radians/second of a DC motor
   with a built-in encoder (forward = positive; reverse = negative)
*/

// Motor encoder output pulses per 360 degree revolution (measured manually)
#define ENC_COUNT_REV 1120

// Encoder output to Arduino Interrupt pin. Tracks the pulse count.
#define ENC_IN_RIGHT_A 18

// Other encoder output to Arduino to keep track of wheel direction
// Tracks the direction of rotation.
#define ENC_IN_RIGHT_B 53


// Encoder output to Arduino Interrupt pin. Tracks the pulse count.
#define ENC_IN_LEFT_A 19

// Other encoder output to Arduino to keep track of wheel direction
// Tracks the direction of rotation.
#define ENC_IN_LEFT_B 52
// True = Forward; False = Reverse
boolean Direction_right = true;
boolean Direction_left = true;
// Keep track of the number of right wheel pulses
volatile long right_wheel_pulse_count = 0;
volatile long left_wheel_pulse_count = 0;
// One-second interval for measurements
int interval = 1000;
int pwmA = 9;
int pwmB = 10;
int enA1 = 50;
int enA2 = 51;
int enB1 = 49;
int enB2 = 48;
// Counters for milliseconds during interval
long previousMillis = 0;
long currentMillis = 0;

// Variable for RPM measuerment
float rpm_right = 0;
float rpm_left = 0;
// Variable for angular velocity measurement
float ang_velocity_right = 0;
float ang_velocity_right_deg = 0;

float ang_velocity_left = 0;
float ang_velocity_left_deg = 0;

const float rpm_to_radians = 0.2923989365;
const float rad_to_deg = 16.753225;

void setup() {

  // Open the serial port at 9600 bps
  Serial.begin(9600);
  pinMode(pwmA, OUTPUT);
  pinMode(pwmB, OUTPUT);
  pinMode(enA1, OUTPUT);
  pinMode(enA2, OUTPUT);
  pinMode(enB1, OUTPUT);
  pinMode(enB2, OUTPUT);
  // Set pin states of the encoder
  pinMode(ENC_IN_RIGHT_A , INPUT_PULLUP);
  pinMode(ENC_IN_RIGHT_B , INPUT);
  pinMode(ENC_IN_LEFT_A , INPUT_PULLUP);
  pinMode(ENC_IN_LEFT_B , INPUT);
  // Every time the pin goes high, this is a pulse
  attachInterrupt(digitalPinToInterrupt(ENC_IN_RIGHT_A), right_wheel_pulse, RISING);
  attachInterrupt(digitalPinToInterrupt(ENC_IN_LEFT_A), left_wheel_pulse, RISING);
  digitalWrite(enA1, HIGH);
  digitalWrite(enA2, LOW);
  digitalWrite(enB1, LOW);
  digitalWrite(enB2, HIGH);
}

void loop() {
  analogWrite(pwmA, 250);
  analogWrite(pwmB, 250);
  // Record the time
  currentMillis = millis();

  // If one second has passed, print the number of pulses
  if (currentMillis - previousMillis > interval) {

    previousMillis = currentMillis;

    // Calculate revolutions per minute
    rpm_right = (float)(right_wheel_pulse_count * 60 / ENC_COUNT_REV);
    ang_velocity_right = rpm_right * rpm_to_radians;
    ang_velocity_right_deg = ang_velocity_right * rad_to_deg;

    //Serial.print(" Right Pulses: ");
    //Serial.println(right_wheel_pulse_count);
    
//    Serial.println(" RPM");
//    Serial.print(" Angular Velocity: ");
//    Serial.print(rpm_right);
//    Serial.print(" rad per second");
//    Serial.print("\t");
//    Serial.print(ang_velocity_right_deg);
//    Serial.println(" deg per second");
    Serial.println();

    rpm_left = (float)(left_wheel_pulse_count * 60 / ENC_COUNT_REV);
    ang_velocity_left = rpm_left * rpm_to_radians;
    ang_velocity_left_deg = ang_velocity_left * rad_to_deg;

    //Serial.print(" Left Pulses: ");
    //Serial.println(left_wheel_pulse_count);
    //Serial.print(" Right Speed: ");
    Serial.print(rpm_right);
    //Serial.println();
    //Serial.print(" Left Speed: ");
    Serial.print(rpm_left);
//    Serial.print(" Angular Velocity: ");
//    Serial.print(rpm_right);
//    Serial.print(" rad per second");
//    Serial.print("\t");
//    Serial.print(ang_velocity_right_deg);
//    Serial.println(" deg per second");
    //Serial.println();

    

    right_wheel_pulse_count = 0;
    left_wheel_pulse_count = 0;
    

  }
}

// Increment the number of pulses by 1
void right_wheel_pulse() {

  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_IN_RIGHT_B);

  if (val == LOW) {
    Direction_right = false; // Reverse
  }
  else {
    Direction_right = true; // Forward
  }

  if (Direction_right) {
    right_wheel_pulse_count++;
  }
  else {
    right_wheel_pulse_count--;
  }
}


void left_wheel_pulse() {

  // Read the value for the encoder for the right wheel
  int val = digitalRead(ENC_IN_LEFT_B);

  if (val == LOW) {
    Direction_left = false; // Reverse
  }
  else {
    Direction_left = true; // Forward
  }

  if (Direction_right) {
    left_wheel_pulse_count++;
  }
  else {
    left_wheel_pulse_count--;
  }
}
