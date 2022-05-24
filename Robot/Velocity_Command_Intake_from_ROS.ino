#include <ArduinoHardware.h> //THIS SHOULD BE THE FINAL CODE. Acha abb dekhna ke how to program a publisher which publishes
//a geometry on the topic and this node can subscribe to that node and apply the differential controller code from github.
#include <AFMotor.h>
#include <ros.h>
#include <geometry_msgs/Twist.h>

ros::NodeHandle nh;
geometry_msgs::Twist msg;

#define PWM_MIN 300

AF_DCMotor motorLB(1);
AF_DCMotor motorRB(2);
AF_DCMotor motorRF(3);
AF_DCMotor motorLF(4);
// 1 - LB || 2 - RB || 3 - RF || 4 - LF 


float move1;
float move2;

void roverCallBack(const geometry_msgs::Twist& cmd_vel)
{
  move1 = cmd_vel.linear.x * 127 ;
  move2 = cmd_vel.angular.z * 127 ;
}

ros::Subscriber <geometry_msgs::Twist> sub("/cmd_vel", roverCallBack);

void setup()
{
  nh.initNode();
  nh.subscribe(sub);
  Serial.begin(115200);
  while(!Serial){;} 
  motorLB.run(RELEASE);
  motorRB.run(RELEASE); 
  motorRF.run(RELEASE); 
  motorLF.run(RELEASE);
} 

void loop()
{
  nh.spinOnce();
  delay(1);
}
