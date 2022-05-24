#!/usr/bin/env python
import rospy
import roslib
import time
roslib.load_manifest('differential_drive')
from math import sin, cos, pi
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from geometry_msgs.msg import Quaternion
from geometry_msgs.msg import Twist
from nav_msgs.msg import Odometry
from std_msgs.msg import Bool
from tf.broadcaster import TransformBroadcaster
from std_msgs.msg import Int16

cred = credentials.Certificate("/home/amal/catkin_ws/src/differential_drive/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()



class DiffTf:
 

    def __init__(self):

        rospy.init_node("diff_tf")
        self.nodename = rospy.get_name()
        rospy.loginfo("-I- %s started" % self.nodename)
        self.flag = False
        self.rate = rospy.get_param('~rate',10.0)  
        self.ticks_meter = float(rospy.get_param('ticks_meter', 50))  
        self.base_width = float(rospy.get_param('~base_width', 0.245))
        
        self.base_frame_id = rospy.get_param('~base_frame_id','base_link') 
        self.odom_frame_id = rospy.get_param('~odom_frame_id', 'odom') 
        
        self.encoder_min = rospy.get_param('encoder_min', -32768)
	#cred = credentials.Certificate("serviceAccountKey.json")
	#firebase_admin.initialize_app(cred)

	#db = firestore.client()ram('encoder_min', -32768)
        self.encoder_max = rospy.get_param('encoder_max', 32768)
        self.encoder_low_wrap = rospy.get_param('wheel_low_wrap', (self.encoder_max - self.encoder_min) * 0.3 + self.encoder_min )
        self.encoder_high_wrap = rospy.get_param('wheel_high_wrap', (self.encoder_max - self.encoder_min) * 0.7 + self.encoder_min )
 
        self.t_delta = rospy.Duration(1.0/self.rate)
        self.t_next = rospy.Time.now() + self.t_delta
        
        # internal data
        self.enc_bleft = None        # wheel encoder readings
        self.enc_bright = None
	self.enc_fleft = None        # wheel encoder readings
        self.enc_fright = None
        
	self.bleft = 0               # actual values coming back from robot
        self.bright = 0
	self.fleft = 0               
        self.fright = 0

        self.blmult = 0
        self.brmult = 0
	self.flmult = 0
        self.frmult = 0

	self.covar = Odometry()

        self.prev_blencoder = 0
        self.prev_brencoder = 0
	self.prev_flencoder = 0
        self.prev_frencoder = 0

        self.x = 0                  # position in xy plane 
        self.y = 0

        self.th = 0
        self.dx = 0                 # speeds in x/rotation
        self.dr = 0

        self.then = rospy.Time.now()
        
        # subscriptions
        rospy.Subscriber("lwheelback", Int16, self.BLwheelCallback)
        rospy.Subscriber("rwheelback", Int16, self.BRwheelCallback)
	rospy.Subscriber("lwheelfront", Int16, self.FLwheelCallback)
        rospy.Subscriber("rwheelfront", Int16, self.FRwheelCallback)
	rospy.Subscriber("odom", Odometry, self.recall_cov)
        self.odomPub = rospy.Publisher("odom", Odometry, queue_size=10)
	self.flagger = rospy.Publisher("flag_firebase",Bool , queue_size=10)
        self.odomBroadcaster = TransformBroadcaster()
        

    def spin(self):
        r = rospy.Rate(self.rate)
        while not rospy.is_shutdown():
            self.update()
	    #self.create_con()
            r.sleep()
       
     

    def update(self):

        now = rospy.Time.now()
	#print(self.flag)
	if self.flag == True:
		#print('Changing State to False')
		self.flag = False
	if self.flag == False:	
		self.create_con()
	#if flag:
	 #   self.create_con()
	  #  flag = False

        if now > self.t_next:
            elapsed = now - self.then
            self.then = now
            elapsed = elapsed.to_sec()
            
            # calculate odometry
            if self.enc_bleft == None:
                d_left = 0
                d_right = 0
            else:
		left_dis = (self.bleft + self.fleft)/2
		right_dis = (self.bright + self.fright)/2
		left_E = (self.enc_bleft + self.enc_fleft)/2
		right_E = (self.enc_bright + self.enc_fright)/2

                d_left = (left_dis - left_E) / self.ticks_meter
                d_right = (right_dis - right_E) / self.ticks_meter

            self.enc_bleft = self.bleft
            self.enc_bright = self.bright
	    self.enc_fleft = self.fleft
            self.enc_fright = self.fright
           
            # distance traveled is the average of the two wheels 
            d = ( d_left + d_right ) / 2
            # this approximation works (in radians) for small angles
            th = ( d_right - d_left ) / self.base_width
            # calculate velocities
            self.dx = d / elapsed
            self.dr = th / elapsed
           
             
            if (d != 0):
                # calculate distance traveled in x and y
                x = cos( th ) * d
                y = -sin( th ) * d
                # calculate the final position of the robot
                self.x = self.x + ( cos( self.th ) * x - sin( self.th ) * y )
                self.y = self.y + ( sin( self.th ) * x + cos( self.th ) * y )
            if( th != 0):
                self.th = self.th + th
                
            # publish the odom information
            quaternion = Quaternion()
            quaternion.x = 0.0
            quaternion.y = 0.0
            quaternion.z = sin( self.th / 2 )
            quaternion.w = cos( self.th / 2 )
            self.odomBroadcaster.sendTransform(
                (self.x, self.y, 0),
                (quaternion.x, quaternion.y, quaternion.z, quaternion.w),
                rospy.Time.now(),
                self.base_frame_id,
		self.odom_frame_id
                )
            
            odom = Odometry()
            odom.header.stamp = now
            odom.header.frame_id = self.odom_frame_id
            odom.pose.pose.position.x = self.x
            odom.pose.pose.position.y = self.y
            odom.pose.pose.position.z = 0
            odom.pose.pose.orientation = quaternion
            odom.child_frame_id = self.base_frame_id
            odom.twist.twist.linear.x = self.dx
            odom.twist.twist.linear.y = 0
            odom.twist.twist.angular.z = self.dr
	    odom.pose.covariance = list(self.covar.pose.covariance)
	    if self.covar.twist.twist.linear.x != odom.twist.twist.linear.x or self.covar.twist.twist.linear.y != odom.twist.twist.linear.y or self.covar.pose.covariance[0] == 0:
	        for i in range(36):
	            if i == 0 or i == 7 or i == 14:
			    odom.pose.covariance[i] = 0.01
		    elif i == 21 or i == 28 or i == 35:
			    odom.pose.covariance[i] += 0.01
		    else:
			    odom.pose.covariance[i] = 0

            self.odomPub.publish(odom)
    

    def create_con(self):


	self.flag = True

 	#cred = credentials.Certificate("serviceAccountKey.json")
	#firebase_admin.initialize_app(cred)
	#db = firestore.client()	
	#querying
	#Adding
	#data = {'name':'Chomu', 'age':69, 'flag' : False}
	#db.collection('persons').add(data)
	#time.sleep(10)
	#Reading
	#result = db.collection('persons').document("ccJ2gMzZ0SIpMgcPHOHP").get()

	# if result.exists:
	#     print(result.to_dict())

	#getting all res
	#print(self.flag, "Inside Con")
	docs = db.collection('users').get()
	#print (docs[1].id)
	
	for doc in docs:
		temp = doc.to_dict()
		self.flag = temp['flag']
		#print(temp)	

	self.flagger.publish(self.flag)
	

    def BLwheelCallback(self, msg):

        enc = msg.data
        if (enc < self.encoder_low_wrap and self.prev_blencoder > self.encoder_high_wrap):
            self.blmult = self.blmult + 1
            
        if (enc > self.encoder_high_wrap and self.prev_blencoder < self.encoder_low_wrap):
            self.blmult = self.blmult - 1
            
        self.bleft = 1.0 * (enc + self.blmult * (self.encoder_max - self.encoder_min)) 
        self.prev_blencoder = enc

    def BRwheelCallback(self, msg):
 
        enc = msg.data
        if(enc < self.encoder_low_wrap and self.prev_brencoder > self.encoder_high_wrap):
            self.brmult = self.brmult + 1
        
        if(enc > self.encoder_high_wrap and self.prev_brencoder < self.encoder_low_wrap):
            self.brmult = self.brmult - 1
            
        self.bright = 1.0 * (enc + self.brmult * (self.encoder_max - self.encoder_min))
        self.prev_brencoder = enc



    def FLwheelCallback(self, msg):

        enc = msg.data
        if (enc < self.encoder_low_wrap and self.prev_flencoder > self.encoder_high_wrap):
            self.flmult = self.flmult + 1
            
        if (enc > self.encoder_high_wrap and self.prev_flencoder < self.encoder_low_wrap):
            self.flmult = self.flmult - 1
            
        self.fleft = 1.0 * (enc + self.flmult * (self.encoder_max - self.encoder_min)) 
        self.prev_flencoder = enc
        
    def FRwheelCallback(self, msg):

        enc = msg.data
        if(enc < self.encoder_low_wrap and self.prev_frencoder > self.encoder_high_wrap):
            self.frmult = self.frmult + 1
        
        if(enc > self.encoder_high_wrap and self.prev_frencoder < self.encoder_low_wrap):
            self.frmult = self.frmult - 1
            
        self.fright = 1.0 * (enc + self.frmult * (self.encoder_max - self.encoder_min))
        self.prev_frencoder = enc


    def recall_cov(self, msg):
	self.covar = msg


if __name__ == '__main__':
    """ main """
    try:
        diffTf = DiffTf()
	#IoTnode = IoTNode()
        diffTf.spin()
    except rospy.ROSInterruptException:
        pass
