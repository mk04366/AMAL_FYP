#!/usr/bin/env python


import rospy
import roslib
roslib.load_manifest('differential_drive')
from math import sin, cos, pi
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from nav_msgs.msg import Odometry
from tf.broadcaster import TransformBroadcaster
from std_msgs.msg import Int16
from geometry_msgs.msg import PoseStamped

cred = credentials.Certificate("/home/amal/catkin_ws/src/differential_drive/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

class goals:


    def __init__(self):

        rospy.init_node("goals")
        self.nodename = rospy.get_name()
        rospy.loginfo("-I- %s started" % self.nodename)
        #### parameters #######
        self.rate = rospy.get_param('~rate',10.0)  # the rate at which to publish the transform
    
        self.directory = {'Charging Base':[0,0,0], 'Cafeteria Counter':[2.35834,-6.18966,0.0], 'Table 1':[-1.74200,-0.995179,0],'Table 1':[-3.00177,4.98015,0]}

        

        self.then = rospy.Time.now()
        

        self.GoalPub = rospy.Publisher("move_base_simple/goal", PoseStamped, queue_size=10)
	


    def update(self):
   
	now = rospy.Time.now() #Gets the current time
	#print(now)
	doc = db.collection('orders').document('test').get().to_dict()
	#print(doc)
	flag = doc['flag']

	if flag == True:
		current_goal = PoseStamped()
		location = 'Table 1'
		#print(flag, location)	
		current_goal.header.frame_id = "map"
		current_goal.header.stamp.secs = now.secs
		current_goal.header.stamp.nsecs = now.nsecs
		current_goal.pose.orientation.x = 0 
		current_goal.pose.orientation.y = 0 
		current_goal.pose.orientation.z = 1
		current_goal.pose.orientation.w = 0  
		current_goal.pose.position.x = self.directory[location][0]
		current_goal.pose.position.y = self.directory[location][1]
		current_goal.pose.position.z = self.directory[location][2]
		self.GoalPub.publish(current_goal)
	elif flag == False:
		current_goal = PoseStamped()
		location = 'Cafeteria Counter'
		#print(flag, location)	
		current_goal.header.frame_id = "map"
		current_goal.header.stamp.secs = now.secs
		current_goal.header.stamp.nsecs = now.nsecs
		current_goal.pose.orientation.x = 0 
		current_goal.pose.orientation.y = 0 
		current_goal.pose.orientation.z = 1
		current_goal.pose.orientation.w = 0  
		current_goal.pose.position.x = self.directory[location][0]
		current_goal.pose.position.y = self.directory[location][1]
		current_goal.pose.position.z = self.directory[location][2]
		self.GoalPub.publish(current_goal)


    def spin(self):

        r = rospy.Rate(self.rate)
        while not rospy.is_shutdown():
            self.update()
            r.sleep()

if __name__ == '__main__':
    """ main """
    try:
        Goal = goals()
        Goal.spin()
    except rospy.ROSInterruptException:
        pass









